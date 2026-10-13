class MEV {
	static function t(label:String, f:Void->Dynamic) {
		var r = try {
			var v:Dynamic = f();
			"= " + Std.string(v);
		} catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " " + r);
	}

	public static macro function natives() {
		var values:Array<{n:String, v:Dynamic}> = [
			{n: "int", v: 1},
			{n: "float", v: 1.5},
			{n: "bool", v: true},
			{n: "string", v: "s"},
			{n: "array", v: [1]},
			{n: "null", v: null},
			{n: "func", v: function() return 1},
			{n: "anon", v: {a: 1}},
			{n: "enumval", v: haxe.ds.Option.Some(1)},
			{n: "bytes", v: haxe.io.Bytes.ofString("ab")},
		];
		for (x in values) {
			var v:Dynamic = x.v;
			var n = x.n;
			t(n + " fields", () -> { var a:Array<String> = Reflect.fields(v); a.sort(Reflect.compare); a; });
			t(n + " copy", () -> Reflect.copy(v));
			t(n + " setField", () -> { Reflect.setField(v, "a", 5); Reflect.field(v, "a"); });
			t(n + " enumIndex", () -> Type.enumIndex(v));
			t(n + " enumParameters", () -> Type.enumParameters(v));
			t(n + " enumConstructor", () -> Type.enumConstructor(v));
			t(n + " int", () -> Std.int(v));
			t(n + " parseInt", () -> Std.parseInt(v));
			t(n + " parseFloat", () -> Std.parseFloat(v));
		}
		var fl:Array<Float> = [2.9, -2.9, 3e9, -3e9, 2147483648.0, 1e15, 5e18, 1e19, -1e20, Math.NaN, Math.POSITIVE_INFINITY];
		for (f in fl) Sys.println("Std.int(" + f + ") = " + Std.int(f));
		var arr:Dynamic = [1, 2, 3];
		Reflect.setField(arr, "length", 1);
		Sys.println("array after length 1: " + (arr : Array<Int>).length);
		t("array setField other", () -> { Reflect.setField(arr, "x", 1); null; });
		return macro null;
	}
}
