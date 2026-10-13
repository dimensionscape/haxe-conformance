class MREG {

	static function hex(s:String):String return haxe.io.Bytes.ofString(s).toHex();

	static function t(label:String, f:Void->Dynamic) {
		var r = try {
			var v:Dynamic = f();
			Std.isOfType(v, String) ? "= len=" + (v : String).length + " " + hex(v) : "= " + Std.string(v);
		} catch (e:Dynamic) "EXC " + hex(Std.string(e));
		Sys.println(label + " " + r);
	}

	static function bad(hex:String):String return haxe.io.Bytes.ofHex(hex).getString(0, Std.int(hex.length / 2));

	public static macro function bytes() {
		var x = bad("41ff42c3");
		var y = bad("6cc0af6c");
		var u = "héllo wörld 中 \u{1F600}";
		t("replace", () -> ~/B/.replace(x, "b"));
		t("dot-global", () -> ~/./g.replace(x, "D"));
		t("split", () -> ~/B/.split(x).join("|"));
		t("escape", () -> EReg.escape(x + "."));
		var r = ~/(.)(B)/;
		t("match", () -> r.match(x));
		t("left", () -> r.matchedLeft());
		t("right", () -> r.matchedRight());
		t("group1", () -> r.matched(1));
		t("group3", () -> r.matched(3));
		t("sub1", () -> ~/B/.matchSub(x, 1));
		t("sub3", () -> ~/B/.matchSub(x, 3));
		t("sub-len", () -> ~/B/.matchSub(x, 0, 2));
		t("utf-pos", () -> {
			var r = ~/w./u;
			r.match(u) ? r.matchedPos().pos + "," + r.matchedPos().len + " " + r.matched(0) : "none";
		});
		t("utf-split", () -> ~/ /g.split(u).length);
		t("groups", () -> ~/(a)|(b)/.replace("b", "[$1|$2]"));
		t("dollar", () -> ~/o/g.replace("foo", "$$"));
		t("options", () -> new EReg("^B", "im").match("a\nb"));
		return macro null;
	}

	public static macro function posBadUtf() {
		var r = ~/B/;
		r.match(bad("41ff42c3"));
		Sys.println(r.matchedPos().pos);
		return macro null;
	}

	public static macro function mapBadUtf() {
		Sys.println(~/l/g.map(bad("6cc0af6c"), m -> "L"));
		return macro null;
	}

	public static macro function mapBadOffset() {
		Sys.println(~//g.map("aéb", m -> "<" + m.matched(0) + ">"));
		return macro null;
	}
}
