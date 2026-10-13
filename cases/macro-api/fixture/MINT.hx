import eval.integers.*;

class MINT {
	static function t(label:String, f:Void->Dynamic) {
		var r = try Std.string(f()) catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " => " + r);
	}

	public static macro function parse() {

		for (s in ["123", "-1", "+5", "0x1F", "0o17", "0b101", "0u123", "1_000", "_1", "", " 5", "5x",
				"18446744073709551615", "18446744073709551616", "9223372036854775808", "-9223372036854775808",
				"0xFFFFFFFFFFFFFFFF", "-0x1"]) {
			t("u " + haxe.Json.stringify(s), () -> UInt64.ofString(s).toString());
			t("i " + haxe.Json.stringify(s), () -> Int64.ofString(s).toString());
		}
		return macro null;
	}

	public static macro function arithmetic() {
		var um = UInt64.MAX, u1 = UInt64.ONE, uz = UInt64.ZERO;
		var imax = Int64.MAX, imin = Int64.MIN, i1 = Int64.ONE;
		t("wrap", () -> (um + u1).toString() + " " + (uz - u1).toString() + " " + (imax + i1).toString());
		t("udiv", () -> (um / UInt64.ofInt(7)).toString() + " " + (um % UInt64.ofInt(7)).toString());
		t("udiv0", () -> (um / uz).toString());
		t("imin/-1", () -> (imin / Int64.ofInt(-1)).toString() + " " + (imin % Int64.ofInt(-1)).toString());
		t("idiv", () -> (Int64.ofInt(-7) / Int64.ofInt(2)).toString() + " " + (Int64.ofInt(-7) % Int64.ofInt(2)).toString());
		t("shift", () -> (u1 << 64).toString() + " " + (u1 << 65).toString() + " " + (um >> 60).toString() + " " + (imin >> 63).toString());
		t("convert", () -> UInt64.ofInt(-1).toString() + " " + um.toInt() + " " + um.toInt64().toString() + " " + Int64.ofInt(-2).toUInt64().toString());
		t("compare", () -> UInt64.compare(um, u1) + " " + Int64.compare(imin, imax));
		t("hx", () -> {
			var h = Int64.ofString("-81985529216486896").toHxInt64();
			h.high + " " + h.low + " " + Int64.ofHxInt64(h).toString();
		});
		var d:Dynamic = UInt64.ofInt(7);
		t("value", () -> Std.string(d) + " " + Type.typeof(d) + " " + (d == d) + " " + ((UInt64.ofInt(7) : Dynamic) == d));
		t("decode", () -> Int64.compare(cast 5, i1));
		return macro null;
	}
}
