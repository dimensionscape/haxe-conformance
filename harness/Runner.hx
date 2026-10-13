import Family;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Lock;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

enum abstract Status(String) to String {
	var Pass = "pass";
	var Fail = "fail";

	/** Differs, and the divergences file lists it. */
	var Known = "known";

	/** Matches, but the divergences file still lists it. */
	var Stale = "stale";
}

typedef Result = {
	var c:Case;
	var status:Status;
	var got:String;
	var want:String;
	var note:String;
	var seconds:Float;
}

typedef Options = {
	var compiler:String;
	var haxe:Null<String>;
	var std:Null<String>;
	var expectedDir:String;
	var divergences:Map<String, String>;
	var jobs:Int;
	var scratch:String;
	var record:Bool;
	var verbose:Bool;
}

class Runner {
	public static function key(c:Case):String
		return c.family.name + "/" + c.name;

	public static function run(cases:Array<Case>, o:Options):Array<Result> {
		var recordings = new Map<String, Map<String, String>>();
		if (!o.record)
			for (c in cases)
				if ((c.family.oracle : String) == Oracle.Haxe && o.haxe == null && !recordings.exists(c.family.name))
					recordings.set(c.family.name, Expectations.load(o.expectedDir, c.family.name));

		var shared = [for (c in cases) if (!c.family.exclusive) c];
		var alone = [for (c in cases) if (c.family.exclusive) c];
		var results:Array<Result> = [];
		var mutex = new Mutex();
		var next = 0;

		function finish(r:Result) {
			mutex.acquire();
			results.push(r);
			if (o.verbose || r.status == Fail || r.status == Stale)
				Sys.println('  ${(r.status : String).toUpperCase()}  ${key(r.c)}');
			mutex.release();
		}

		function work() {
			while (true) {
				mutex.acquire();
				var c = next < shared.length ? shared[next++] : null;
				mutex.release();
				if (c == null) break;
				finish(runCase(c, o, recordings, mutex));
			}
		}

		var jobs = o.jobs < 1 ? 1 : o.jobs;
		if (jobs == 1) {
			work();
		} else {
			var done = new Lock();
			for (_ in 0...jobs)
				Thread.create(() -> {
					try work() catch (e:Dynamic) Sys.println("worker error: " + Std.string(e));
					done.release();
				});
			for (_ in 0...jobs) done.wait();
		}
		for (c in alone) finish(runCase(c, o, recordings, mutex));
		if (results.length != cases.length) throw 'ran ${results.length} of ${cases.length} cases';

		var order = new Map<String, Int>();
		for (i in 0...cases.length) order.set(key(cases[i]), i);
		results.sort((a, b) -> order.get(key(a.c)) - order.get(key(b.c)));
		return results;
	}

	static function runCase(c:Case, o:Options, recordings:Map<String, Map<String, String>>, mutex:Mutex):Result {
		var t0 = Sys.time();
		var dir = Path.join([o.scratch, c.family.name, safe(c.name)]);
		function once():Result
			return try attempt(c, dir, o, recordings, mutex) catch (e:Dynamic)
				{c: c, status: Fail, got: "", want: "", note: "harness error: " + Std.string(e), seconds: 0};
		var r = once();
		if (r.status == Fail && c.family.recount)
			r = once();
		var reason = o.divergences.get(key(c));
		if (reason != null && !o.record) {
			if (r.status == Fail) {
				r.status = Known;
				r.note = reason;
			} else if (r.status == Pass) {
				r.status = Stale;
				r.note = "matches, but is still listed in the divergences file";
			}
		}
		r.seconds = Sys.time() - t0;
		return r;
	}

	static function attempt(c:Case, dir:String, o:Options, recordings:Map<String, Map<String, String>>, mutex:Mutex):Result {
		prepare(c, dir);
		var f = c.family;
		var got = produce(c, dir, o.compiler, "a", o);
		var want:Null<String> = null;
		switch ((f.oracle : String)) {
			case Oracle.Expected:
				want = normalize(c.expect, dir, o.std);
			case Oracle.Self:
				want = produce(c, dir, o.compiler, "b", o);
			case _:
				if (o.record) {
					mutex.acquire();
					var m = recordings.get(f.name);
					if (m == null) recordings.set(f.name, m = new Map());
					m.set(c.name, got);
					mutex.release();
					want = got;
				} else if (o.haxe != null || f.live.indexOf(c.name) >= 0) {
					want = produce(c, dir, o.haxe != null ? o.haxe : (Exec.isWindows ? "haxe.exe" : "haxe"), "b", o);
				} else {
					var m = recordings.get(f.name);
					want = m != null ? m.get(c.name) : null;
					if (want == null)
						return {c: c, status: Fail, got: got, want: "", note: "no recorded expectation; run `record`", seconds: 0};
				}
		}
		return {c: c, status: got == want ? Pass : Fail, got: got, want: want, note: "", seconds: 0};
	}

