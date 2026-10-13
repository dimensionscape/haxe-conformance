import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;

class MB5 {
	static function pos() return Context.currentPos();
	static function withField(f:Field):Array<Field> { var a = Context.getBuildFields(); a.push(f); return a; }
	public static macro function fieldsTwice():Array<Field> { var a = Context.getBuildFields(); var b = Context.getBuildFields(); Sys.println(a.length + " " + (a == b) + " " + (a[0] == b[0]) + " " + a[0].name); return null; }
	public static macro function mutateThenNull():Array<Field> { var a = Context.getBuildFields(); a.push({name: "added", pos: pos(), kind: FVar(macro :Int, macro 1), access: [AStatic]}); return null; }
	public static macro function duplicateField():Array<Field> { return withField({name: "main", pos: pos(), kind: FVar(macro :Int, macro 1), access: [AStatic]}); }
	public static macro function varNoTypeNoExpr():Array<Field> { return withField({name: "v", pos: pos(), kind: FVar(null, null), access: [AStatic]}); }
	public static macro function fieldNullPos():Array<Field> { return withField({name: "w", pos: null, kind: FVar(macro :Int, macro 1), access: [AStatic]}); }
	public static macro function fieldNullName():Array<Field> { return withField({name: null, pos: pos(), kind: FVar(macro :Int, macro 1), access: [AStatic]}); }
	public static macro function fieldEmptyName():Array<Field> { return withField({name: "", pos: pos(), kind: FVar(macro :Int, macro 1), access: [AStatic]}); }
	public static macro function fieldNullKind():Array<Field> { return withField({name: "k", pos: pos(), kind: null, access: [AStatic]}); }
	public static macro function fieldNullAccess():Array<Field> { return withField({name: "n", pos: pos(), kind: FVar(macro :Int, macro 1), access: null}); }
	public static macro function fieldDoubleStatic():Array<Field> { return withField({name: "d", pos: pos(), kind: FVar(macro :Int, macro 1), access: [AStatic, AStatic]}); }
	public static macro function ctorVar():Array<Field> { return withField({name: "new", pos: pos(), kind: FVar(macro :Int, macro 1), access: []}); }
	public static macro function inlineVarNoExpr():Array<Field> { return withField({name: "iv", pos: pos(), kind: FVar(macro :Int, null), access: [AStatic, AInline]}); }
	public static macro function localClassInBuild():Array<Field> { Sys.println(Context.getLocalClass().get().name + " " + Context.getLocalType().toString() + " " + Context.getLocalModule() + " " + Context.getLocalMethod()); return null; }
	public static macro function getTypeOfSelf():Array<Field> { Sys.println(Context.getType("P").toString()); return null; }
	public static macro function nullElement():Array<Field> { var a = Context.getBuildFields(); a.push(null); return a; }
	public static macro function emptyList():Array<Field> { return []; }
	public static macro function fieldWithNativeMeta():Array<Field> { return withField({name: "m", pos: pos(), kind: FVar(macro :Int, macro 1), access: [AStatic], meta: [{name: ":native", params: [], pos: pos()}]}); }
	public static macro function funNullArgs():Array<Field> { return withField({name: "fn", pos: pos(), kind: FFun({args: null, ret: null, expr: macro {}}), access: [AStatic]}); }
	public static macro function funNullExpr():Array<Field> { return withField({name: "fe", pos: pos(), kind: FFun({args: [], ret: null, expr: null}), access: [AStatic]}); }
	public static macro function funArgNullName():Array<Field> { return withField({name: "fa", pos: pos(), kind: FFun({args: [{name: null, type: macro :Int}], ret: null, expr: macro {}}), access: [AStatic]}); }
	public static macro function propField():Array<Field> { return withField({name: "pr", pos: pos(), kind: FProp("default", "never", macro :Int, macro 1), access: [AStatic]}); }
	public static macro function propBadAccess():Array<Field> { return withField({name: "pb", pos: pos(), kind: FProp("nope", "never", macro :Int, macro 1), access: [AStatic]}); }
	public static macro function propNullAccess():Array<Field> { return withField({name: "pn", pos: pos(), kind: FProp(null, null, macro :Int, macro 1), access: [AStatic]}); }
	public static macro function defineWithBuild():Array<Field> { Context.defineType({pack: [], name: "Built5", pos: pos(), meta: [{name: ":build", params: [macro MB5.localClassInBuild()], pos: pos()}], kind: TDClass(), fields: []}); Sys.println(Context.getType("Built5").toString()); return null; }
	public static macro function buildOrderA():Array<Field> { Sys.println("A"); return null; }
	public static macro function buildOrderB():Array<Field> { Sys.println("B"); return null; }
	public static macro function returnsInt():Array<Field> { return cast 1; }
	public static macro function returnsString():Array<Field> { return cast "fields"; }
	public static macro function throwsInBuild():Array<Field> { throw "build-throw"; }
	public static macro function errorInBuild():Array<Field> { Context.error("build-error", pos()); return null; }
	public static macro function fieldDocAndOverride():Array<Field> { return withField({name: "ov", pos: pos(), doc: "doc", kind: FFun({args: [], ret: null, expr: macro {}}), access: [AOverride]}); }
}
