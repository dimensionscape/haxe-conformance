import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;

class MD {
	static inline function optInline(e:Null<Expr>, f:Expr->Void)
		if (e != null)
			f(e);
	static function optPlain(e:Null<Expr>, f:Expr->Void)
		if (e != null)
			f(e);
	static inline function callInline(f:Expr->Void) f(macro 1);
	public static macro function getTypeEmpty() { Context.getType(""); return macro null; }
	public static macro function getTypeTrailingDot() { Context.getType("a."); return macro null; }
	public static macro function getTypeLeadingDot() { Context.getType(".Int"); return macro null; }
	public static macro function getTypeMissingSub() { Context.getType("haxe.ds.Map.Nope"); return macro null; }
	public static macro function getTypeMapString() { Sys.println(Context.getType("haxe.ds.Map").toString()); return macro null; }
	public static macro function resolveTypeAnon() { Sys.println(Context.resolveType(macro :{x:Int, y:String}, Context.currentPos()).toString()); return macro null; }
	public static macro function allModuleTypesDuringTyping() { Sys.println(Context.getAllModuleTypes().length > 0); return macro null; }
	public static macro function typeNotFoundWrongName() { Context.onTypeNotFound(function(n) return {pack: [], name: "Other4", pos: Context.currentPos(), kind: TDClass(), fields: []}); Context.getType("Nope5"); return macro null; }
	public static macro function timerClosedTwice() { var t = Context.timer("t1"); t(); t(); return macro null; }
	public static macro function parseInlineStringEmpty() { Context.parseInlineString("", Context.currentPos()); return macro null; }
	public static macro function storeExprIds() { Sys.println(Context.storeExpr(macro 1).toString() + " " + Context.storeExpr(macro 2).toString()); return macro null; }
	public static macro function signatureOfType() { Sys.println(Context.signature(Context.getType("Int"))); return macro null; }
	public static macro function toComplexTypeMono() { Sys.println(new haxe.macro.Printer().printComplexType(Context.toComplexType(Context.typeof(macro null)))); return macro null; }
	public static macro function definesSorted() { var ks = [for (k in Context.getDefines().keys()) k]; ks.sort(Reflect.compare); Sys.println(ks.join(",")); return macro null; }
	public static macro function exprIterNullFn() { haxe.macro.ExprTools.iter(macro [1, 2], null); return macro null; }
	public static macro function typeMapNullFn() { haxe.macro.TypeTools.map(Context.getType("Array"), null); return macro null; }
	public static macro function typeofAnonFieldOrder() { Sys.println(Context.typeof(macro {x: 1, y: "s", a: true}).toString()); return macro null; }
	public static macro function getModulePrintNames() { Sys.println([for (t in Context.getModule("haxe.ds.Map")) t.toString()].join(",")); return macro null; }
	public static macro function resolveTypeFun() { Sys.println(Context.resolveType(macro :Int->String->Void, Context.currentPos()).toString()); return macro null; }
	public static macro function localClassName() { Sys.println(Context.getLocalClass().get().name); return macro null; }
	public static macro function localMethodName() { Sys.println(Context.getLocalMethod()); return macro null; }
	public static macro function currentPosPrint() { Sys.println(Context.currentPos()); return macro null; }
	public static macro function posInfosCurrent() { var i = Context.getPosInfos(Context.currentPos()); Sys.println(i.file + ":" + i.min + "-" + i.max); return macro null; }
	public static macro function warningUnknownFile() { Context.warning("w", Context.makePosition({file: "nope_file.hx", min: 0, max: 1})); return macro null; }
	public static macro function onGenerateOrder() { Context.onGenerate(function(_) Sys.println("g1")); Context.onGenerate(function(_) Sys.println("g2")); return macro null; }
	public static macro function onAfterTypingThrows() { Context.onAfterTyping(function(_) throw "after-typing"); return macro null; }
	public static macro function storeTypedExprIds() { Sys.println(Context.storeTypedExpr(Context.typeExpr(macro 1)).toString() + " " + Context.storeTypedExpr(Context.typeExpr(macro 2)).toString()); return macro null; }
	public static macro function getTypedExprRoundTrip() { Sys.println(Context.getTypedExpr(Context.typeExpr(macro 1 + 1)).toString()); return macro null; }
	public static macro function typedExprToStringBlock() { Sys.println(haxe.macro.TypedExprTools.toString(Context.typeExpr(macro { var x = 1; x + 1; }), true)); return macro null; }
	public static macro function exprToStringSwitch() { Sys.println(haxe.macro.ExprTools.toString(macro switch (x) { case 1 | 2 if (y): "a"; case _: "b"; })); return macro null; }
	public static macro function typeofFunctionString() { Sys.println(Context.typeof(macro function(a:Int) return a).toString()); return macro null; }
	public static macro function followMonoString() { Sys.println(Context.follow(Context.typeof(macro null)).toString()); return macro null; }
	public static macro function defineModuleMismatchedPack() { Context.defineModule("a.X8", [{pack: [], name: "X8", pos: Context.currentPos(), kind: TDClass(), fields: []}]); return macro null; }
	public static macro function addResourceTwice() { Context.addResource("r1", haxe.io.Bytes.ofString("a")); Context.addResource("r1", haxe.io.Bytes.ofString("b")); Sys.println(Context.getResources().get("r1").toString()); return macro null; }
	public static macro function getModulePackage() { Context.getModule("haxe.ds"); return macro null; }
	public static macro function defs() { var d = Context.getDefines(); var n = 0; for (k in d.keys()) n++; Sys.println(Context.defined("macro") + " " + Context.defined("sys") + " " + d.exists("macro") + " " + n + " " + d.get("haxe_ver")); return macro null; }
	public static macro function parseNonInline() { Context.parse("", Context.currentPos()); return macro null; }
	public static macro function ctOfMono() { var ct = Context.toComplexType(Context.typeof(macro null)); Sys.println(ct == null); Sys.println(Std.string(ct)); return macro null; }
	public static macro function definesAfterDefine() { haxe.macro.Compiler.define("zz4", "9"); var d = Context.getDefines(); Sys.println(d.exists("zz4") + " " + Context.definedValue("zz4") + " " + d.exists("sys")); return macro null; }
	public static macro function nul() { Context.parseInlineString(String.fromCharCode(0), Context.currentPos()); return macro null; }
	public static macro function viaInline() { optInline(macro 1, null); return macro null; }
	public static macro function viaPlain() { optPlain(macro 1, null); return macro null; }
	public static macro function viaCallInline() { callInline(null); return macro null; }
}
