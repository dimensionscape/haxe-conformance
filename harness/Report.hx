import Runner;
import sys.io.File;

using StringTools;

class Report {
	public static function print(results:Array<Result>, seconds:Float) {
		var families:Array<String> = [];
		var byFamily = new Map<String, Array<Result>>();
		for (r in results) {
			var n = r.c.family.name;
			if (!byFamily.exists(n)) {
				byFamily.set(n, []);
				families.push(n);
			}
			byFamily.get(n).push(r);
		}
		Sys.println("");
		for (n in families) {
			var rs = byFamily.get(n);
			var c = counts(rs);
			var tag = c.fail + c.stale > 0 ? "FAIL" : "PASS";
			var extra = c.known > 0 ? '  (${c.known} known)' : "";
			Sys.println('  $tag  $n  ${c.pass + c.known}/${rs.length}$extra');
		}

		var bad = [for (r in results) if (r.status == Fail || r.status == Stale) r];
		if (bad.length > 0) {
			Sys.println("");
			Sys.println("failures:");
			for (r in bad) {
				Sys.println('  ${Runner.key(r.c)}' + (r.note != "" ? '  (${r.note})' : ""));
				if (r.status == Fail) {
					Sys.println('    source: ' + firstLine(r.c.source));
					for (l in diff(r.got, r.want).split("\n")) Sys.println("    " + l);
				}
			}
		}
		var known = [for (r in results) if (r.status == Known) r];
		if (known.length > 0) {
			Sys.println("");
			Sys.println("known divergences:");
			for (r in known) Sys.println('  ${Runner.key(r.c)}  -  ${r.note}');
		}
		var c = counts(results);
		Sys.println("");
		var line = '${results.length} checked, ${c.fail} failed';
		if (c.stale > 0) line += ', ${c.stale} stale divergences';
		if (c.known > 0) line += ', ${c.known} known';
		Sys.println(line + '  (${Math.round(seconds)}s)');
		Sys.println(c.fail + c.stale == 0 ? "RESULT: PASS" : "RESULT: FAIL");
	}

	public static function failed(results:Array<Result>):Bool {
		var c = counts(results);
		return c.fail + c.stale > 0;
	}

	static function counts(rs:Array<Result>) {
		var c = {pass: 0, fail: 0, known: 0, stale: 0};
		for (r in rs)
			switch (r.status) {
				case Pass: c.pass++;
				case Fail: c.fail++;
				case Known: c.known++;
				case Stale: c.stale++;
			}
		return c;
	}

	/** The first differing line with a few lines of context, then the line counts. */
	public static function diff(got:String, want:String):String {
		var a = got.split("\n"), b = want.split("\n");
		var i = 0;
		while (i < a.length && i < b.length && a[i] == b[i]) i++;
		var col = 0;
		if (i < a.length && i < b.length)
			while (col < a[i].length && col < b[i].length && a[i].charCodeAt(col) == b[i].charCodeAt(col)) col++;
		// A difference past the shown part of a long line is shown from a little before it.
		var from = col > 100 ? col - 60 : 0;
		var out = [from > 0 ? 'first difference at line ${i + 1}, column ${col + 1}:' : 'first difference at line ${i + 1}:'];
		for (k in i...Std.int(Math.min(i + 6, a.length))) out.push("  got:  " + clip(a[k], from));
		for (k in i...Std.int(Math.min(i + 6, b.length))) out.push("  want: " + clip(b[k], from));
		out.push('(${a.length} lines got, ${b.length} lines wanted)');
		return out.join("\n");
	}

	static function clip(s:String, from = 0):String {
		if (from > 0 && s.length > from) s = "..." + s.substr(from);
		return s.length > 160 ? s.substr(0, 157) + "..." : s;
	}

	static function firstLine(s:String):String {
		var i = s.indexOf("\n");
		return clip(i < 0 ? s : s.substr(0, i) + " ...");
	}

	public static function junit(path:String, suiteName:String, results:Array<Result>) {
		var b = new StringBuf();
		var c = counts(results);
		b.add('<?xml version="1.0" encoding="UTF-8"?>\n');
		b.add('<testsuites name="${xml(suiteName)}" tests="${results.length}" failures="${c.fail + c.stale}">\n');
		var families:Array<String> = [];
		var byFamily = new Map<String, Array<Result>>();
		for (r in results) {
			var n = r.c.family.name;
			if (!byFamily.exists(n)) {
				byFamily.set(n, []);
				families.push(n);
			}
			byFamily.get(n).push(r);
		}
		for (n in families) {
			var rs = byFamily.get(n);
			var fc = counts(rs);
			b.add('  <testsuite name="${xml(n)}" tests="${rs.length}" failures="${fc.fail + fc.stale}" skipped="${fc.known}">\n');
			for (r in rs) {
				b.add('    <testcase classname="${xml(n)}" name="${xml(r.c.name)}" time="${Math.round(r.seconds * 1000) / 1000}"');
				switch (r.status) {
					case Pass:
						b.add("/>\n");
					case Known:
						b.add('>\n      <skipped message="${xml(r.note)}"/>\n    </testcase>\n');
					case Stale:
						b.add('>\n      <failure message="${xml(r.note)}"/>\n    </testcase>\n');
					case Fail:
						b.add('>\n      <failure message="${xml(r.note != "" ? r.note : "output differs")}">${xml(diff(r.got, r.want))}</failure>\n    </testcase>\n');
				}
			}
			b.add("  </testsuite>\n");
		}
		b.add("</testsuites>\n");
		File.saveContent(path, b.toString());
	}

	/** Appends a short markdown summary when running under GitHub Actions. */
	public static function stepSummary(title:String, results:Array<Result>, seconds:Float) {
		var path = Sys.getEnv("GITHUB_STEP_SUMMARY");
		if (path == null || path == "") return;
		var c = counts(results);
		var b = new StringBuf();
		b.add('### $title: ' + (c.fail + c.stale == 0 ? "pass" : "FAIL") + "\n\n");
		b.add('${results.length} checked, ${c.fail} failed, ${c.known} known, ${c.stale} stale  (${Math.round(seconds)}s)\n\n');
		var bad = [for (r in results) if (r.status == Fail || r.status == Stale) r];
		if (bad.length > 0) {
			b.add("| case | note |\n|---|---|\n");
			for (r in bad.slice(0, 50)) b.add('| `${Runner.key(r.c)}` | ${r.note != "" ? r.note : "output differs"} |\n');
			if (bad.length > 50) b.add('\n${bad.length - 50} more\n');
		}
		b.add("\n");
		var prev = try File.getContent(path) catch (_:Dynamic) "";
		File.saveContent(path, prev + b.toString());
	}

	static function xml(s:String):String {
		var b = new StringBuf();
		for (i in 0...s.length) {
			var ch = s.charCodeAt(i);
			switch (ch) {
				case "&".code: b.add("&amp;");
				case "<".code: b.add("&lt;");
				case ">".code: b.add("&gt;");
				case "\"".code: b.add("&quot;");
				case 9 | 10 | 13: b.addChar(ch);
				case c if (c < 32): b.add("?");
				case c: b.addChar(c);
			}
		}
		return b.toString();
	}
}
