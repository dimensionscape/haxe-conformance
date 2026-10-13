import eval.luv.*;

class MLUVC {
	static function t(label:String, f:Void->Dynamic) {
		var r = try Std.string(f()) catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " => " + r);
	}

#if macro
	static function res<T>(r:Result<T>):String {
		return switch (r) {
			case Ok(v): "Ok(" + Std.string(v) + ")";
			case Error(e): "Error(" + e + " " + e.errName() + ")";
		}
	}

	static function ok<T>(r:Result<T>):T {
		return switch (r) {
			case Ok(v): v;
			case Error(e): throw "unexpected " + e;
		}
	}

	static function local():SockAddr return ok(SockAddr.ipv4("127.0.0.1", 0));

	static function pipeName():String {
		var n = "hxcconf" + Std.random(1000000);
		return Sys.systemName() == "Windows" ? "\\\\.\\pipe\\" + n : Sys.getCwd() + n;
	}
#end

	public static macro function udp() {
		var loop = Loop.defaultLoop();

		var alog = [], bsend = [], brecv = [];
		var a = ok(Udp.init(loop));
		var b = ok(Udp.init(loop, INET, false));
		t("bind", () -> res(a.bind(local())) + " " + res(b.bind(local(), false, true)));
		var aport = ok(a.getSockName()).port;
		var bport = ok(b.getSockName()).port;
		t("ports", () -> aport > 0 && bport > 0 && aport != bport);
		t("options", () -> [res(a.setBroadcast(true)), res(a.setTtl(64)), res(a.setMulticastLoop(true)), res(a.setMulticastTtl(2)),
			res(a.setMulticastInterface(cast "127.0.0.1")), res(a.setMembership("239.1.2.3", "127.0.0.1", JOIN_GROUP)),
			res(a.setMembership("239.1.2.3", "127.0.0.1", LEAVE_GROUP)), res(a.setTtl(0)), res(a.setMulticastTtl(300))].join(" "));
		t("queue", () -> a.getSendQueueSize() + " " + a.getSendQueueCount());
		t("usingRecvmmsg", () -> b.usingRecvmmsg());
		a.recvStart((r, ?_) -> switch (r) {
			case Ok(o):
				alog.push("a got " + o.data.toString() + " " + o.data.size() + " from " + (switch (o.addr) { case Some(x): Std.string(x.port == bport); case None: "none"; }) + " flags " + o.flags);
				alog.push("a recvStop " + res(a.recvStop()));
				a.close(() -> alog.push("a closed"));
			case Error(e):
				alog.push("a error " + e);
		});

		var udpImpl = Type.resolveClass("eval.luv._Udp.Udp_Impl_");
		Reflect.callMethod(null, Reflect.field(udpImpl, "recvStart"), [b, function(r:Result<Dynamic>) switch (r) {
			case Ok(o):
				brecv.push("b got " + (o.data : Buffer).toString() + " flags " + o.flags);
				b.close(() -> brecv.push("b closed"));
			case Error(e):
				brecv.push("b error " + e);
		}, function(size:Int) {
			brecv.push("b alloc " + (size > 0));
			return Buffer.create(2);
		}]);
		b.send([Buffer.fromString("pi"), Buffer.fromString("ng")], ok(SockAddr.ipv4("127.0.0.1", aport)), r -> bsend.push("b sent " + res(r)));
		t("trySend", () -> res(a.trySend([Buffer.fromString("pong")], ok(SockAddr.ipv4("127.0.0.1", bport)))));
		t("run", () -> loop.run(DEFAULT));
		Sys.println(alog.join(" | ") + " || " + bsend.join(" | ") + " || " + brecv.join(" | "));
		return macro null;
	}

	public static macro function connected() {
		var loop = Loop.defaultLoop();
		var log = [];
		var a = ok(Udp.init(loop));
		ok(a.bind(local()));
		var aport = ok(a.getSockName()).port;
		var b = ok(Udp.init(loop));
		ok(b.bind(local()));
		t("peer before", () -> res((cast b : ConnectedUdp).getPeerName()));
		var c:ConnectedUdp = ok(b.connect(ok(SockAddr.ipv4("127.0.0.1", aport))));
		t("same handle", () -> (cast c : Udp) == b);
		t("peer", () -> ok(c.getPeerName()).port == aport);
		t("connect again", () -> res(b.connect(ok(SockAddr.ipv4("127.0.0.1", aport)))));

		a.recvStart((r, ?_) -> switch (r) {
			case Ok(o):
				log.push("a got " + o.data.toString());
				b.close(() -> log.push("b closed"));
				a.close(() -> log.push("a closed"));
			case Error(e): log.push("a error " + e);
		});
		t("send", () -> { c.send([Buffer.fromString("hi")], r -> log.push("send cb " + res(r))); "ret"; });
		var cimpl = Type.resolveClass("eval.luv._ConnectedUdp.ConnectedUdp_Impl_");
		t("send value", () -> res(Reflect.callMethod(null, Reflect.field(cimpl, "send"), [c, [Buffer.fromString("hi2")]])));
		t("fields", () -> { var f = Type.getClassFields(cimpl); f.sort(Reflect.compare); f.join(","); });
		t("disconnect", () -> res(c.disconnect()) + " " + res(c.getPeerName()) + " " + res(c.disconnect()));
		t("send disconnected", () -> res(Reflect.callMethod(null, Reflect.field(cimpl, "send"), [c, [Buffer.fromString("x")]])));
		t("run", () -> loop.run(DEFAULT));
		Sys.println(log.join(" | "));
		return macro null;
	}

	public static macro function udpErrors() {
		var loop = Loop.defaultLoop();
		var a = ok(Udp.init(loop));
		t("sockname", () -> res(a.getSockName()));
		t("recvStop", () -> res(a.recvStop()));
		t("init", () -> res(Udp.init(loop, OTHER(12345))) + " " + res(Udp.init(loop, INET6)).substr(0, 3));
		t("membership bad", () -> res(a.setMembership("1.2.3.4", "127.0.0.1", cast 5)));
		t("membership", () -> res(a.setMembership("1.2.3.4", "127.0.0.1", JOIN_GROUP)) + " " + res(a.setMembership("zzz", "", JOIN_GROUP)));
		t("interface", () -> res(a.setMulticastInterface(cast "zzz")));
		t("decode", () -> (cast ok(Timer.init(loop)) : Udp).setTtl(1));
		t("close", () -> { a.close(() -> Sys.println("closed")); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		return macro null;
	}

	public static macro function pipe() {
		var loop = Loop.defaultLoop();
		var log = [];
		var name = pipeName();
		var server = ok(Pipe.init(loop));
		t("bind", () -> res(server.bind(name)));
		t("sockname", () -> switch (server.getSockName()) { case Ok(n): Std.string(n.toString() == name); case Error(e): "Error " + e; });
		t("peername", () -> res(server.getPeerName()));
		t("pending", () -> { server.pendingInstances(2); server.receiveHandle(); });
		server.listen(r -> {
			log.push("connection " + res(r));
			var client = ok(Pipe.init(loop));
			log.push("accept " + res(server.accept(client)));
			client.readStart(r -> switch (r) {
				case Ok(b):
					log.push("server read " + b.toString());
					client.write([b], (r, n) -> {
						log.push("server wrote " + res(r) + " " + n);
						client.close(() -> {
							log.push("server client closed");
							server.close(() -> log.push("server closed"));
						});
					});
				case Error(e): log.push("server read error " + e);
			});
		});
		var c = ok(Pipe.init(loop, false));
		c.connect(name, r -> {
			log.push("connected " + res(r));
			log.push("peer " + (switch (c.getPeerName()) { case Ok(n): Std.string(n.toString() == name); case Error(e): "Error " + e; }));
			c.write([Buffer.fromString("yo")], (r, n) -> log.push("client wrote " + res(r) + " " + n));
			c.readStart(r -> switch (r) {
				case Ok(b):
					log.push("client read " + b.toString());
				case Error(e):
					log.push("client read error " + e);
					c.close(() -> log.push("client closed"));
			});
		});
		t("run", () -> loop.run(DEFAULT));
		Sys.println(log.join(" | "));
		return macro null;
	}

	public static macro function pipeErrors() {
		var loop = Loop.defaultLoop();
		var p = ok(Pipe.init(loop));
		t("names", () -> res(p.getSockName()) + " " + res(p.getPeerName()));
		t("chmod bad", () -> res(p.chmod(cast 7)));
		t("chmod", () -> res(p.chmod(READ)));
		t("receive", () -> p.receiveHandle());
		var q = ok(Pipe.init(loop));
		q.connect(pipeName(), r -> {
			Sys.println("connect " + res(r));
			q.close(() -> Sys.println("q closed"));
		});
		t("decode", () -> (cast ok(Timer.init(loop)) : Pipe).chmod(READ));
		t("close", () -> { p.close(() -> Sys.println("closed")); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		return macro null;
	}

	public static macro function fsEvent() {
		var loop = Loop.defaultLoop();
		var dir = Sys.getCwd() + "fsev_" + Std.random(1000000);
		sys.FileSystem.createDirectory(dir);
		var e = ok(FsEvent.init(loop));
		var got = false;
		e.start(dir, null, r -> {
			if (got) return;
			got = true;
			switch (r) {
				case Ok(o): Sys.println("event file " + o.file + " events " + o.events);
				case Error(err): Sys.println("event error " + err);
			}
			Sys.println("stop " + res(e.stop()));
			e.close(() -> Sys.println("closed"));
		});
		var tm = ok(Timer.init(loop));
		tm.start(() -> {
			sys.io.File.saveContent(dir + "/a.txt", "x");
			tm.close(() -> {});
		}, 50);
		t("run", () -> loop.run(DEFAULT));
		try sys.FileSystem.deleteFile(dir + "/a.txt") catch (_:Dynamic) {}
		try sys.FileSystem.deleteDirectory(dir) catch (_:Dynamic) {}

		var f = ok(FsEvent.init(loop));
		f.start(dir + "/gone", null, r -> Sys.println("cb " + res(r)));
		t("flags", () -> { f.start(dir + "/gone", [FS_EVENT_WATCH_ENTRY, FS_EVENT_STAT, FS_EVENT_RECURSIVE], r -> Sys.println("cb2 " + res(r))); "ret"; });
		t("decode", () -> (cast ok(Timer.init(loop)) : FsEvent).stop());
		t("close", () -> { f.close(() -> Sys.println("f closed")); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		return macro null;
	}
}
