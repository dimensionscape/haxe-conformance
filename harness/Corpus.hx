import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/** Haxe's own test suites under tests/, run the way tests/runci/targets/Macro.hx runs them. **/
class Corpus {
	static final all = ["unit", "misc", "resolution", "sourcemaps", "nullsafety", "sys", "threads"];

	public static function run(suites:Array<String>, compiler:Null<String>, std:Null<String>, testsDir:String,
			junit:Null<String>):Int {
		if (compiler == null) throw "--compiler is required";
		if (!FileSystem.exists(compiler)) throw 'compiler not found: $compiler';
		if (suites.length == 0) suites = all;
		for (s in suites)
			if (all.indexOf(s) < 0 && s != "display") throw 'unknown suite "$s"';

		var shim = Path.join([Exec.tempRoot(), "haxe-conformance-shim-" + Std.random(0x7FFFFFF)]);
		Exec.mkdirs(shim);
		var exe = Path.join([shim, Exec.isWindows ? "haxe.exe" : "haxe"]);
		File.copy(compiler, exe);
		if (!Exec.isWindows) Sys.command("chmod", ["+x", exe]);
		Sys.putEnv("PATH", shim + (Exec.isWindows ? ";" : ":") + Sys.getEnv("PATH"));
		if (std != null) Sys.putEnv("HAXE_STD_PATH", std);

		var system = ["-D", Sys.systemName()];
		var steps:Array<{name:String, dir:String, args:Array<String>}> = [];
		for (s in suites)
			switch (s) {
				case "unit": steps.push({name: "unit", dir: "unit", args: ["compile-macro.hxml"].concat(system)});
				case "misc": steps.push({name: "misc", dir: "misc", args: ["compile.hxml"]});
				case "resolution": steps.push({name: "resolution", dir: "misc/resolution", args: ["run.hxml"]});
				case "sourcemaps": steps.push({name: "sourcemaps", dir: "sourcemaps", args: ["run.hxml"]});
				case "nullsafety":
					steps.push({name: "nullsafety", dir: "nullsafety", args: ["test.hxml"]});
					steps.push({name: "nullsafety-js-es6", dir: "nullsafety", args: ["test-js-es6.hxml"]});
				case "sys":
					Sys.putEnv("EXISTS", "1");
					steps.push({name: "sys", dir: "sys", args: ["compile-macro.hxml"].concat(system)});
				case "threads": steps.push({name: "threads", dir: "threads", args: ["build.hxml", "--interp"]});
				case "display": steps.push({name: "display", dir: "display", args: ["build.hxml"]});
			}

		var results:Array<{name:String, ok:Bool, seconds:Float}> = [];
		var home = Sys.getCwd();
		for (step in steps) {
			Sys.println('=== ${step.name}: haxe ${step.args.join(" ")}  (tests/${step.dir})');
			Sys.setCwd(Path.join([testsDir, step.dir]));
			var t0 = Sys.time();
			var code = try Sys.command("haxe", step.args) catch (e:Dynamic) {
				Sys.println(Std.string(e));
				1;
			}
			Sys.setCwd(home);
			results.push({name: step.name, ok: code == 0, seconds: Sys.time() - t0});
			Sys.println('=== ${step.name}: ' + (code == 0 ? "PASS" : 'FAIL (exit $code)'));
			Sys.println("");
		}
		try Exec.removeTree(shim) catch (_:Dynamic) {}

		var failures = 0;
		for (r in results) {
			Sys.println('  ' + (r.ok ? "PASS" : "FAIL") + '  ${r.name}  (${Math.round(r.seconds)}s)');
			if (!r.ok) failures++;
		}
		Sys.println(failures == 0 ? "RESULT: PASS" : "RESULT: FAIL");
		if (junit != null) {
			var b = new StringBuf();
			b.add('<?xml version="1.0" encoding="UTF-8"?>\n<testsuites name="corpus" tests="${results.length}" failures="$failures">\n');
			b.add('  <testsuite name="corpus" tests="${results.length}" failures="$failures">\n');
			for (r in results) {
				b.add('    <testcase classname="corpus" name="${r.name}" time="${Math.round(r.seconds)}"');
				b.add(r.ok ? "/>\n" : '>\n      <failure message="suite failed"/>\n    </testcase>\n');
			}
			b.add("  </testsuite>\n</testsuites>\n");
			File.saveContent(junit, b.toString());
		}
		return failures == 0 ? 0 : 1;
	}
}
