import eval.luv.*;
#if macro
import eval.luv.File;
import eval.luv.Dir;
import eval.integers.Int64;
import eval.integers.UInt64;
#end

class MLUVD {
	static function t(label:String, f:Void->Dynamic) {
		var r = try Std.string(f()) catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " => " + r);
	}

#if macro
	static function res<T>(r:Result<T>):String {
		return switch (r) {
			case Ok(v): "Ok(" + Std.string(v) + ")";
			case Error(e): "Error(" + e + " " + e.errName() + ")";
		}
	}

	static function ok<T>(r:Result<T>):T {
		return switch (r) {
			case Ok(v): v;
			case Error(e): throw "unexpected " + e;
		}
	}

	static function stat(s:FileStat):String {
		return "size=" + s.size.toString() + " reg=" + File.testMode([IFREG], s.mode) + " dir=" + File.testMode([IFDIR], s.mode)
			+ " w=" + File.testMode([IWUSR], s.mode) + " nlink=" + s.nlink.toString();
	}

	static function scratch(name:String):String {
		var dir = Sys.getCwd() + "mluvd_" + name + "_" + Std.random(1000000);
		sys.FileSystem.createDirectory(dir);
		return dir;
	}

	static function remove(dir:String) {
		for (f in sys.FileSystem.readDirectory(dir))
			try sys.FileSystem.deleteFile(dir + "/" + f) catch (_:Dynamic) try sys.FileSystem.deleteDirectory(dir + "/" + f) catch (_:Dynamic) {}
		try sys.FileSystem.deleteDirectory(dir) catch (_:Dynamic) {}
	}