	public static function recordings(results:Array<Result>):Map<String, Map<String, String>> {
		var out = new Map<String, Map<String, String>>();
		for (r in results) {
			if ((r.c.family.oracle : String) != Oracle.Haxe || r.c.family.live.indexOf(r.c.name) >= 0) continue;
			var m = out.get(r.c.family.name);
			if (m == null) out.set(r.c.family.name, m = new Map());
			m.set(r.c.name, r.got);
		}
		return out;
	}

	static function prepare(c:Case, dir:String) {
		Exec.removeTree(dir);
		Exec.mkdirs(dir);
		if (c.family.fixture != null) Exec.copyTree(c.family.fixture, dir);
		var parts = c.module.split(".");
		var file = parts.pop() + ".hx";
		var target = dir;
		for (p in parts) target = Path.join([target, p]);
		Exec.mkdirs(target);
		File.saveContent(Path.join([target, file]), c.source + "\n");
	}

	/** One compiler's result for a case: messages, program output or generated file, by kind. */
	static function produce(c:Case, dir:String, exe:String, tag:String, o:Options):String {
		var f = c.family;
		var out = Path.join([dir, "out.js"]);
		if (FileSystem.exists(out)) FileSystem.deleteFile(out);
		var args = (f.chdir ? [] : ["--cwd", dir]).concat([for (a in f.args.concat(c.args)) subst(a, c, dir, out)]);
		var env = new Map<String, String>();
		if (o.std != null) env.set("HAXE_STD_PATH", o.std);
		var r = Exec.run(exe, args, env, f.chdir ? dir : null);
		if (r.timedOut) return "<timed out after " + Exec.timeout + "s>";
		var said = normalize(r.output, dir, o.std);
		switch ((f.kind : String)) {
			case Kind.CompileDiff:
				return said;
			case Kind.Run:
				if (!Lambda.has(f.args, "$out")) return said;
				if (!FileSystem.exists(out)) return "<compile failed>\n" + said;
				var run = Exec.run("node", [out], env);
				FileSystem.deleteFile(out);
				return run.timedOut ? "<timed out after " + Exec.timeout + "s>" : normalize(run.output, dir, o.std);
			case _:
				if (!FileSystem.exists(out)) return "<nothing generated>\n" + said;
				var text = normalize(File.getContent(out), dir, o.std);
				FileSystem.deleteFile(out);
				return text;
		}
	}

	static function subst(a:String, c:Case, dir:String, out:String):String {
		if (a == "$module") return c.module;
		if (a == "$out") return out;
		if (a.indexOf("$FILEJSON") >= 0) return a.replace("$FILEJSON", caseFile(c, dir).split("\\").join("\\\\"));
		if (a.indexOf("$FILE") >= 0) return a.replace("$FILE", caseFile(c, dir));
		return a;
	}

	static function caseFile(c:Case, dir:String):String {
		var parts = c.module.split(".");
		var file = parts.pop() + ".hx";
		return FileSystem.fullPath(Path.join([dir].concat(parts).concat([file])));
	}

	static function safe(name:String):String
		return ~/[^A-Za-z0-9_.-]/g.replace(name, "_");

	/** Line endings, the display timestamp, and the machine-specific case and std paths. */
	public static function normalize(s:String, dir:String, std:Null<String>):String {
		s = s.replace("\r\n", "\n").replace("\r", "");
		s = ~/"timestamp":[0-9.eE+-]+/g.replace(s, '"timestamp":0');
		s = replacePath(s, FileSystem.fullPath(dir), "$CASE");
		if (std != null) s = replacePath(s, FileSystem.fullPath(std), "$STD");
		return s.trim();
	}

	static function replacePath(s:String, path:String, token:String):String {
		var p = Path.removeTrailingSlashes(path.replace("\\", "/"));
		for (v in [p, p.replace("/", "\\"), p.replace("/", "\\\\")]) {
			var rx = new EReg(escape(v), Exec.isWindows ? "gi" : "g");
			s = rx.map(s, _ -> token);
		}
		return s;
	}

	static function escape(s:String):String
		return ~/([.*+?^${}()|\[\]\\\/])/g.replace(s, "\\$1");
}
