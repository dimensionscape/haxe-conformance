class MCF {
	static function shape(v:Dynamic, depth:Int = 0):String {
		if (v == null) return "null";
		if (Std.isOfType(v, Bool) || Std.isOfType(v, Int) || Std.isOfType(v, Float)) return Std.string(v);
		if (Std.isOfType(v, String)) return '"' + v + '"';
		if (depth > 4) return "..";
		if (Reflect.isEnumValue(v)) return Type.enumConstructor(v) + "(" + [for (p in Type.enumParameters(v)) shape(p, depth + 1)].join(",") + ")";
		if (Std.isOfType(v, Array)) return "[" + [for (x in (v : Array<Dynamic>)) shape(x, depth + 1)].join(",") + "]";
		if (Std.isOfType(v, haxe.ds.StringMap)) {
			var m:haxe.ds.StringMap<Dynamic> = v;
			var ks = [for (k in m.keys()) k];
			ks.sort(Reflect.compare);
			return "StringMap{" + [for (k in ks) k + "=>" + shape(m.get(k), depth + 1)].join(",") + "}";
		}
		var fs = Reflect.fields(v);
		fs.sort(Reflect.compare);
		return "{" + [for (f in fs) f + ":" + shape(Reflect.field(v, f), depth + 1)].join(" ") + "}";
	}
	public static macro function config() {
		var c = haxe.macro.Compiler.getConfiguration();
		Sys.println("platform " + c.platform);
		Sys.println("platformConfig " + shape(c.platformConfig));
		Sys.println("packageRules " + shape(c.packageRules));
		return macro null;
	}
}
