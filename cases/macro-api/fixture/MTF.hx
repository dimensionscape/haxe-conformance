private class MtfErr extends haxe.Exception {
	public function new(m:String) {
		super(m);
	}
}
private class MtfDeep extends MtfErr {
	public var code:Int = 7;
	public function new(m:String, early:Bool) {
		if (early) {
			super("early " + m);
			return;
		}
		super(m);
	}
}
@:native("renamed.MtfThing")
class MtfThing {
	public var a:Int = 1;
	public var b:String = "two";
	public function new() {}
}
class MtfPlain {
	public var list:Array<Int> = [1, 2];
	public var n = 3;
}
class MTF {
	static function frames(e:haxe.Exception):String {
		return [for (s in e.stack) switch (s) { case FilePos(_, f, l, _): f + ":" + l; case _: "?"; }].join(" ");
	}
	public static macro function run() {
		var e1 = new MtfErr("m1");
		Sys.println("MtfErr " + e1.message + " frames=" + frames(e1));
		var e2 = new MtfDeep("m2", false);
		Sys.println("MtfDeep " + e2.message + " code=" + e2.code + " frames=" + frames(e2));
		var e3 = new MtfDeep("m3", true);
		Sys.println("MtfDeep early " + e3.message + " frames=" + frames(e3));
		try throw new MtfErr("thrown") catch (e:MtfErr) Sys.println("caught " + e.message + " frames=" + frames(e));
		var t = new MtfThing();
		Sys.println("Thing " + Type.getClassName(Type.getClass(t)) + " " + t.a + " " + t.b + " resolve=" + (Type.resolveClass("renamed.MtfThing") != null) + " old=" + (Type.resolveClass("MtfThing") != null));
		var p = Type.createInstance(MtfPlain, []);
		Sys.println("Plain " + p.list + " " + p.n + " fields=" + Type.getInstanceFields(MtfPlain));
		return macro null;
	}
}
