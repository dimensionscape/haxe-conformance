private enum MedE { A; B(x:Int); }

class MED {

	static var skip = [
		"bigfloat Type.createEnumIndex",
		"bigfloat StringBuf.addChar",
		"bigfloat EReg.matchSub pos",
		"negfloat Type.createEnumIndex",
		"negfloat StringBuf.addChar",
		"negfloat EReg.matchSub pos",
		"negfloat a.resize",
		"negfloat fromCharCode", "bigfloat fromCharCode", "bigfloat a.resize", "bigfloat Bytes.alloc",
		"negfloat Bytes.alloc", "bigfloat a.insert",
	];

	static function t(label:String, f:Void->Dynamic) {
		if (skip.indexOf(label) >= 0) return;
		var r = try {
			var v:Dynamic = f();
			"= " + Std.string(v);
		} catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " " + r);
	}

	static function bits(f:Float):String {
		var b = haxe.io.Bytes.alloc(8);
		b.setDouble(0, f);
		return b.toHex();
	}

	public static macro function decoders() {
		var odd:Array<{n:String, v:Dynamic}> = [
			{n: "null", v: null},
			{n: "int", v: 1},
			{n: "float", v: 1.7},
			{n: "negfloat", v: -1.7},
			{n: "bigfloat", v: 3e9},
			{n: "nan", v: Math.NaN},
			{n: "string", v: "1"},
			{n: "bool", v: true},
			{n: "array", v: [1]},
			{n: "anon", v: {a: 1}},
		];
		for (o in odd) {
			var v:Dynamic = o.v;
			var n = o.n;
			var s:Dynamic = "hello";
			t(n + " charAt", () -> s.charAt(v));
			t(n + " charCodeAt", () -> s.charCodeAt(v));
			t(n + " indexOf sub", () -> s.indexOf(v));
			t(n + " indexOf start", () -> s.indexOf("l", v));
			t(n + " lastIndexOf sub", () -> s.lastIndexOf(v));
			t(n + " lastIndexOf start", () -> s.lastIndexOf("l", v));
			t(n + " substr pos", () -> s.substr(v));
			t(n + " substr len", () -> s.substr(1, v));
			t(n + " substr past len", () -> s.substr(9, v));
			t(n + " substring start", () -> s.substring(v));
			t(n + " substring end", () -> s.substring(1, v));
			t(n + " split", () -> s.split(v));
			t(n + " fromCharCode", () -> String.fromCharCode(v));
			var a:Dynamic = [3, 1, 2];
			t(n + " a.indexOf from", () -> a.indexOf(1, v));
			t(n + " a.lastIndexOf from", () -> a.lastIndexOf(1, v));
			t(n + " empty lastIndexOf from", () -> { var e:Dynamic = []; e.lastIndexOf(1, v); });
			t(n + " a.insert", () -> { var b:Dynamic = [1, 2]; b.insert(v, 9); b; });
			t(n + " a.slice pos", () -> a.slice(v));
			t(n + " a.slice end", () -> a.slice(0, v));
			t(n + " a.splice pos", () -> { var b:Dynamic = [1, 2, 3]; b.splice(v, 1); });
			t(n + " a.splice len", () -> { var b:Dynamic = [1, 2, 3]; b.splice(0, v); });
			t(n + " a.join", () -> a.join(v));
			t(n + " a.concat", () -> a.concat(v));
			t(n + " a.map", () -> a.map(v));
			t(n + " empty map", () -> { var e:Dynamic = []; e.map(v); });
			t(n + " a.filter", () -> a.filter(v));
			t(n + " empty filter", () -> { var e:Dynamic = []; e.filter(v); });
			t(n + " a.resize", () -> { var b:Dynamic = [1, 2]; b.resize(v); b; });
			t(n + " a.sort cmp", () -> { var b:Dynamic = [2, 1]; b.sort(function(x, y) return v); b; });
			t(n + " Math.floor", () -> Math.floor(v));
			t(n + " Math.ceil", () -> Math.ceil(v));
			t(n + " Math.round", () -> Math.round(v));
			t(n + " Math.abs", () -> Math.abs(v));
			t(n + " Math.sqrt", () -> Math.sqrt(v));
			t(n + " Math.pow", () -> { var x:Dynamic = "x"; Math.pow(v, x); });
			t(n + " Math.min", () -> Math.min(v, 2));
			t(n + " Math.max", () -> Math.max(2, v));
			t(n + " Math.atan2", () -> { var y:Dynamic = "y"; Math.atan2(v, y); });
			t(n + " Math.isNaN", () -> Math.isNaN(v));
			t(n + " Math.isFinite", () -> Math.isFinite(v));
			t(n + " Math.fround", () -> Math.fround(v));
			var by = haxe.io.Bytes.ofString("abcdefgh");
			t(n + " b.get", () -> by.get(v));
			t(n + " b.set pos", () -> { by.set(v, 65); by.toString(); });
			t(n + " b.set value", () -> { var c = haxe.io.Bytes.alloc(1); c.set(0, v); c.get(0); });
			t(n + " b.getDouble", () -> by.getDouble(v));
			t(n + " b.getFloat", () -> by.getFloat(v));
			t(n + " b.getInt32", () -> by.getInt32(v));
			t(n + " b.getUInt16", () -> by.getUInt16(v));
			t(n + " b.getInt64", () -> by.getInt64(v));
			t(n + " b.getString pos", () -> by.getString(v, 1));
			t(n + " b.sub len", () -> by.sub(0, v));
			t(n + " b.fill value", () -> { var c = haxe.io.Bytes.alloc(2); c.fill(0, 2, v); c.toHex(); });
			t(n + " b.blit src", () -> { var c = haxe.io.Bytes.alloc(2); c.blit(0, v, 0, 1); c.toHex(); });
			t(n + " b.compare", () -> by.compare(v));
			t(n + " b.setDouble value", () -> { var c = haxe.io.Bytes.alloc(8); c.setDouble(0, v); c.toHex(); });
			t(n + " b.setInt32 value", () -> { var c = haxe.io.Bytes.alloc(4); c.setInt32(0, v); c.toHex(); });
			t(n + " b.setInt64 value", () -> { var c = haxe.io.Bytes.alloc(8); c.setInt64(0, v); c.toHex(); });
			t(n + " b.setUInt16 value", () -> { var c = haxe.io.Bytes.alloc(2); c.setUInt16(0, v); c.toHex(); });
			t(n + " Bytes.alloc", () -> haxe.io.Bytes.alloc(v).length);
			t(n + " Bytes.ofHex", () -> haxe.io.Bytes.ofHex(v));
			t(n + " Bytes.ofString", () -> haxe.io.Bytes.ofString(v));
			t(n + " FPHelper.doubleToI64", () -> haxe.io.FPHelper.doubleToI64(v));
			t(n + " FPHelper.floatToI32", () -> haxe.io.FPHelper.floatToI32(v));
			t(n + " FPHelper.i32ToFloat", () -> haxe.io.FPHelper.i32ToFloat(v));
			t(n + " FPHelper.i64ToDouble", () -> haxe.io.FPHelper.i64ToDouble(v, 0));
			t(n + " EReg.matched", () -> { var r = ~/(a)(b)?/; r.match("ab"); r.matched(v); });
			t(n + " EReg.matchSub pos", () -> ~/a/.matchSub("xa", v));
			t(n + " EReg.matchSub len", () -> ~/a/.matchSub("xa", 0, v));
			t(n + " StringBuf.addChar", () -> { var b = new StringBuf(); b.addChar(v); b.toString(); });
			t(n + " StringBuf.addSub s", () -> { var b = new StringBuf(); b.addSub(v, 0); b.toString(); });
			t(n + " StringBuf.addSub len", () -> { var b = new StringBuf(); b.addSub("hello", 1, v); b.toString(); });
			t(n + " Type.createEnum e", () -> Type.createEnum(v, "A"));
			t(n + " Type.createEnum name", () -> Type.createEnum(MedE, v));
			t(n + " Type.createEnumIndex", () -> Type.createEnumIndex(MedE, v));
			t(n + " Type.createInstance cl", () -> Type.createInstance(v, []));
			t(n + " Type.createInstance args", () -> Type.createInstance(StringBuf, v));
			t(n + " Type.resolveClass", () -> Type.resolveClass(v));
			t(n + " Type.resolveEnum", () -> Type.resolveEnum(v));
		}

		var b = haxe.io.Bytes.ofString("abcd");
		t("getInt64 ok", () -> b.getInt64(0));
		t("getInt64 str", () -> Std.string(haxe.io.Bytes.ofHex("0100000002000000").getInt64(0)));
		t("doubleToI64 1", () -> Std.string(haxe.io.FPHelper.doubleToI64(1.0)));
		t("setInt32 partial", () -> { var c = haxe.io.Bytes.alloc(4); try c.setInt32(2, -1) catch (e:Dynamic) {}; c.toHex(); });
		t("setDouble partial", () -> { var c = haxe.io.Bytes.alloc(4); try c.setDouble(0, 1.5) catch (e:Dynamic) {}; c.toHex(); });
		t("fill out", () -> { b.fill(3, 2, 7); b.toHex(); });
		t("fill neg", () -> { b.fill(-1, 1, 7); b.toHex(); });
		t("blit out", () -> { b.blit(3, b, 0, 2); b.toHex(); });
		t("compare longer", () -> haxe.io.Bytes.ofString("ab").compare(haxe.io.Bytes.ofString("abcd")));
		t("compare shorter", () -> haxe.io.Bytes.ofString("abcd").compare(haxe.io.Bytes.ofString("ab")));
		t("compare bigger", () -> haxe.io.Bytes.ofString("b").compare(haxe.io.Bytes.ofString("abcd")));
		t("ofHex upper", () -> haxe.io.Bytes.ofHex("ABcd").toHex());
		t("ofHex junk", () -> haxe.io.Bytes.ofHex("zz!!").toHex());
		t("matched after map", () -> { var r = ~/a/; r.map("aa", r -> "b"); r.matched(0); });
		t("matched unmatched group", () -> { var r = ~/(a)|(b)/; r.match("b"); r.matched(1); });
		t("Math.abs int min", () -> Math.abs(-2147483647 - 1));
		t("Math.abs int type", () -> Std.isOfType(Math.abs(-5), Int));
		t("Math.floor int min", () -> Math.floor(cast(-2147483647 - 1)));
		t("Math.min zeros", () -> 1 / Math.min(0.0, -0.0));
		t("Math.max zeros", () -> 1 / Math.max(-0.0, 0.0));
		t("pow order", () -> { var x:Dynamic = "a"; var y:Dynamic = "b"; Math.pow(x, y); });
		t("atan2 order", () -> { var x:Dynamic = "a"; var y:Dynamic = "b"; Math.atan2(x, y); });
		t("concat order", () -> { var x:Dynamic = "x"; var y:Dynamic = 5; y.concat(x); });
		var vec = new haxe.ds.Vector<Int>(2);
		var nv:Dynamic = null;
		t("vector join null", () -> (cast vec : Dynamic).join(nv));
		t("vector map null", () -> vec.map(nv));
		return macro null;
	}

	public static macro function sortAndNan() {
		for (n in [0, 1, 2, 3, 4, 5, 7, 10, 17]) {
			var a = [for (i in 0...n) {k: i % 3, i: i}];
			a.sort((x, y) -> x.k - y.k);
			Sys.println(n + " ties: " + [for (x in a) x.i].join(","));
			var calls = [];
			var b = [for (i in 0...n) (i * 7) % 5];
			b.sort(function(x, y) {
				calls.push(x + "" + y);
				return x - y;
			});
			Sys.println(n + " sorted: " + b.join(",") + " calls: " + calls.join(" "));
		}
		var c = [3, 1, 2];
		c.sort((x, y) -> 0);
		Sys.println("all equal: " + c);
		var d = [5, 4, 3, 2, 1];
		try d.sort(function(x, y) { if (x == 2 || y == 2) throw "stop"; return x - y; }) catch (e:Dynamic) {}
		Sys.println("after throw: " + d);
		Sys.println("Math.NaN " + bits(Math.NaN));
		Sys.println("sqrt -1 " + bits(Math.sqrt(-1)));
		Sys.println("parseFloat x " + bits(Std.parseFloat("x")));
		var z:Dynamic = 0.0;
		Sys.println("0/0 " + bits(z / z));
		var i5:Dynamic = 5;
		var i0:Dynamic = 0;
		Sys.println("5%0 " + bits(i5 % i0));
		var mn:Dynamic = -2147483647 - 1;
		var m1:Dynamic = -1;
		Sys.println("min%-1 " + (mn % m1));
		Sys.println("7%-1 " + (i5 % m1));
		Sys.println("doubleToI64 NaN " + haxe.io.FPHelper.doubleToI64(Math.NaN));
		Sys.println("floatToI32 NaN " + haxe.io.FPHelper.floatToI32(Math.NaN));
		Sys.println("unserialize k " + bits(haxe.Unserializer.run("k")));
		return macro null;
	}
}