#end

	public static macro function sync() {
		var dir = scratch("sync");
		var p = dir + "/a.txt";
		var f = ok(FileSync.open(p, [CREAT, WRONLY, TRUNC]));
		t("write", () -> res(FileSync.write(f, Int64.ofInt(-1), [Buffer.fromString("hello "), Buffer.fromString("world")])));
		t("fsync", () -> res(FileSync.fsync(f)) + " " + res(FileSync.fdataSync(f)));
		t("fstat", () -> stat(ok(FileSync.fstat(f))));
		t("ftruncate", () -> res(FileSync.ftruncate(f, Int64.ofInt(5))) + " " + stat(ok(FileSync.fstat(f))));
		t("close", () -> res(FileSync.close(f)) + " " + res(FileSync.close(f)));
		var g = ok(FileSync.open(p, [RDONLY]));
		var b = Buffer.create(3);
		var c = Buffer.create(10);
		t("read", () -> res(FileSync.read(g, Int64.ofInt(0), [b, c])) + " " + b.toString() + "|" + c.sub(0, 2).toString());
		t("read eof", () -> res(FileSync.read(g, Int64.ofInt(100), [c])) + " " + res(FileSync.write(g, Int64.ofInt(0), [b])));
		t("stat", () -> stat(ok(FileSync.stat(p))) + " / " + stat(ok(FileSync.lstat(p))) + " / " + res(FileSync.stat(dir + "/nope")));
		t("modes", () -> [for (m in [IRWXU, IRUSR, IWUSR, IXUSR, IRWXG, IRGRP, IWGRP, IXGRP, IRWXO, IROTH, IWOTH, IXOTH, ISUID, ISGID, ISVTX, IFMT, IFREG, IFDIR, IFBLK, IFCHR, IFLNK, IFIFO])
			File.testMode([m], ok(FileSync.stat(p)).mode) ? "1" : "0"].join("") + " " + [for (i in 0...20) File.testMode([NUMERIC(1 << i)], ok(FileSync.stat(dir)).mode) ? "1" : "0"].join(""));
		t("statfs", () -> ok(FileSync.statFs(p)).fspare.length);
		t("access", () -> res(FileSync.access(p, [F_OK])) + " " + res(FileSync.access(p, [R_OK, W_OK])) + " " + res(FileSync.access(dir + "/nope", [F_OK])));
		t("sendFile", () -> {
			var h = ok(FileSync.open(dir + "/b.txt", [CREAT, WRONLY]));
			var r = res(FileSync.sendFile(g, h, Int64.ofInt(1), UInt64.ofInt(3)));
			FileSync.close(h);
			r + " " + sys.io.File.getContent(dir + "/b.txt");
		});
		FileSync.close(g);
		t("copyFile", () -> res(FileSync.copyFile(p, dir + "/c.txt")) + " " + res(FileSync.copyFile(p, dir + "/c.txt", [COPYFILE_EXCL])));
		t("rename", () -> res(FileSync.rename(dir + "/c.txt", dir + "/d.txt")) + " " + sys.FileSystem.exists(dir + "/d.txt"));
		t("link", () -> res(FileSync.link(dir + "/d.txt", dir + "/e.txt")) + " " + stat(ok(FileSync.stat(dir + "/e.txt"))));
		t("readLink", () -> res(FileSync.readLink(dir + "/d.txt")));
		t("chmod", () -> res(FileSync.chmod(dir + "/d.txt", [IRUSR])) + " " + stat(ok(FileSync.stat(dir + "/d.txt"))) + " " + res(FileSync.chmod(dir + "/d.txt", [NUMERIC(438)])));
		t("utime", () -> res(FileSync.utime(dir + "/d.txt", 1000000000.5, 1500000000)) + " " + ok(FileSync.stat(dir + "/d.txt")).mtim.sec.toString());
		t("mkdir", () -> res(FileSync.mkdir(dir + "/sub")) + " " + res(FileSync.mkdir(dir + "/sub")) + " " + res(FileSync.rmdir(dir + "/sub")) + " " + res(FileSync.rmdir(dir + "/sub")));
		t("mkdtemp", () -> switch (FileSync.mkdtemp(dir + "/tmpXXXXXX")) { case Ok(s): var n = s.toString(); FileSync.rmdir(n); Std.string(StringTools.startsWith(n, dir + "/tmp")); case Error(e): "Error " + e; });
		t("mkstemp", () -> switch (FileSync.mkstemp(dir + "/tmpXXXXXX")) { case Ok(o): var r = o.file.toInt() > 2; FileSync.close(o.file); FileSync.unlink(o.name); Std.string(r); case Error(e): "Error " + e; });
		t("unlink", () -> res(FileSync.unlink(dir + "/e.txt")) + " " + res(FileSync.unlink(dir + "/e.txt")));
		t("std", () -> File.stdin.toInt() + " " + File.stdout.toInt() + " " + File.stderr.toInt());
		remove(dir);
		return macro null;
	}

	public static macro function async() {
		var loop = Loop.defaultLoop();
		var dir = scratch("async");
		var p = dir + "/a.txt";
		var log = [];
		var steps:Array<(Void->Void)->Void> = [];
		function next() if (steps.length > 0) steps.shift()(next);
		var f:File = null;
		var b = Buffer.create(4);
		steps.push(k -> File.open(loop, p, [CREAT, RDWR], [NUMERIC(420)], null, r -> { f = ok(r); log.push("opened"); k(); }));
		steps.push(k -> f.write(loop, Int64.ofInt(0), [Buffer.fromString("abcdef")], null, r -> { log.push("wrote " + res(r)); k(); }));
		steps.push(k -> f.read(loop, Int64.ofInt(1), [b], null, r -> { log.push("read " + res(r) + " " + b.toString()); k(); }));
		steps.push(k -> f.fstat(loop, null, r -> { log.push("fstat " + stat(ok(r))); k(); }));
		steps.push(k -> f.ftruncate(loop, Int64.ofInt(2), null, r -> { log.push("ftruncate " + res(r)); k(); }));
		steps.push(k -> f.close(loop, null, r -> { log.push("closed " + res(r)); k(); }));
		steps.push(k -> f.close(loop, null, r -> { log.push("closed again " + res(r)); k(); }));
		steps.push(k -> File.copyFile(loop, p, dir + "/c.txt", [COPYFILE_EXCL], null, r -> { log.push("copyFile " + res(r)); k(); }));
		steps.push(k -> File.copyFile(loop, p, dir + "/c.txt", [COPYFILE_EXCL], null, r -> { log.push("copyFile excl " + res(r)); k(); }));
		steps.push(k -> File.utime(loop, p, 1000, 2000, null, r -> { log.push("utime " + res(r)); k(); }));
		steps.push(k -> File.stat(loop, p, File.createRequest(), r -> { var s = ok(r); log.push("stat " + stat(s) + " " + s.mtim.sec.toString()); k(); }));
		steps.push(k -> File.rename(loop, p, dir + "/r.txt", null, r -> { log.push("rename " + res(r)); k(); }));
		steps.push(k -> File.unlink(loop, dir + "/r.txt", null, r -> { log.push("unlink " + res(r)); k(); }));
		steps.push(k -> File.unlink(loop, dir + "/r.txt", null, r -> { log.push("unlink again " + res(r)); k(); }));
		steps.push(k -> File.open(loop, dir + "/nope/x", [RDONLY], null, null, r -> { log.push("open missing " + res(r)); k(); }));
		steps.push(k -> File.mkdir(loop, dir + "/m", null, null, r -> { log.push("mkdir " + res(r)); k(); }));
		steps.push(k -> File.rmdir(loop, dir + "/m", null, r -> { log.push("rmdir " + res(r)); k(); }));
		steps.push(k -> File.access(loop, dir, [F_OK, R_OK], null, r -> { log.push("access " + res(r)); k(); }));
		steps.push(k -> File.realPath(loop, dir + "/nope", null, r -> { log.push("realPath missing " + res(r)); k(); }));
		next();
		t("run", () -> loop.run(DEFAULT));
		Sys.println(log.join(" | "));
		remove(dir);
		return macro null;
	}

	public static macro function dirs() {
		var loop = Loop.defaultLoop();
		var dir = scratch("dir");
		sys.io.File.saveContent(dir + "/x.txt", "x");
		sys.io.File.saveContent(dir + "/y.txt", "y");
		sys.FileSystem.createDirectory(dir + "/z");
		var d = ok(DirSync.open(dir));
		t("read", () -> switch (DirSync.read(d)) { case Ok(a): var s = [for (e in a) e.name.toString() + ":" + e.kind]; s.sort(Reflect.compare); s.join(","); case Error(e): "Error " + e; });
		t("read again", () -> switch (DirSync.read(d, 1)) { case Ok(a): Std.string(a.length); case Error(e): "Error " + e; });
		t("close", () -> res(DirSync.close(d)));
		t("open missing", () -> res(DirSync.open(dir + "/nope")) + " " + res(DirSync.scan(dir + "/nope")));
		var sc = ok(DirSync.scan(dir));
		var names = [];
		var e;
		while ((e = sc.next()) != null) names.push(e.name.toString() + ":" + e.kind);
		names.sort(Reflect.compare);
		t("scan", () -> names.join(",") + " " + sc.next());
		sc.end();
		Dir.open(loop, dir + "/nope", null, r -> {
			Sys.println("async open missing " + res(r));
			Dir.open(loop, dir, null, r -> {
				var dd = ok(r);
				dd.read(loop, 2, null, r -> {
					Sys.println("async read " + (switch (r) { case Ok(a): Std.string(a.length); case Error(e): "Error " + e; }));
					dd.close(loop, null, r -> {
						Sys.println("async close " + res(r));
						Dir.scan(loop, dir, null, r -> {
							var s = ok(r);
							var n = [];
							var e;
							while ((e = s.next()) != null) n.push(e.name.toString());
							n.sort(Reflect.compare);
							Sys.println("async scan " + n.join(","));
						});
					});
				});
			});
		});
		t("run", () -> loop.run(DEFAULT));
		remove(dir);
		return macro null;
	}

	public static macro function poll() {
		var loop = Loop.defaultLoop();
		var dir = scratch("poll");
		var p = dir + "/a.txt";
		sys.io.File.saveContent(p, "1");
		var fp = ok(FsPoll.init(loop));
		fp.start(p, 50, r -> {
			switch (r) {
				case Ok(o): Sys.println("poll " + o.previous.size.toString() + " -> " + o.current.size.toString());
				case Error(e): Sys.println("poll error " + e);
			}
			Sys.println("stop " + res(fp.stop()));
			fp.close(() -> Sys.println("closed"));
			var fp2 = ok(FsPoll.init(loop));
			fp2.start(dir + "/nope", null, r -> {
				Sys.println("missing " + res(r));
				fp2.stop();
				fp2.close(() -> Sys.println("closed2"));
			});
		});
		var tm = ok(Timer.init(loop));
		tm.start(() -> {
			sys.io.File.saveContent(p, "12345");
			tm.close(() -> {});
		}, 200);
		t("run", () -> loop.run(DEFAULT));
		remove(dir);
		return macro null;
	}

	public static macro function errors() {
		var loop = Loop.defaultLoop();
		t("open badflag", () -> FileSync.open("x", [cast 21]));
		t("open badmode", () -> FileSync.open("x", [CREAT], [cast 1]));
		t("open badpath", () -> FileSync.open(cast 1, [RDONLY]));
		t("close badfile", () -> FileSync.close(cast 1));
		t("read badoffset", () -> FileSync.read(File.stdin, cast 1, []));
		t("access badflag", () -> FileSync.access("x", [cast 4]));
		t("utime badnum", () -> FileSync.utime("x", cast "x", 1));
		t("sendFile badlength", () -> FileSync.sendFile(File.stdin, File.stdout, Int64.ofInt(0), cast 1));
		t("testMode bad", () -> File.testMode([IFREG], cast 1));
		t("dir bad", () -> DirSync.close(cast 1));
		t("async badloop", () -> { File.stat(cast 1, "x", null, r -> {}); "ret"; });
		t("async badrequest", () -> { File.stat(loop, "x", cast 1, r -> {}); "ret"; });
		t("cancel fresh", () -> res(File.createRequest().cancel()));
		t("tty", () -> res(Tty.init(loop, File.stdin)).substr(0, 5) + " " + res(Tty.resetMode()));
		t("tty bad", () -> { Tty.setVTermState(cast 5); "ret"; });
		return macro null;
	}
}
