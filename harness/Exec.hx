import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

typedef ExecResult = {
	var output:String;
	var timedOut:Bool;
}

typedef Watch = {
	var pid:Int;
	var deadline:Float;
	var expired:Bool;
}

/**
	Runs one command through a generated shell script that redirects stdout and stderr to files and
	reads stdin from the null device, so no pipe can fill up. A watchdog thread kills any command that
	outlives the timeout.
**/
class Exec {
	public static var timeout:Float = 120;
	static var counter = 0;
	static var lock = new sys.thread.Mutex();
	static var watches:Array<Watch> = [];
	static var watchdog:Null<sys.thread.Thread> = null;

	public static var isWindows(get, never):Bool;

	static function get_isWindows():Bool
		return Sys.systemName() == "Windows";

	static var root:Null<String> = null;

	public static function tempRoot():String {
		if (root == null) {
			var v = Sys.getEnv(isWindows ? "TEMP" : "TMPDIR");
			root = longPath(v != null && v != "" ? v : (isWindows ? "C:/Windows/Temp" : "/tmp"));
		}
		return root;
	}

	/** The directory with any 8.3 short names spelled out, the way compilers report it. */
	static function longPath(dir:String):String {
		if (!isWindows || dir.indexOf("~") < 0 || !FileSystem.isDirectory(dir)) return dir;
		var marker = "haxe-conformance-" + Std.random(0x7FFFFFF);
		File.saveContent(Path.join([dir, marker]), "");
		var parts = Path.normalize(dir).split("/");
		var resolved = parts[0];
		for (i in 1...parts.length) {
			var part = parts[i];
			if (part.indexOf("~") >= 0) {
				var rest = parts.slice(i + 1).concat([marker]).join("/");
				for (entry in FileSystem.readDirectory(resolved + "/"))
					if (FileSystem.exists('$resolved/$entry/$rest')) {
						part = entry;
						break;
					}
			}
			resolved += "/" + part;
		}
		FileSystem.deleteFile(Path.join([dir, marker]));
		return resolved;
	}

	public static function run(exe:String, args:Array<String>, env:Map<String, String>, ?cwd:String):ExecResult {
		lock.acquire();
		var tag = Std.string(Std.random(0x7FFFFFF)) + "-" + Std.string(counter++);
		lock.release();
		var dir = Path.join([tempRoot(), "haxe-conformance-io"]);
		mkdirs(dir);
		var outPath = Path.join([dir, tag + ".out"]);
		var errPath = Path.join([dir, tag + ".err"]);
		var script = Path.join([dir, tag + (isWindows ? ".bat" : ".sh")]);
		var files = [outPath, errPath, script];

		var lines:Array<String> = [];
		if (isWindows) {
			lines.push("@echo off");
			for (k => v in env) lines.push('set "$k=$v"');
			if (cwd != null) lines.push("cd /d " + q(native(cwd)));
			lines.push(q(native(exe)) + " " + [for (a in args) q(a)].join(" ") + " > " + q(native(outPath)) + " 2> "
				+ q(native(errPath)) + " < NUL");
			File.saveContent(script, lines.join("
") + "
");
		} else {
			lines.push("#!/bin/sh");
			for (k => v in env) lines.push("export " + k + "=" + sq(v));
			if (cwd != null) lines.push("cd " + sq(cwd));
			lines.push("exec " + sq(exe) + " " + [for (a in args) sq(a)].join(" ") + " > " + sq(outPath) + " 2> " + sq(errPath) + " < /dev/null");
			File.saveContent(script, lines.join("
") + "
");
		}

		var w:Watch = {pid: 0, deadline: Sys.time() + timeout, expired: false};
		// A process killed by a signal has no exit code; what it printed before is kept.
		var killed:Null<String> = null;
		try {
			var p = isWindows ? new Process("cmd", ["/c", native(script)]) : new Process("sh", [script]);
			w.pid = p.getPid();
			watching(w, true);
			try p.exitCode() catch (e:Dynamic) killed = Std.string(e);
			watching(w, false);
			p.close();
		} catch (e:Dynamic) {
			watching(w, false);
			cleanup(files);
			return {output: "<could not start: " + Std.string(e) + ">", timedOut: false};
		}
		var o = try File.getContent(outPath) catch (_:Dynamic) "";
		var e = try File.getContent(errPath) catch (_:Dynamic) "";
		cleanup(files);
		return {output: o + e + (killed != null ? "<" + killed + ">" : ""), timedOut: w.expired};
	}

	static function watching(w:Watch, on:Bool) {
		lock.acquire();
		if (on) {
			watches.push(w);
			if (watchdog == null) watchdog = sys.thread.Thread.create(patrol);
		} else {
			watches.remove(w);
		}
		lock.release();
	}

	static function patrol() {
		while (true) {
			Sys.sleep(0.25);
			var now = Sys.time();
			lock.acquire();
			var overdue = [for (w in watches) if (!w.expired && now > w.deadline) w];
			for (w in overdue) w.expired = true;
			lock.release();
			for (w in overdue)
				if (isWindows) Sys.command("taskkill /T /F /PID " + w.pid + " > NUL 2>&1"); else Sys.command("kill -9 " + w.pid + " 2>/dev/null");
		}
	}

	static function cleanup(files:Array<String>) {
		for (f in files) try FileSystem.deleteFile(f) catch (_:Dynamic) {}
	}

	static function q(s:String):String
		return '"' + s.replace('"', '\\"') + '"';

	static function sq(s:String):String
		return "'" + s.split("'").join("'\\''") + "'";

	public static function native(s:String):String
		return isWindows ? s.replace("/", "\\") : s;

	public static function mkdirs(dir:String) {
		if (dir == "" || FileSystem.exists(dir)) return;
		mkdirs(Path.directory(dir));
		try FileSystem.createDirectory(dir) catch (e:Dynamic) if (!FileSystem.exists(dir)) throw e;
	}

	public static function removeTree(dir:String) {
		if (!FileSystem.exists(dir)) return;
		for (entry in FileSystem.readDirectory(dir)) {
			var p = Path.join([dir, entry]);
			if (FileSystem.isDirectory(p)) removeTree(p); else FileSystem.deleteFile(p);
		}
		FileSystem.deleteDirectory(dir);
	}

	public static function copyTree(from:String, to:String) {
		mkdirs(to);
		for (entry in FileSystem.readDirectory(from)) {
			var src = Path.join([from, entry]);
			var dst = Path.join([to, entry]);
			if (FileSystem.isDirectory(src)) copyTree(src, dst); else File.copy(src, dst);
		}
	}
}
