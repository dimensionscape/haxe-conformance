import haxe.macro.Context;

class Holder { public var alpha:Int = 1; public var beta:String = "x"; public var gamma:Bool = true; public var delta:Float = 2.5; public function new() {} }

class MI {
	static function p(v:Dynamic) Sys.println(Std.string(v));
	public static macro function sInt() { p(Context.signature(1)); return macro null; }
	public static macro function sStr() { p(Context.signature("abc")); return macro null; }
	public static macro function sObj() { p(Context.signature({a: 1, b: "x"})); return macro null; }
	public static macro function sArr() { p(Context.signature([1, 2, 3])); return macro null; }
	public static macro function sFun() { p(Context.signature(function() return 1)); return macro null; }
	public static macro function sTypeInt() { p(Context.signature(Context.getType("Int"))); return macro null; }
	public static macro function sTypeString() { p(Context.signature(Context.getType("String"))); return macro null; }
	public static macro function sTypeArray() { p(Context.signature(Context.getType("Array"))); return macro null; }
	public static macro function sRefOnly() { var t = Context.getType("String"); p(Context.signature(switch (t) { case TInst(c, _): c; case _: null; })); return macro null; }
	public static macro function sAnon() { p(Context.signature(Context.typeof(macro {a: 1}))); return macro null; }
	public static macro function sExpr() { p(Context.signature(macro 1 + 1)); return macro null; }
	public static macro function sSameTwice() { var a = Context.signature(Context.getType("Int")); p(a == Context.signature(Context.getType("Int"))); return macro null; }
	public static macro function sDiffers() { p(Context.signature(Context.getType("Int")) == Context.signature(Context.getType("String"))); return macro null; }
	public static macro function fieldsOfInstance() { p(Reflect.fields(new Holder())); return macro null; }
	public static macro function fieldsOfObject() { p(Reflect.fields({alpha: 1, beta: "x", gamma: true, delta: 2.5})); return macro null; }
	public static macro function fieldsOfRef() { var t = Context.getType("String"); p(Reflect.fields(switch (t) { case TInst(c, _): c; case _: null; })); return macro null; }
	public static macro function refRoundTrip() { var t = Context.getType("String"); p(switch (t) { case TInst(c, _): c.get().name + "|" + c.toString(); case _: "no"; }); return macro null; }
}
