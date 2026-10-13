import eval.luv.*;
#if macro
import eval.luv.Random;
import eval.luv.Dns;
import eval.luv.Process;
#end

class MLUVE {
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
#end

	public static macro function random() {
		var loop = Loop.defaultLoop();
		var b = Buffer.create(16);
		Random.random(loop, b, null, r -> {
			Sys.println("random " + res(r) + " " + b.size());
			Random.random(loop, Buffer.create(0), Random.createRequest(), r -> Sys.println("random empty " + res(r)));
		});
		t("sync", () -> res(RandomSync.random(Buffer.create(4))));
		t("bad buffer", () -> { Random.random(loop, cast 1, null, r -> {}); "ret"; });
		t("bad request", () -> { Random.random(loop, Buffer.create(1), cast 1, r -> {}); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		return macro null;
	}

	public static macro function dns() {
		var loop = Loop.defaultLoop();
		Dns.getAddrInfo(loop, "127.0.0.1", "80", {family: INET, sockType: STREAM, flags: [NUMERICHOST, NUMERICSERV]}, r -> {
			switch (r) {
				case Ok(a): Sys.println("addr " + a.length + " " + [for (i in a) i.family + "/" + i.sockType + "/" + i.protocol + "/" + i.addr.toString() + ":" + i.addr.port + "/" + i.canonName].join(";"));
				case Error(e): Sys.println("addr error " + e);
			}
			Dns.getAddrInfo(loop, "127.0.0.1", null, {flags: [CANONNAME, NUMERICHOST], request: Dns.createAddrRequest()}, r -> {
				switch (r) {
					case Ok(a): Sys.println("canon " + [for (i in a) Std.string(i.canonName)].join(","));
					case Error(e): Sys.println("canon error " + e);
				}
				Dns.getAddrInfo(loop, "no.such.host.invalid", null, {flags: [NUMERICHOST]}, r -> {
					Sys.println("not numeric " + res(r));
					Dns.getNameInfo(loop, ok(SockAddr.ipv4("127.0.0.1", 80)), {flags: [NUMERICHOST, NUMERICSERV]}, r -> switch (r) {
						case Ok(o): Sys.println("name " + (o : Dynamic).node + " " + o.service + " " + (o : Dynamic).hostName);
						case Error(e): Sys.println("name error " + e);
					});
				});
			});
		});
		t("neither", () -> { Dns.getAddrInfo(loop, null, null, null, r -> {}); "ret"; });
		t("bad flag", () -> { Dns.getAddrInfo(loop, "x", null, {flags: [cast 9]}, r -> {}); "ret"; });
		t("bad request", () -> { Dns.getAddrInfo(loop, "x", null, {request: cast 1}, r -> {}); "ret"; });
		t("name bad flag", () -> { Dns.getNameInfo(loop, ok(SockAddr.ipv4("127.0.0.1", 80)), {flags: [cast 9]}, r -> {}); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		return macro null;
	}

	public static macro function process() {
		if (Sys.systemName() != "Windows") return macro null;
		var loop = Loop.defaultLoop();
		var log = [];
		var out = ok(Pipe.init(loop));
		var p = ok(Process.spawn(loop, "cmd.exe", ["cmd.exe", "/c", "echo hi&& exit 3"], {
			redirect: [Process.toParentPipe(1, out, false, true, false)],
			onExit: (proc, status, signal) -> {
				log.push("exit " + status.toString() + " " + signal);
				proc.close(() -> log.push("proc closed"));
			}
		}));
		t("pid", () -> p.pid() > 0);
		out.readStart(r -> switch (r) {
			case Ok(b): log.push("out " + StringTools.trim(b.toString()));
			case Error(e):
				log.push("out end " + e);
				out.close(() -> log.push("out closed"));
		});
		t("spawn missing", () -> res(Process.spawn(loop, "no_such_program_xyz", ["no_such_program_xyz"])));
		t("spawn env eq", () -> res(Process.spawn(loop, "cmd.exe", ["cmd.exe"], {environment: ["A=B" => "c"]})));
		t("spawn bad cwd", () -> res(Process.spawn(loop, "cmd.exe", ["cmd.exe", "/c", "exit"], {workingDirectory: "Z:/no/such/dir"})));
		t("spawn bad env", () -> Process.spawn(loop, "cmd.exe", ["cmd.exe"], {environment: cast 1}));
		t("spawn bad redirect", () -> Process.spawn(loop, "cmd.exe", ["cmd.exe"], {redirect: cast [1]}));
		t("spawn bad options", () -> Process.spawn(loop, "cmd.exe", ["cmd.exe"], cast 1));
		t("killPid", () -> res(Process.killPid(999999, 15)));
		t("run", () -> loop.run(DEFAULT));

		log.sort(Reflect.compare);
		Sys.println(log.join(" | "));
		return macro null;
	}

	public static macro function threads() {
		var loop = Loop.defaultLoop();
		var m = ok(Mutex.init());
		var log = [];
		var th = ok(Thread.create(() -> {
			m.lock();
			log.push("in thread");
			m.unlock();
		}));
		t("join", () -> res(th.join()) + " " + log.join(","));
		t("self", () -> Thread.self() != null);
		t("stack", () -> { var t2 = ok(Thread.create(() -> log.push("big"), 1024 * 1024)); res(t2.join()) + " " + log.join(","); });
		t("bad join", () -> (cast 1 : Thread).join());
		var plog = [];
		ThreadPool.queueWork(loop, null, () -> {
			m.lock();
			plog.push("work");
			m.unlock();
		}, r -> {
			plog.push("done " + res(r));
			ThreadPool.queueWork(loop, ThreadPool.createRequest(), () -> {}, r -> plog.push("done2 " + res(r)));
		});
		t("setSize", () -> { ThreadPool.setSize(4, true); "ret"; });
		t("bad request", () -> { ThreadPool.queueWork(loop, cast 1, () -> {}, r -> {}); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		Sys.println(plog.join(" | "));
		t("cancel", () -> res(Dns.createAddrRequest().cancel()) + " " + res(Random.createRequest().cancel()) + " " + res(ThreadPool.createRequest().cancel()));
		t("cancel bad", () -> (cast 1 : Request).cancel());
		return macro null;
	}
}
