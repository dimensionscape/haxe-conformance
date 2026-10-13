import Family;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

/** Reference outputs, one JSON object per family: case name to normalized output, in case order. **/
class Expectations {
	public static function file(dir:String, family:String):String
		return Path.join([dir, family + ".json"]);

	public static function load(dir:String, family:String):Map<String, String> {
		var out = new Map<String, String>();
		var path = file(dir, family);
		if (!FileSystem.exists(path)) return out;
		var json:Dynamic = haxe.Json.parse(File.getContent(path));
		for (k in Reflect.fields(json)) out.set(k, Reflect.field(json, k));
		return out;
	}

	public static function save(dir:String, f:Family, outputs:Map<String, String>) {
		var b = new StringBuf();
		b.add("{\n");
		var first = true;
		for (c in f.cases) {
			if (!outputs.exists(c.name)) continue;
			if (!first) b.add(",\n");
			first = false;
			b.add("\t" + quote(c.name) + ": " + quote(outputs.get(c.name)));
		}
		b.add("\n}\n");
		Exec.mkdirs(dir);
		File.saveContent(file(dir, f.name), b.toString());
	}

	static function quote(s:String):String {
		var b = new StringBuf();
		b.add('"');
		for (i in 0...s.length) {
			var c = StringTools.fastCodeAt(s, i);
			switch (c) {
				case '"'.code: b.add('\\"');
				case '\\'.code: b.add("\\\\");
				case '\n'.code: b.add("\\n");
				case '\r'.code: b.add("\\r");
				case '\t'.code: b.add("\\t");
				case c if (c < 0x20 || c == 0x7F): b.add("\\u" + StringTools.hex(c, 4));
				case _: b.addChar(c);
			}
		}
		b.add('"');
		return b.toString();
	}
}
