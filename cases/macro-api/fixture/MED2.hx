import haxe.macro.Context;

private enum MedE2 { A; B(x:Int); C; D(s:String); }

private class MedK {
	public var n:Int;
	public function new(n) this.n = n;
	public function toString() return "K" + n;
	public function m(x:Int) return x;
	public static function s(x:Int) return x;
}

class MED2 {

	static var skip:Array<String> = [
		"string EReg opt",
	];

	static function t(label:String, f:Void->Dynamic) {
		if (skip.indexOf(label) >= 0) return;
		var r = try {
			var v:Dynamic = f();
			"= " + Std.string(v);
		} catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " " + r);
	}

	public static macro function decoders() {
		var odd:Array<{n:String, v:Dynamic}> = [
			{n: "null", v: null},
			{n: "int", v: 1},
			{n: "float", v: 1.7},
			{n: "string", v: "1"},
			{n: "bool", v: true},
			{n: "array", v: [1]},
		];
		for (o in odd) {
			var v:Dynamic = o.v;
			var n = o.n;
			var s:Dynamic = "hello";
			t(n + " fastCodeAt s", () -> StringTools.fastCodeAt(v, 0));
			t(n + " fastCodeAt i", () -> StringTools.fastCodeAt(s, v));
			t(n + " unsafeCodeAt i", () -> StringTools.unsafeCodeAt(s, v));
			t(n + " replace s", () -> StringTools.replace(v, "a", "b"));
			t(n + " replace sub", () -> StringTools.replace("abc", v, "b"));
			t(n + " replace by", () -> StringTools.replace("abc", "a", v));
			t(n + " urlEncode", () -> StringTools.urlEncode(v));
			t(n + " urlDecode", () -> StringTools.urlDecode(v));
			t(n + " Std.random", () -> Std.random(v) >= 0);
			t(n + " Sys.getEnv", () -> Sys.getEnv(v));
			t(n + " Sys.putEnv name", () -> { Sys.putEnv(v, "x"); null; });
			t(n + " Sys.sleep", () -> { Sys.sleep(n == "int" || n == "float" ? 0.001 : v); null; });
			t(n + " Reflect.field", () -> Reflect.field({a: 1}, v));
			t(n + " Reflect.field null", () -> Reflect.field(null, v));
			t(n + " Reflect.setField", () -> { var o = {a: 1}; Reflect.setField(o, v, 2); o; });
			t(n + " Reflect.hasField", () -> Reflect.hasField({a: 1}, v));
			t(n + " Reflect.deleteField", () -> Reflect.deleteField({a: 1}, v));
			t(n + " Reflect.getProperty", () -> Reflect.getProperty({a: 1}, v));
			t(n + " Reflect.setProperty", () -> { var o = {a: 1}; Reflect.setProperty(o, v, 2); o; });
			t(n + " Reflect.callMethod args", () -> Reflect.callMethod(null, function() return 1, v));
			t(n + " Reflect.callMethod fn", () -> Reflect.callMethod(null, v, []));
			t(n + " makeVarArgs", () -> (Reflect.makeVarArgs(v) : Dynamic)(1, 2));
			t(n + " EReg r", () -> new EReg(v, ""));
			t(n + " EReg opt", () -> new EReg("a", v));
			t(n + " Utf8.charCodeAt s", () -> haxe.Utf8.charCodeAt(v, 0));
			t(n + " Utf8.charCodeAt i", () -> haxe.Utf8.charCodeAt(s, v));
			t(n + " Utf8.compare", () -> haxe.Utf8.compare(v, "a"));
			t(n + " Utf8.decode", () -> haxe.Utf8.decode(v));
			t(n + " Utf8.encode", () -> haxe.Utf8.encode(v));
			t(n + " Utf8.iter s", () -> { haxe.Utf8.iter(v, c -> {}); null; });
			t(n + " Utf8.iter f", () -> { haxe.Utf8.iter("ab", v); null; });
			t(n + " Utf8.length", () -> haxe.Utf8.length(v));
			t(n + " Utf8.sub pos", () -> haxe.Utf8.sub(s, v, 2));
			t(n + " Utf8.sub len", () -> haxe.Utf8.sub(s, 1, v));
			t(n + " Utf8.validate", () -> haxe.Utf8.validate(v));
			t(n + " Utf8.addChar", () -> { var u = new haxe.Utf8(); u.addChar(v); u.toString(); });
			t(n + " Resource.getString", () -> haxe.Resource.getString(v));
			t(n + " Resource.getBytes", () -> haxe.Resource.getBytes(v));
			t(n + " Date.fromTime", () -> Date.fromTime(v).getTime());
			t(n + " Date.fromString", () -> Date.fromString(v));
			t(n + " new Date", () -> new Date(v, 1, 1, 0, 0, 0).getFullYear());
			t(n + " FileSystem.exists", () -> sys.FileSystem.exists(v));
			t(n + " FileSystem.isDirectory", () -> sys.FileSystem.isDirectory(v));
			t(n + " FileSystem.stat", () -> sys.FileSystem.stat(v) != null);
			t(n + " File.getContent", () -> sys.io.File.getContent(v));
			t(n + " File.saveContent content", () -> { sys.io.File.saveContent("evs5.tmp", v); sys.io.File.getContent("evs5.tmp"); });
			t(n + " BytesBuffer.addByte", () -> { var b = new haxe.io.BytesBuffer(); b.addByte(v); b.getBytes().toHex(); });
			t(n + " BytesBuffer.addString", () -> { var b = new haxe.io.BytesBuffer(); b.addString(v); b.getBytes().toHex(); });
			t(n + " BytesBuffer.addInt32", () -> { var b = new haxe.io.BytesBuffer(); b.addInt32(v); b.getBytes().toHex(); });
			t(n + " BytesBuffer.addInt64", () -> { var b = new haxe.io.BytesBuffer(); b.addInt64(v); b.getBytes().toHex(); });
			t(n + " BytesBuffer.addFloat", () -> { var b = new haxe.io.BytesBuffer(); b.addFloat(v); b.getBytes().toHex(); });
			t(n + " BytesBuffer.addDouble", () -> { var b = new haxe.io.BytesBuffer(); b.addDouble(v); b.getBytes().toHex(); });
			t(n + " BytesBuffer.addBytes pos", () -> { var b = new haxe.io.BytesBuffer(); b.addBytes(haxe.io.Bytes.ofString("abc"), v, 1); b.getBytes().toHex(); });
			t(n + " BytesBuffer.add", () -> { var b = new haxe.io.BytesBuffer(); b.add(v); b.getBytes().toHex(); });
			t(n + " Compress.run level", () -> haxe.zip.Compress.run(haxe.io.Bytes.ofString("aaaa"), v).length > 0);
			t(n + " Uncompress.run size", () -> haxe.zip.Uncompress.run(haxe.zip.Compress.run(haxe.io.Bytes.ofString("aaaa"), 9), v).toString());
			t(n + " Vector new", () -> new haxe.ds.Vector<Int>(v).length);
		}
		t("replace empty sub", () -> StringTools.replace("a\u{1F600}b", "", "-"));
		t("replace empty all", () -> StringTools.replace("", "", "-"));
		t("addBytes out", () -> { var b = new haxe.io.BytesBuffer(); b.addBytes(haxe.io.Bytes.ofString("abc"), 2, 5); b.getBytes().toHex(); });
		t("addBytes neg", () -> { var b = new haxe.io.BytesBuffer(); b.addBytes(haxe.io.Bytes.ofString("abc"), -1, 1); b.getBytes().toHex(); });
		t("addByte 300", () -> { var b = new haxe.io.BytesBuffer(); b.addByte(300); b.getBytes().toHex(); });
		t("addInt64", () -> { var b = new haxe.io.BytesBuffer(); b.addInt64(haxe.Int64.make(1, 2)); b.getBytes().toHex(); });
		t("Utf8.compare order", () -> [haxe.Utf8.compare("a", "b"), haxe.Utf8.compare("b", "a"), haxe.Utf8.compare("ab", "a"), haxe.Utf8.compare("\u{FFFD}", "\u{1F600}")]);
		t("Utf8.sub neg", () -> haxe.Utf8.sub("hello", -2, 5));
		t("Utf8.length", () -> haxe.Utf8.length("h\u{E9}llo"));
		t("unsafeCodeAt", () -> StringTools.unsafeCodeAt("abc", 1));
		t("callMethod null args", () -> Reflect.callMethod(null, null, null));
		t("field null null", () -> Reflect.field(null, null));
		t("getProperty null null", () -> Reflect.getProperty(null, null));
		t("EReg null null", () -> new EReg(null, null));
		t("rename order", () -> { var x:Dynamic = 5; sys.FileSystem.rename(x, null); null; });
		t("Date order", () -> { var x:Dynamic = "a"; var y:Dynamic = "b"; new Date(2020, x, 1, y, 0, 0); });
		t("replace order", () -> { var x:Dynamic = 1; var y:Dynamic = 2; StringTools.replace(x, y, null); });
		t("File.write binary", () -> { var o = sys.io.File.write("evs5.tmp", cast 5); o.writeString("x\n"); o.close(); sys.io.File.getContent("evs5.tmp").length; });
		try sys.FileSystem.deleteFile("evs5.tmp") catch (e:Dynamic) {}
		return macro null;
	}

	public static macro function datesAndCalls() {
		t("new Date 1969", () -> new Date(1969, 11, 31, 23, 59, 59).getTime());
		t("new Date 1970", () -> new Date(1970, 0, 1, 0, 0, 0).getTime());
		t("new Date 2020", () -> new Date(2020, 1, 30, 25, 61, 61).toString());
		t("new Date 2038", () -> new Date(2038, 0, 19, 3, 14, 8).getTime());
		t("new Date 3001", () -> new Date(3001, 0, 1, 0, 0, 0).getFullYear());
		t("fromString 1960", () -> Date.fromString("1960-01-01").getTime());
		t("fromString 1970", () -> Date.fromString("1970-01-01 00:00:00").getTime());
		t("fromString time", () -> Date.fromString("10:20:30").getTime());
		t("fromTime -1000 hours", () -> Date.fromTime(-1000).getHours());
		t("fromTime 0 utc", () -> Date.fromTime(0).getUTCHours());
		t("stat missing", () -> sys.FileSystem.stat("nope/x.txt"));
		t("stat missing slash", () -> sys.FileSystem.stat("nope/"));
		t("getContent missing", () -> sys.io.File.getContent("nope.txt"));
		var f:Dynamic = function(x) return x;
		t("closure extra", () -> f(1, 2));
		t("closure fewer", () -> f());
		t("callMethod extra", () -> Reflect.callMethod(null, f, [1, 2]));
		t("method extra", () -> Reflect.callMethod(new MedK(0), Reflect.field(new MedK(0), "m"), [1, 2]));
		t("static extra", () -> Reflect.callMethod(MedK, Reflect.field(MedK, "s"), [1, 2]));
		t("static dynamic extra", () -> { var g:Dynamic = MedK.s; g(1, 2); });
		t("enum ctor extra", () -> { var c:Dynamic = haxe.ds.Option.Some; c(1, 2); });
		t("EReg print", () -> ~/a(b)c/gi);
		t("EReg print new", () -> new EReg("x/y", "m"));
		t("EReg in array", () -> [~/q/]);
		return macro null;
	}

	public static macro function maps() {
		var sm = new haxe.ds.StringMap<Int>();
		for (k in ["b", "a", "c", "aa", "B", "", "z", "\u{E9}"]) sm.set(k, k.length);
		t("StringMap keys", () -> [for (k in sm.keys()) k]);
		t("StringMap toString", () -> sm.toString());
		var im = new haxe.ds.IntMap<Int>();
		for (k in [5, 3, 17, -1, 1000, 0, 33, 16, 2147483647, -2147483648]) im.set(k, k);
		t("IntMap keys", () -> [for (k in im.keys()) k]);
		t("IntMap toString", () -> im.toString());
		var om = new haxe.ds.ObjectMap<Dynamic, Int>();
		var objs:Array<Dynamic> = [new MedK(1), new MedK(2), {a: 1}, [1], new MedK(3), MED2, MedE2, "s"];
		for (i in 0...objs.length) om.set(objs[i], i);
		t("ObjectMap values", () -> [for (v in om) v]);
		t("ObjectMap keys", () -> [for (k in om.keys()) Std.string(k)]);
		var em = new haxe.ds.EnumValueMap<MedE2, Int>();
		for (k in [MedE2.C, MedE2.D("b"), MedE2.A, MedE2.B(2), MedE2.D("a"), MedE2.B(1), MedE2.B(10)]) em.set(k, 0);
		t("EnumValueMap keys", () -> [for (k in em.keys()) k]);
		t("EnumValueMap toString", () -> em.toString());
		t("EnumValueMap get", () -> em.get(MedE2.B(2)));
		t("EnumValueMap exists", () -> em.exists(MedE2.D("a")));
		t("EnumValueMap remove", () -> [em.remove(MedE2.B(1)), em.remove(MedE2.B(3))]);
		var dm:Dynamic = new haxe.ds.StringMap<Int>();
		var di:Dynamic = new haxe.ds.IntMap<Int>();
		for (v in ([null, 1, 1.7, "1", true, [1]] : Array<Dynamic>)) {
			t("StringMap set " + v, () -> { dm.set(v, 1); dm.exists(v); });
			t("StringMap get " + v, () -> dm.get(v));
			t("StringMap remove " + v, () -> dm.remove(v));
			t("IntMap set " + v, () -> { di.set(v, 1); di.exists(v); });
			t("IntMap get " + v, () -> di.get(v));
			t("IntMap remove " + v, () -> di.remove(v));
		}
		var m = new Map<String, Int>();
		m["x"] = 1;
		m["y"] = 2;
		t("Map copy", () -> [for (k in m.copy().keys()) k]);
		t("Map kv", () -> [for (k => v in m) k + "=" + v]);
		var sm = new haxe.ds.StringMap<Int>();
		for (k in ["b", "a", "c", "aa"]) sm.set(k, k.length);
		var im = new haxe.ds.IntMap<String>();
		for (k in [5, 3, 17, -1, 1000, 0]) im.set(k, "v" + k);
		var om = new haxe.ds.ObjectMap<Dynamic, Int>();
		var ks:Array<Dynamic> = [{a: 1}, [1], "s", 5];
		for (i in 0...ks.length) om.set(ks[i], i);
		for (m in ([sm, im, om] : Array<Dynamic>)) {
			Sys.println(Context.signature(m));
			Sys.println(try haxe.macro.ExprTools.toString(Context.makeExpr(m, Context.currentPos())) catch (e:Dynamic) "EXC " + e);
			Sys.println(Std.string(m));
		}
		var em = new haxe.ds.EnumValueMap<haxe.macro.Expr.Binop, Int>();
		em.set(OpSub, 1);
		em.set(OpAdd, 2);
		Sys.println(Std.string(em));
		Sys.println(try haxe.macro.ExprTools.toString(Context.makeExpr(em, Context.currentPos())) catch (e:Dynamic) "EXC " + e);
		Sys.println(Context.signature(em));
		return macro null;
	}

	public static macro function uncaught() {
		var a:Dynamic = [1];
		try a.resize(-1) catch (e:Dynamic) Sys.println("caught " + e);
		Sys.println("not reached");
		return macro null;
	}
}
