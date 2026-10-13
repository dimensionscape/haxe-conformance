private abstract MedA5(Int) {
	public function new(i:Int) this = i;
	public function toString() return "A(" + this + ")";
}

class MED5 {
	static function t(label:String, f:Void->Dynamic) {
		var r = try {
			var v:Dynamic = f();
			"= " + Std.string(v);
		} catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " " + r);
	}

	public static macro function run() {
		t("std string", () -> Std.string(new MedA5(5)));
		t("concat", () -> "" + new MedA5(5));
		t("interp", () -> '${new MedA5(6)}');
		t("map kv null", () -> { var m:Map<String, Int> = null; m.keyValueIterator(); });
		t("map for null", () -> { var m:Map<String, Int> = null; for (k => v in m) {} null; });
		t("map int", () -> { var m = new Map<Int, String>(); m.set(1, "a"); [for (k => v in m) k + v]; });
		t("map obj", () -> { var o = {}; var m = new Map<{}, Int>(); m.set(o, 1); m.get(o); });
		t("map enum", () -> { var m = new Map<haxe.ds.Option<Int>, Int>(); m.set(None, 3); m.get(None); });
		t("map string", () -> { var m = ["b" => 1, "a" => 2]; m.toString(); });
		t("map copy", () -> { var m = ["x" => 1]; var c = m.copy(); c["y"] = 2; [m.exists("y"), c.exists("y")]; });
		t("null map get", () -> { var m:Map<String, Int> = null; m.get("a"); });
		t("null map set", () -> { var m:Map<String, Int> = null; m.set("a", 1); null; });
		return macro null;
	}
}
