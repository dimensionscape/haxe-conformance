import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/** What a case's result is compared against. **/
enum abstract Oracle(String) from String to String {
	/** The output of Haxe: recorded under expected/, or a live compiler given with --haxe. */
	var Haxe = "haxe";

	/** The case's own `===` block. */
	var Expected = "expected";

	/** The compiler under test itself, e.g. two compiles of the same input. */
	var Self = "self";
}

enum abstract Cost(String) from String to String {
	var Quick = "quick";
	var Medium = "medium";
	var Slow = "slow";
}

enum abstract Kind(String) from String to String {
	/** Compile the case; compare what the compiler printed. */
	var CompileDiff = "compile-diff";

	/** Compile and run the case; compare what the program printed. */
	var Run = "run";

	/** Compile the case; compare the file it generated. */
	var EmitDiff = "emit-diff";

	/** Compile the case twice; require identical generated files. */
	var CompileTwice = "compile-twice";
}

typedef Case = {
	var family:Family;
	var name:String;
	var source:String;

	/** Dotted module the source is written as, e.g. `foo.A` is written to foo/A.hx. */
	var module:String;

	var args:Array<String>;
	var expect:Null<String>;
}

class Family {
	public var dir:String;
	public var name:String;
	public var oracle:Oracle;
	public var cost:Cost;
	public var kind:Kind;
	public var exclusive:Bool;
	public var recount:Bool;
	public var module:String;
	public var args:Array<String>;
	public var chdir:Bool;
	public var fixture:Null<String>;

	/** Cases whose result depends on the machine, compared with a running Haxe. */
	public var live:Array<String>;

	public var cases:Array<Case>;

	function new() {}

	public static function discover(root:String):Array<Family> {
		var out:Array<Family> = [];
		function walk(dir:String) {
			if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) return;
			if (FileSystem.exists(Path.join([dir, "family.json"]))) {
				out.push(load(dir));
				return;
			}
			var entries = FileSystem.readDirectory(dir);
			entries.sort(Reflect.compare);
			for (entry in entries) walk(Path.join([dir, entry]));
		}
		walk(root);
		out.sort((a, b) -> Reflect.compare(a.name, b.name));
		return out;
	}

	public static function load(dir:String):Family {
		var manifest = Path.join([dir, "family.json"]);
		var json:Dynamic = try haxe.Json.parse(File.getContent(manifest)) catch (e:Dynamic) throw '$manifest: $e';
		var f = new Family();
		f.dir = dir;
		f.name = required(json, "name", manifest);
		f.oracle = required(json, "oracle", manifest);
		f.kind = required(json, "kind", manifest);
		f.cost = json.cost != null ? json.cost : Cost.Quick;
		f.exclusive = json.exclusive == true;
		f.recount = json.recount == true;
		f.module = json.module != null ? json.module : "P";
		f.args = json.args != null ? json.args : ["-cp", ".", "$module", "--no-output"];
		f.chdir = json.chdir == true;
		f.live = json.live != null ? json.live : [];
		var fixture = Path.join([dir, "fixture"]);
		f.fixture = FileSystem.exists(fixture) && FileSystem.isDirectory(fixture) ? fixture : null;

		switch ((f.kind : String)) {
			case Kind.CompileDiff | Kind.Run | Kind.EmitDiff | Kind.CompileTwice:
			case other: throw '$manifest: unknown kind "$other"';
		}
		switch ((f.oracle : String)) {
			case Oracle.Haxe | Oracle.Expected | Oracle.Self:
			case other: throw '$manifest: unknown oracle "$other"';
		}

		var casesPath = Path.join([dir, "cases.hx.txt"]);
		if (!FileSystem.exists(casesPath)) throw '$dir: missing cases.hx.txt';
		f.cases = parse(f, File.getContent(casesPath), casesPath);
		if (f.cases.length == 0) throw '$casesPath: no cases';
		var seen = new Map<String, Bool>();
		for (n in f.live)
			if (!Lambda.exists(f.cases, c -> c.name == n)) throw '$manifest: "live" names an unknown case "$n"';
		for (c in f.cases) {
			if (seen.exists(c.name)) throw '$casesPath: duplicate case "${c.name}"';
			seen.set(c.name, true);
			if ((f.oracle : String) == Oracle.Expected && c.expect == null)
				throw '$casesPath: case "${c.name}" needs a === block';
		}
		return f;
	}

	static function required(json:Dynamic, field:String, where:String):String {
		var v = Reflect.field(json, field);
		if (v == null) throw '$where: missing "$field"';
		return v;
	}

	/**
		    --- case-name [@ module] [+ extra args]
		    source...
		    ===
		    expected output (oracle "expected" only)

		Lines that are exactly `#` or start with `# ` are comments.
	**/
	public static function parse(f:Family, text:String, where:String):Array<Case> {
		var out:Array<Case> = [];
		var current:Null<Case> = null;
		var src:Array<String> = [];
		var expect:Null<Array<String>> = null;

		function flush() {
			if (current == null) return;
			while (src.length > 0 && src[src.length - 1].trim() == "") src.pop();
			current.source = src.join("\n");
			if (current.source == "") throw '$where: case "${current.name}" has no source';
			if (expect != null) {
				while (expect.length > 0 && expect[expect.length - 1].trim() == "") expect.pop();
				current.expect = expect.join("\n");
			}
			out.push(current);
			current = null;
			src = [];
			expect = null;
		}

		for (raw in text.split("\n")) {
			var line = raw.endsWith("\r") ? raw.substr(0, raw.length - 1) : raw;
			if (line == "#" || line.startsWith("# ")) continue;
			if (line.startsWith("---")) {
				flush();
				var head = line.substr(3).trim();
				var args:Array<String> = [];
				var plus = head.indexOf(" + ");
				if (plus >= 0) {
					args = splitArgs(head.substr(plus + 3));
					head = head.substr(0, plus).trim();
				}
				var module = f.module;
				var at = head.indexOf("@");
				if (at >= 0) {
					module = head.substr(at + 1).trim();
					head = head.substr(0, at).trim();
					if (module == "") throw '$where: empty module after @';
				}
				if (head == "") throw '$where: unnamed case';
				current = {family: f, name: head, source: "", module: module, args: args, expect: null};
			} else if (current == null) {
				if (line.trim() != "") throw '$where: text before the first case: $line';
			} else if (line.startsWith("===")) {
				expect = [];
			} else if (expect != null) {
				expect.push(line);
			} else {
				src.push(line);
			}
		}
		flush();
		return out;
	}

	/**
		Whitespace separates arguments. `"` groups (and is dropped); `'` outside a group protects its
		spaces and is kept; `\"` is a literal double quote.
	**/
	public static function splitArgs(s:String):Array<String> {
		var out:Array<String> = [];
		var cur = new StringBuf();
		var quoted = false, grouped = false, any = false;
		var i = 0;
		while (i < s.length) {
			var ch = s.charAt(i++);
			if (ch == "\\" && i < s.length && s.charAt(i) == "\"") {
				cur.add(s.charAt(i++));
				any = true;
			} else if (ch == "\"") {
				grouped = !grouped;
				any = true;
			} else if (!grouped && ch == "'") {
				quoted = !quoted;
				cur.add(ch);
				any = true;
			} else if (!quoted && !grouped && (ch == " " || ch == "\t")) {
				if (any) out.push(cur.toString());
				cur = new StringBuf();
				any = false;
			} else {
				cur.add(ch);
				any = true;
			}
		}
		if (any) out.push(cur.toString());
		return out;
	}
}
