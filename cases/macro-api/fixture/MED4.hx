class MED4 {
	static function t(label:String, f:Void->Dynamic) {
		var r = try {
			var v:Dynamic = f();
			"= " + Std.string(v);
		} catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " " + r);
	}

	public static macro function run() {
		sys.io.File.saveContent("fsw_file.txt", "x");
		t("deleteFile missing", () -> { sys.FileSystem.deleteFile("nope.txt"); null; });
		t("deleteFile dir", () -> { sys.FileSystem.createDirectory("fsw_dir"); sys.FileSystem.deleteFile("fsw_dir"); null; });
		t("deleteDirectory missing", () -> { sys.FileSystem.deleteDirectory("nope"); null; });
		t("deleteDirectory file", () -> { sys.FileSystem.deleteDirectory("fsw_file.txt"); null; });
		t("deleteDirectory not empty", () -> { sys.FileSystem.createDirectory("fsw_dir2/sub"); sys.FileSystem.deleteDirectory("fsw_dir2"); null; });
		t("readDirectory missing", () -> sys.FileSystem.readDirectory("nope"));
		t("readDirectory missing slash", () -> sys.FileSystem.readDirectory("nope/"));
		t("readDirectory file", () -> sys.FileSystem.readDirectory("fsw_file.txt"));
		t("readDirectory ok", () -> { var d = sys.FileSystem.readDirectory("fsw_dir2"); d; });
		t("rename missing", () -> { sys.FileSystem.rename("nope.txt", "nope2.txt"); null; });
		t("rename over existing", () -> { sys.io.File.saveContent("fsw_a.txt", "a"); sys.io.File.saveContent("fsw_b.txt", "b"); sys.FileSystem.rename("fsw_a.txt", "fsw_b.txt"); sys.io.File.getContent("fsw_b.txt"); });
		t("rename into missing dir", () -> { sys.FileSystem.rename("fsw_b.txt", "nope/x.txt"); null; });
		t("createDirectory nested", () -> { sys.FileSystem.createDirectory("fsw_c/d/e"); sys.FileSystem.isDirectory("fsw_c/d/e"); });
		t("createDirectory over file", () -> { sys.FileSystem.createDirectory("fsw_file.txt/x"); null; });
		t("createDirectory existing", () -> { sys.FileSystem.createDirectory("fsw_c"); null; });
		t("getContent missing", () -> sys.io.File.getContent("nope.txt"));
		t("read missing", () -> sys.io.File.read("nope.txt"));
		t("read dir", () -> sys.io.File.read("fsw_dir2"));
		t("write missing dir", () -> sys.io.File.write("nope/x.txt"));
		t("write dir", () -> sys.io.File.write("fsw_dir2"));
		t("append missing dir", () -> sys.io.File.append("nope/x.txt"));
		t("update missing", () -> sys.io.File.update("nope/x.txt"));
		t("saveContent missing dir", () -> { sys.io.File.saveContent("nope/x.txt", "x"); null; });
		t("saveBytes missing dir", () -> { sys.io.File.saveBytes("nope/x.txt", haxe.io.Bytes.alloc(1)); null; });
		t("setCwd missing", () -> { Sys.setCwd("nope"); null; });
		t("stat missing", () -> sys.FileSystem.stat("nope"));
		for (f in ["fsw_file.txt", "fsw_b.txt", "fsw_a.txt"]) try sys.FileSystem.deleteFile(f) catch (e:Dynamic) {}
		for (d in ["fsw_dir", "fsw_dir2/sub", "fsw_dir2", "fsw_c/d/e", "fsw_c/d", "fsw_c"]) try sys.FileSystem.deleteDirectory(d) catch (e:Dynamic) {}
		return macro null;
	}
}
