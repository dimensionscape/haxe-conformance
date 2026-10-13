private enum MedE3 { A; B(x:Int); C; }

private class MedK3 {
	public var f:Int = 1;
	public function new() {}
	public function m() return f;
	public function self(v:Dynamic):Dynamic {
		var me:MedK3 = v;
		return me.f;
	}
}

private class MedS3 {
	public static var x:Int = 0;
}

class MED3 {

	static var skip:Array<String> = [
		"int vector index",
	];

	static function t(label:String, f:Void->Dynamic) {
		if (skip.indexOf(label) >= 0) return;
		var r = try {
			var v:Dynamic = f();
			"= " + Std.string(v);
		} catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " " + r);
	}

	public static macro function emitter() {
		var odd:Array<{n:String, v:Dynamic}> = [
			{n: "null", v: null},
			{n: "int", v: 5},
			{n: "float", v: 1.7},
			{n: "string", v: "s"},
			{n: "array", v: [1]},
		];
		for (o in odd) {
			var v:Dynamic = o.v;
			var n = o.n;
			t(n + " array read", () -> { var a:Array<Int> = v; a[0]; });
			t(n + " array length", () -> { var a:Array<Int> = v; a.length; });
			t(n + " array write", () -> { var a:Array<Int> = v; a[0] = 1; });
			t(n + " array rw", () -> { var a:Array<Int> = v; a[0] += 1; });
			t(n + " array index", () -> { var a = [1, 2]; var i:Int = v; a[i]; });
			t(n + " array index write", () -> { var a = [1, 2]; var i:Int = v; a[i] = 3; });
			t(n + " array index rw", () -> { var a = [1, 2]; var i:Int = v; a[i] += 3; });
			t(n + " vector read", () -> { var a:haxe.ds.Vector<Int> = v; a[0]; });
			t(n + " vector length", () -> { var a:haxe.ds.Vector<Int> = v; a.length; });
			t(n + " vector write", () -> { var a:haxe.ds.Vector<Int> = v; a[0] = 1; });
			t(n + " vector index", () -> { var a = new haxe.ds.Vector<Int>(2); var i:Int = v; a[i]; });
			t(n + " new vector", () -> { var i:Int = v; new haxe.ds.Vector<Int>(i).length; });
			t(n + " bytes length", () -> { var b:haxe.io.Bytes = v; b.length; });
			t(n + " incr", () -> { var i:Int = v; i++; i; });
			t(n + " decr prefix", () -> { var i:Int = v; --i; });
			t(n + " field read", () -> { var k:MedK3 = v; k.f; });
			t(n + " field write", () -> { var k:MedK3 = v; k.f = 2; });
			t(n + " field rw", () -> { var k:MedK3 = v; k.f += 2; });
			t(n + " int switch", () -> { var i:Int = v; switch (i) { case 1: "one"; case 2: "two"; case 3: "three"; case _: "other"; } });
			t(n + " string switch", () -> { var s:String = v; switch (s) { case "a": 1; case "b": 2; case "c": 3; case _: 0; } });
			t(n + " enum switch", () -> { var e:MedE3 = v; switch (e) { case A: 1; case B(_): 2; case C: 3; } });
			t(n + " fastCodeAt s", () -> StringTools.fastCodeAt(v, 0));
			t(n + " fastCodeAt i", () -> StringTools.fastCodeAt("abc", v));
			t(n + " neg", () -> { var i:Int = v; -i; });
			t(n + " negbits", () -> { var i:Int = v; ~i; });
			t(n + " captured incr", () -> { var i:Int = v; var f = () -> i; i++; f(); });
			t(n + " captured decr", () -> { var i:Int = v; var f = () -> i; i--; f(); });
			t(n + " postfix decr", () -> { var i:Int = v; i--; });
			t(n + " prefix incr", () -> { var i:Int = v; ++i; });
			t(n + " field incr", () -> { var k:MedK3 = v; k.f++; });
			t(n + " field decr", () -> { var k:MedK3 = new MedK3(); var x:Int = v; k.f = x; k.f--; });
			t(n + " static incr", () -> { MedS3.x = v; MedS3.x++; MedS3.x; });
			t(n + " array incr", () -> { var a:Array<Int> = [v]; a[0]++; a[0]; });
			t(n + " array neg index write", () -> { var a = [1]; var i:Int = v; a[i - 10] = 1; a; });
			t(n + " method call", () -> { var k:MedK3 = v; k.m(); });
			t(n + " this field", () -> { var k:MedK3 = new MedK3(); k.self(v); });
			t(n + " anon field", () -> { var o:{x:Int} = v; o.x; });
			t(n + " anon field write", () -> { var o:{x:Int} = v; o.x = 1; });
			t(n + " dynamic field", () -> { var o:Dynamic = v; o.x; });
			t(n + " dynamic index", () -> { var o:Dynamic = v; o[0]; });
		}
		return macro null;
	}

	public static macro function arity() {
		var abs:Dynamic = Math.abs;
		t("abs 2", () -> abs(-1, 2));
		t("abs 1", () -> abs(-1));
		var now:Dynamic = Date.now;
		t("now 1", () -> now(1) != null);
		var s:Dynamic = "abc";
		t("charAt 2", () -> s.charAt(0, 1));
		t("charAt 1", () -> s.charAt(1));
		var a:Dynamic = [1];
		t("push 2", () -> a.push(1, 2));
		var b:Dynamic = haxe.io.Bytes.alloc(4);
		t("blit 5", () -> b.blit(0, haxe.io.Bytes.alloc(4), 0, 1, 9));
		t("blit 4", () -> { b.blit(0, haxe.io.Bytes.alloc(4), 0, 1); "ok"; });
		var m:Dynamic = new haxe.ds.StringMap<Int>();
		t("map set 3", () -> m.set("a", 1, 2));
		var tr:Dynamic = Reflect.callMethod;
		t("callMethod 4", () -> tr(null, abs, [1], 4));
		t("callMethod via callMethod", () -> Reflect.callMethod(null, abs, [1, 2]));
		t("string field closure", () -> { var f:Dynamic = "xyz".charAt; f(0, 1); });
		return macro null;
	}
}
