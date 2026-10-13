import eval.luv.*;
#if macro
import eval.luv.Signal.SigNum;
#end

class MLUVB {
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

	public static macro function echo() {
		var loop = Loop.defaultLoop();
		var slog = [], clog = [];
		var server = ok(Tcp.init(loop));
		t("bind", () -> res(server.bind(ok(SockAddr.ipv4("127.0.0.1", 0)))));
		var port = ok(server.getSockName()).port;
		server.listen(r -> {
			slog.push("connection " + res(r));
			var client = ok(Tcp.init(loop));
			slog.push("accept " + res(server.accept(client)));
			slog.push("peer " + ok(client.getPeerName()).toString());
			client.readStart(r -> switch (r) {
				case Ok(b):
					slog.push("read " + b.toString() + " " + b.size());
					slog.push("write ret " + Std.string(client.write([b], (r, n) -> slog.push("echoed " + res(r) + " " + n))));
				case Error(e):
					slog.push("read error " + e + " " + e.errName());
					client.close(() -> {
						slog.push("server client closed");
						server.close(() -> slog.push("server closed"));
					});
			});
		});
		var c = ok(Tcp.init(loop));
		c.connect(ok(SockAddr.ipv4("127.0.0.1", port)), r -> {
			clog.push("connected " + res(r));
			clog.push("readable " + c.isReadable() + " writable " + c.isWritable());
			clog.push("peer " + (ok(c.getPeerName()).port == port));
			clog.push("tryWrite " + res(c.tryWrite([Buffer.fromString("")])));
			c.write([Buffer.fromString("hel"), Buffer.fromString("lo")], (r, n) -> clog.push("written " + res(r) + " " + n));
			var got = 0;
			c.readStart(r -> switch (r) {
				case Ok(b):
					clog.push("got " + b.toString());
					got += b.size();
					if (got == 5) {
						clog.push("readStop " + res(c.readStop()));
						c.shutdown(r -> {
							clog.push("shutdown " + res(r));
							c.close(() -> clog.push("client closed"));
						});
					}
				case Error(e):
					clog.push("client read error " + e);
			}, size -> {
				clog.push("alloc " + (size > 0));
				Buffer.create(3);
			});
		});
		t("run", () -> loop.run(DEFAULT));
		Sys.println("server: " + slog.join(" | "));
		Sys.println("client: " + clog.join(" | "));
		return macro null;
	}

	public static macro function unconnected() {
		var loop = Loop.defaultLoop();
		var c = ok(Tcp.init(loop));
		t("noDelay", () -> res(c.noDelay(true)));
		t("keepAlive", () -> res(c.keepAlive(Some(10))) + " " + res(c.keepAlive(None)));
		t("simultaneousAccepts", () -> res(c.simultaneousAccepts(true)));
		t("names", () -> res(c.getSockName()) + " " + res(c.getPeerName()));
		t("readable", () -> c.isReadable() + " " + c.isWritable());
		t("bufferSizes", () -> res(Handle.sendBufferSize(c)) + " " + res(Handle.recvBufferSize(c)));
		t("readStart", () -> { c.readStart(r -> Sys.println("read cb " + res(r))); "ret"; });
		t("readStop", () -> res(c.readStop()));
		t("write", () -> c.write([Buffer.fromString("x")], (r, n) -> Sys.println("write cb " + res(r) + " " + n)));
		t("tryWrite", () -> res(c.tryWrite([Buffer.fromString("x")])));
		t("shutdown", () -> { c.shutdown(r -> Sys.println("shutdown cb " + res(r))); "ret"; });
		t("setBlocking", () -> res(c.setBlocking(true)));
		t("closeReset", () -> { c.closeReset(r -> Sys.println("closeReset cb " + res(r))); "ret"; });
		t("closeReset again", () -> { c.closeReset(r -> Sys.println("closeReset again cb " + res(r))); Handle.isClosing(c); });
		t("run", () -> loop.run(DEFAULT));
		var probe = ok(Tcp.init(loop));
		ok(probe.bind(ok(SockAddr.ipv4("127.0.0.1", 0))));
		var port = ok(probe.getSockName()).port;

		probe.close(() -> {
			Sys.println("probe closed");
			var d = ok(Tcp.init(loop));
			d.connect(ok(SockAddr.ipv4("127.0.0.1", port)), r -> {
				Sys.println("connect " + res(r));
				d.close(() -> Sys.println("closed"));
			});
		});
		t("run refused", () -> loop.run(DEFAULT));
		return macro null;
	}

