import eval.luv.*;

class MLUV {
	static function p(s:Dynamic) Sys.println(s);

	public static macro function sync() {
		var m = Mutex.init().resolve();
		m.lock();
		p("trylock-held " + m.tryLock());
		m.unlock();
		p("trylock-free " + m.tryLock());
		m.unlock();
		var rw = RwLock.init().resolve();
		rw.rdLock();
		p("rd-rd " + rw.rdTryLock());
		rw.rdUnlock();
		p("rd-wr " + rw.wrTryLock());
		rw.rdUnlock();
		var s = Semaphore.init(1).resolve();
		p("sem " + s.tryWait() + " " + s.tryWait());
		s.post();
		p("sem-post " + s.tryWait());
		var b = Barrier.init(1).resolve();
		p("barrier " + b.wait());
		var o = Once.init().resolve();
		var n = 0;
		for (_ in 0...3) o.once(() -> n++);
		p("once " + n);
		return macro null;
	}

	public static macro function loop() {
		var loop = Loop.init().resolve();
		p("alive " + loop.alive() + " nowait " + loop.run(NOWAIT));

		var order = [];
		for (k in 0...4) Timer.init(loop).resolve().start(() -> order.push("t" + k), 0);
		var r = Timer.init(loop).resolve();
		var count = 0;
		r.start(() -> { order.push("r" + count); if (++count == 3) r.stop(); }, 0, 1);
		p("run " + loop.run(DEFAULT));
		p(order.join(","));

		var watched = [];
		var i = Idle.init(loop).resolve();
		var c = Check.init(loop).resolve();
		var pr = Prepare.init(loop).resolve();
		var ticks = 0;
		i.start(() -> { watched.push("idle"); if (++ticks == 2) { i.stop(); c.stop(); pr.stop(); } });
		p("again " + i.start(() -> watched.push("never")));
		c.start(() -> watched.push("check"));
		pr.start(() -> watched.push("prepare"));
		p("run " + loop.run(DEFAULT));
		p(watched.join(","));
		var t = Timer.init(loop).resolve();
		t.close(() -> p("closed " + t.isClosing()));
		p("closing " + t.isClosing());
		p("run " + loop.run(DEFAULT) + " close " + loop.close());
		p("handle " + Std.string((loop : Dynamic)) + " " + Type.typeof(loop) + " " + (loop == loop)
			+ " " + (Loop.defaultLoop() == Loop.defaultLoop()));
		return macro null;
	}

	public static macro function errors() {
		for (i in [0, 5, 22, 34, 47, 68, 71, 72, 81]) {
			var e:UVError = cast i;
			p(i + " " + e.errName() + " " + e.toString());
		}
		p("translate " + UVError.translateSysError(0) + " " + UVError.translateSysError(999999));
		p("version " + Version.major + "." + Version.minor + "." + Version.patch + " " + Version.isRelease);
		return macro null;
	}

	public static macro function reflection() {
		p(Reflect.fields(new sys.thread.Condition()).join(","));
		p(Reflect.fields(new sys.thread.Semaphore(1)).join(","));
		p(Type.getInstanceFields(sys.thread.Condition).join(","));
		p(Type.getInstanceFields(sys.thread.Semaphore).join(","));
		p(Type.getInstanceFields(sys.thread.EventLoop).join(","));
		return macro null;
	}

	public static macro function fields() {
		p(Type.getInstanceFields(MLUVBase).join(","));
		p(Type.getInstanceFields(MLUVSub).join(","));
		return macro null;
	}

	public static macro function callbackException() {
		var loop = Loop.init().resolve();
		Timer.init(loop).resolve().start(() -> throw "from a timer", 1);
		loop.run(DEFAULT);
		p("not reached");
		return macro null;
	}

	public static macro function closeException() {
		var loop = Loop.init().resolve();
		Timer.init(loop).resolve().close(() -> throw "from a close callback");
		loop.run(DEFAULT);
		p("not reached");
		return macro null;
	}

	public static macro function handler() {
		UVError.setOnUnhandledException(e -> p("handled: " + e.message));
		var loop = Loop.init().resolve();
		Timer.init(loop).resolve().start(() -> throw "from a timer", 1);
		p("run " + loop.run(DEFAULT));
		return macro null;
	}
}

class MLUVBase {
	public var x:Int = 0;
	var y:String;
	public function new() {}
	public function f() {}
	function g() {}
}

class MLUVSub extends MLUVBase {
	public var z = 1;
	override public function f() {}
	public function h() {}
}
