import eval.luv.*;

class MLUVA {
	static function t(label:String, f:Void->Dynamic) {
		var r = try Std.string(f()) catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " => " + r);
	}

	public static macro function buffer() {
		var b = Buffer.fromString("hello world");
		var s = b.sub(6, 5);
		var c = Buffer.create(5);
		c.fill(65);
		t("get", () -> b.size() + " " + b.get(1) + " " + b.get(10));
		t("sub-shares", () -> { s.set(0, 87); b.toString(); });
		t("blit", () -> { s.blit(c); c.toString(); });
		t("drop", () -> [for (x in Buffer.drop([b, s, c], 13)) x.toString()].join("|") + " " + Buffer.totalSize([b, s, c]));
		t("bytes", () -> { var bytes = haxe.io.Bytes.ofString("0123456789"); s.blitToBytes(bytes, 2); bytes.toString(); });
		t("from", () -> { c.blitFromBytes(haxe.io.Bytes.ofString("xyzuv"), 0); c.toString() + " " + Buffer.fromBytes(haxe.io.Bytes.ofString("abc")).toString(); });
		t("value", () -> Std.string((b : Dynamic)) + " " + ((b : Dynamic) == (b : Dynamic)) + " " + ((b.sub(0, 1) : Dynamic) == (b.sub(0, 1) : Dynamic)));
		t("decode", () -> Buffer.totalSize(cast [5]));
		return macro null;
	}

	public static macro function outOfBounds() {
		Buffer.fromString("abc").get(3);
		return macro null;
	}

	public static macro function charOfInt() {
		Buffer.fromString("abc").set(0, 256);
		return macro null;
	}

	public static macro function sockaddr() {
		for (h in ["127.0.0.1", "255.255.255.255", "1.2.3", "::1", "abc"]) {
			t("ipv4 " + h, () -> switch (SockAddr.ipv4(h, 8080)) { case Ok(a): a.toString() + " " + a.port; case Error(e): "Error " + e; });
			t("ipv6 " + h, () -> switch (SockAddr.ipv6(h, 65535)) { case Ok(a): a.toString() + " " + a.port; case Error(e): "Error " + e; });
		}
		return macro null;
	}

	public static macro function env() {
		Env.setEnv("HXC_CONF_LUV", eval.NativeString.fromString("luv"));
		t("setEnv", () -> Sys.getEnv("HXC_CONF_LUV") + " " + Sys.environment().get("HXC_CONF_LUV"));
		Sys.putEnv("HXC_CONF_SYS", "sys");
		Env.unsetEnv("HXC_CONF_SYS");
		t("unsetEnv", () -> Sys.getEnv("HXC_CONF_SYS") + " " + Sys.environment().get("HXC_CONF_SYS"));
		t("getEnv", () -> switch (Env.getEnv("HXC_CONF_MISSING")) { case Ok(v): v.toString(); case Error(e): "Error " + e; });
		return macro null;
	}
}
