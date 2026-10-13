#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class M {
#if macro

	public static macro function getTypeMissing() { Context.getType("Nope"); return macro null; }
	public static macro function errorNullPos() { Context.error("bad", null); return macro null; }
	public static macro function followNull() { haxe.macro.TypeTools.follow(null); return macro null; }
	public static macro function makeExprOfFunction() { return Context.makeExpr(function() {}, Context.currentPos()); }

	public static macro function defineTwice() {
		var td:TypeDefinition = {pack: [], name: "Made", pos: Context.currentPos(), kind: TDClass(), fields: []};
		Context.defineType(td); Context.defineType(td); return macro null;
	}

	public static macro function answersNull():Expr { return null; }

	public static macro function parseBad() { Context.parse("1 +", Context.currentPos()); return macro null; }
	public static macro function parseInlineBad() { Context.parseInlineString("1 +", Context.currentPos()); return macro null; }

	public static function addMacroFn():Array<Field> {
		var fields = Context.getBuildFields();
		fields.push({
			name: "m", access: [AStatic, AMacro], pos: Context.currentPos(),
			kind: FFun({args: [], ret: null, expr: macro return macro null})
		});
		return fields;
	}

	public static function wrongValue():Dynamic return 1;

	public static function throws():Array<Field> { throw "boom"; }

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		fields.push({
			name: "added", access: [AStatic, APublic], pos: Context.currentPos(),
			kind: FVar(macro :Int, macro 42)
		});
		return fields;
	}

	public static function buildNull():Array<Field> return null;

	public static function buildError():Array<Field> {
		return Context.error("macro said no", Context.currentPos());
	}

	public static function buildWrongReturn():Expr return macro 1;

	public static function buildEnum():Array<Field> {
		var fields = Context.getBuildFields();
		fields.push({name: "Extra", pos: Context.currentPos(), kind: FVar(null, null)});
		return fields;
	}

	public static function buildEnumNoArgType():Array<Field> {
		var fields = Context.getBuildFields();
		fields.push({
			name: "Bad", pos: Context.currentPos(),
			kind: FFun({args: [{name: "v", type: null}], ret: null, expr: null})
		});
		return fields;
	}

	public static function buildEnumWithBody():Array<Field> {
		var fields = Context.getBuildFields();
		fields.push({
			name: "Bad", pos: Context.currentPos(),
			kind: FFun({args: [], ret: null, expr: macro trace("x")})
		});
		return fields;
	}

	public static function buildEnumLocalType():Array<Field> {
		var t = Context.getLocalType();
		var fields = Context.getBuildFields();
		fields.push({
			name: "T_" + haxe.macro.TypeTools.toString(t).split(".").pop(),
			pos: Context.currentPos(), kind: FVar(null, null)
		});
		return fields;
	}

	public static function buildThrow():Array<Field> {
		throw "raw throw from a macro";
	}