	public static macro function domains() {
		var loop = Loop.defaultLoop();
		var c = ok(Tcp.init(loop, INET));
		t("setSend", () -> res(Handle.setSendBufferSize(c, 65536)) + " " + res(Handle.sendBufferSize(c)));
		t("sockname", () -> res(c.getSockName()));
		t("init6", () -> res(Tcp.init(loop, INET6)).substr(0, 3));
		t("initUnspec", () -> res(Tcp.init(loop, UNSPEC)).substr(0, 3));
		t("initOther", () -> res(Tcp.init(loop, OTHER(12345))));
		t("bind ipv6only on ipv4", () -> res(ok(Tcp.init(loop)).bind(ok(SockAddr.ipv4("127.0.0.1", 0)), true)));

		var cls = Type.resolveClass("eval.luv._Handle.Handle_Impl_");
		t("setRendBufferSize", () -> res(Reflect.callMethod(null, Reflect.field(cls, "setRendBufferSize"), [c, 32768])) + " " + res(Handle.recvBufferSize(c)));
		t("setRecvBufferSize", () -> Handle.setRecvBufferSize(c, 1024));
		t("close", () -> { c.close(() -> Sys.println("closed")); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		return macro null;
	}

	public static macro function decoders() {
		var loop = Loop.defaultLoop();
		var tm = ok(Timer.init(loop));
		t("tcp-timer", () -> (cast tm : Tcp).noDelay(true));
		t("tcp-int", () -> (cast 1 : Tcp).noDelay(true));
		t("stream-timer", () -> Stream.readStop(cast tm));
		t("stream-int", () -> Stream.readStop(cast 1));
		t("socket-timer", () -> Handle.sendBufferSize(cast tm));
		t("socket-int", () -> Handle.sendBufferSize(cast 1));
		t("accept-mixed", () -> Stream.accept(cast ok(Tcp.init(loop)), cast tm));
		t("write-notarray", () -> Stream.write(cast ok(Tcp.init(loop)), cast 1, (r, n) -> {}));
		t("write-notbuffer", () -> Stream.write(cast ok(Tcp.init(loop)), cast [1], (r, n) -> {}));
		t("keepAlive-bad", () -> ok(Tcp.init(loop)).keepAlive(cast 1));
		t("keepAlive-null", () -> ok(Tcp.init(loop)).keepAlive(null));
		t("init-badfamily", () -> Tcp.init(loop, cast 1));
		t("init-badloop", () -> Tcp.init(cast 1));
		t("signal-timer", () -> (cast tm : Signal).stop());
		t("handle-close-tcp", () -> { Handle.close(ok(Tcp.init(loop)), () -> Sys.println("tcp closed")); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		return macro null;
	}

	public static macro function signals() {
		var loop = Loop.defaultLoop();
		t("nums", () -> [SigNum.SIGABRT, SigNum.SIGFPE, SigNum.SIGHUP, SigNum.SIGILL, SigNum.SIGINT, SigNum.SIGKILL, SigNum.SIGSEGV, SigNum.SIGTERM, SigNum.SIGWINCH].join(","));
		var s = ok(Signal.init(loop));
		t("idle", () -> s.signum() + " " + Handle.isActive(s));
		t("start", () -> res(s.start(SIGWINCH, () -> Sys.println("sig"))) + " " + s.signum() + " " + Handle.isActive(s));
		t("stop", () -> res(s.stop()) + " " + s.signum());
		t("oneshot", () -> res(s.startOneshot(SIGINT, () -> Sys.println("sig1"))) + " " + s.signum());
		t("bad", () -> res(s.start(0, () -> {})) + " " + res(s.start(100, () -> {})));
		t("close", () -> { res(s.stop()); Handle.close(s, () -> Sys.println("closed")); "ret"; });
		t("run", () -> loop.run(DEFAULT));
		return macro null;
	}

	public static macro function callbackException() {
		var loop = Loop.defaultLoop();
		var server = ok(Tcp.init(loop));
		ok(server.bind(ok(SockAddr.ipv4("127.0.0.1", 0))));
		var port = ok(server.getSockName()).port;
		server.listen(r -> throw "boom in connection");
		var c = ok(Tcp.init(loop));

		c.connect(ok(SockAddr.ipv4("127.0.0.1", port)), r -> {});
		loop.run(DEFAULT);
		return macro null;
	}

	public static macro function nullSlot() {
		var c = ok(Tcp.init(Loop.defaultLoop(), INET));
		var f:Dynamic = Handle.setRecvBufferSize;
		Sys.println("read " + f);
		Handle.setRecvBufferSize(c, 1);
		return macro null;
	}
}
