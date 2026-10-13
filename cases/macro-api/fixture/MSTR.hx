class MSTR {

	static function hex(s:String):String return haxe.io.Bytes.ofString(s).toHex();

	static function show(v:Dynamic):String {
		if (Std.isOfType(v, String)) {
			var s:String = v;
			return "len=" + s.length + " " + hex(s);
		}
		return hex(Std.string(v));
	}

	static function t(label:String, f:Void->Dynamic) {
		var r = try {
			var v:Dynamic = f();
			"= " + show(v);
		} catch (e:Dynamic) "EXC " + hex(Std.string(e));
		Sys.println(label + " " + r);
	}

	static function bad(hex:String):String return haxe.io.Bytes.ofHex(hex).getString(0, Std.int(hex.length / 2));

	public static macro function bytes() {
		var s:Dynamic = "héllo wörld \u{1F602}!";
		var sur:Dynamic = String.fromCharCode(0xD800) + "x" + String.fromCharCode(0xDFFF);
		var big:Dynamic = String.fromCharCode(0x110000) + String.fromCharCode(0x7FFFFFFF);
		var inv:Dynamic = bad("41ff42c3");
		for (c in [0x7F, 0x80, 0x7FF, 0x800, 0xFFFF, 0x10000, 0x10FFFF, 0x110000, 0x1FFFFF, 0x200000, 0x3FFFFFF, 0x4000000, 0x7FFFFFFF])
			t("fromCharCode " + c, () -> String.fromCharCode(c));
		for (h in ["c3a9", "ff", "80", "eda080", "f4908080", "c0af"])
			t("getString " + h, () -> haxe.io.Bytes.ofHex(h).getString(0, Std.int(h.length / 2)).length);
		for (h in ["c3a9", "ff", "eda080", "f4908080"])
			t("toString " + h, () -> haxe.io.Bytes.ofHex(h).toString().length);
		var xs:Array<Dynamic> = [s, sur, big];
		for (x in xs) {
			t("charAt", () -> x.charAt(1));
			t("charCodeAt", () -> x.charCodeAt(2));
			t("substr", () -> x.substr(1, 2));
			t("substring", () -> x.substring(3, 1));
			t("upper", () -> x.toUpperCase());
			t("lower", () -> x.toLowerCase());
			t("split", () -> x.split(""));
			t("split x", () -> x.split("x"));
			t("indexOf", () -> x.indexOf("\u{1F602}"));
			t("lastIndexOf", () -> x.lastIndexOf("o"));
			t("replace", () -> StringTools.replace(x, "l", "ß"));
			t("replace empty", () -> StringTools.replace(x, "", "-"));
			t("urlEncode", () -> StringTools.urlEncode(x));
			t("concat len", () -> (x + 1).length);
			t("array print len", () -> Std.string([x, 1]).length);
			t("object print len", () -> Std.string({a: x, b: 2}).length);
			t("bytes", () -> haxe.io.Bytes.ofString(x).toHex());
			t("md5", () -> haxe.crypto.Md5.encode(x));
			t("utf8 encode len", () -> haxe.Utf8.encode(x).length);
			t("cmp", () -> (x < "h") + " " + (x > "h"));
			t("join len", () -> [x, x].join("·").length);
			t("native", () -> { var n:eval.NativeString = x; n.length + "/" + n.code(0); });
		}
		t("inv length", () -> inv.length);
		t("inv urlEncode", () -> StringTools.urlEncode(inv));
		t("inv message", () -> { var n:eval.NativeString = inv; n.length; });
		t("inv concat", () -> (inv + "|").length);
		t("buf", () -> { var b = new StringBuf(); b.add("é"); b.add(1); b.add([s]); b.addChar(0x1F602); b.addChar(0xD800); b.addChar(0x110000); b.addSub(s, 1, 3); b.toString().length + "/" + b.length; });
		t("utf8 buf", () -> { var u = new haxe.Utf8(); u.addChar(0xE9); u.addChar(0x1F602); u.addChar(0x110000); u.toString().length; });
		for (u in ["%C3%A9", "%E2%82%AC", "%F0%9F%98%82", "%zz", "a+b%20c", "é"])
			t("urlDecode " + u, () -> StringTools.urlDecode(u));
		return macro null;
	}

	public static macro function fatal() {
		haxe.macro.Context.warning("recorded first", haxe.macro.Context.currentPos());
		var inv:String = bad("41ff42");
		Sys.println(inv.charCodeAt(1));
		return macro null;
	}
}