#end

	public static macro function twice(e:haxe.macro.Expr):haxe.macro.Expr return macro $e + $e;

	public static macro function fail(e:haxe.macro.Expr):haxe.macro.Expr {
		return haxe.macro.Context.error("expression macro said no", haxe.macro.Context.currentPos());
	}

	public static macro function getModuleMissing() { Context.getModule("Nope"); return macro null; }
	public static macro function getModuleBadPath() { Context.getModule("a.b.Nope"); return macro null; }
	public static macro function localMethodOutside() { return macro $v{Context.getLocalMethod()}; }
	public static macro function localTypeOutside() { var t = Context.getLocalType(); return macro $v{t == null}; }
	public static macro function localModuleOutside() { return macro $v{Context.getLocalModule()}; }
	public static macro function macroStack() { return macro $v{Context.getMacroStack().length}; }
	public static macro function defineModuleTwice() {
		Context.defineModule("Made2", [{pack: [], name: "Made2", pos: Context.currentPos(), kind: TDClass(), fields: []}]);
		Context.defineModule("Made2", [{pack: [], name: "Made2", pos: Context.currentPos(), kind: TDClass(), fields: []}]);
		return macro null;
	}
	public static macro function defineModuleEmpty() { Context.defineModule("Made3", []); return macro null; }
	public static macro function defineModuleNameMismatch() {
		Context.defineModule("Made4", [{pack: ["other"], name: "Made4", pos: Context.currentPos(), kind: TDClass(), fields: []}]);
		return macro null;
	}
	public static macro function globalMetaBadPattern() { haxe.macro.Compiler.addGlobalMetadata("", "@:keep"); return macro null; }
	public static macro function globalMetaBadMeta() { haxe.macro.Compiler.addGlobalMetadata("P", "not meta"); return macro null; }
	public static macro function typeAndStoreBad() { Context.typeAndStoreExpr(macro nope); return macro null; }
	public static macro function unifyNull() { return macro $v{Context.unify(null, null)}; }
	public static macro function toComplexNull() { Context.toComplexType(null); return macro null; }
	public static macro function moduleTypeToTypeNull() { haxe.macro.TypeTools.toModuleType(null); return macro null; }
	public static macro function positionToRangeNull() { haxe.macro.PositionTools.toLocation(null); return macro null; }
	public static macro function posInfosNull() { Context.getPosInfos(null); return macro null; }
	public static macro function includeFileMissing() { haxe.macro.Compiler.includeFile("nope.js"); return macro null; }
	public static macro function includeFileBadPos() { haxe.macro.Compiler.includeFile("M.hx", "nowhere"); return macro null; }
	public static macro function applyParamsMismatch() {
		var t = Context.getType("Array");
		haxe.macro.TypeTools.applyTypeParameters(t, [], [Context.getType("Int")]);
		return macro null;
	}
	public static macro function followAbstractsNull() { haxe.macro.TypeTools.followWithAbstracts(null); return macro null; }
	public static macro function getTypedExprNull() { Context.getTypedExpr(null); return macro null; }
	public static macro function storeExprNull() { Context.storeExpr(null); return macro null; }
	public static macro function withImportsBad() { Context.withImports(["nope.Nope"], [], function() return 1); return macro null; }
	public static macro function withImportsUsingBad() { Context.withImports([], ["nope.Nope"], function() return 1); return macro null; }
	public static macro function infoNullPos() { Context.info("fyi", null); return macro null; }
	public static macro function definedNull() { return macro $v{Context.defined(null)}; }
	public static macro function definedValueMissing() { return macro $v{Context.definedValue("nope_define") == null}; }
	public static macro function formatStringBad() { haxe.macro.MacroStringTools.formatString("${", Context.currentPos()); return macro null; }
	public static macro function containsDisplayNull() { return macro $v{Context.containsDisplayPosition(null)}; }
	public static macro function typeNotFoundThrows() { Context.onTypeNotFound(function(s) { throw "tnf " + s; }); return macro (null : nope.Missing); }
	public static macro function typeNotFoundBadReturn() { Context.onTypeNotFound(function(s) return {pack: [], name: "X", pos: Context.currentPos(), kind: TDClass(), fields: []}); return macro (null : Missing2); }
	public static macro function filterThrows() { Context.warning("w", Context.currentPos()); Context.filterMessages(function(m) throw "filt"); return macro null; }
	public static macro function messagesCount() { Context.warning("w1", Context.currentPos()); return macro $v{Context.getMessages().length}; }
	public static macro function initMacrosDoneValue() { return macro $v{Context.initMacrosDone()}; }
	public static macro function afterInitMacrosLate() { Context.onAfterInitMacros(function() Context.error("late init", Context.currentPos())); return macro null; }
	public static macro function resolveTypeNullPos() { Context.resolveType(macro :Int, null); return macro null; }
	public static macro function makeExprCyclic() { var o:Dynamic = {}; o.self = o; return Context.makeExpr(o, Context.currentPos()); }
	public static macro function makeMonomorphValue() { var t = Context.makeMonomorph(); return macro $v{haxe.macro.TypeTools.toString(t)}; }
	public static macro function getClassPathCount() { return macro $v{Context.getClassPath().length > 0}; }
	public static macro function typeExprNullExpr() { Context.typeExpr(null); return macro null; }
	public static macro function typeofNullExpr() { Context.typeof(null); return macro null; }
	public static macro function parseNullString() { Context.parse(null, Context.currentPos()); return macro null; }
	public static macro function parseNullPos() { Context.parse("1", null); return macro null; }
	public static macro function errorNullMsg() { Context.error(null, Context.currentPos()); return macro null; }
	public static macro function defineTypeNull() { Context.defineType(null); return macro null; }
	public static macro function getBuildFieldsInExpr() { return macro $v{Context.getBuildFields().length}; }
	public static macro function typeofOf(e:haxe.macro.Expr) { Sys.println(haxe.macro.TypeTools.toString(Context.typeof(e))); return macro null; }
}
