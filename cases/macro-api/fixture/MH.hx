import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.PositionTools;
using haxe.macro.Tools;

class MH {
	static function p(v:Dynamic) Sys.println(Std.string(v));
	#if macro
	static function pos() return Context.currentPos();
	#end
	#if macro
	static function tstr(t:Null<Type>):String return t == null ? "null" : t.toString();
	#end
	public static inline function inl(x:Int) return x + 1;

	public static macro function expected() { p(tstr(Context.getExpectedType())); return macro cast null; }
	public static macro function expectedBuild():Array<Field> { p(tstr(Context.getExpectedType())); return null; }

	public static macro function gcaMacro() { p(Context.getCallArguments()); return macro null; }
	public static macro function gcaBuild():ComplexType {
		var args = Context.getCallArguments();
		p(args == null ? "null" : [for (a in args) a.toString()].join(","));
		return macro : GImpl;
	}

	public static macro function imports() {
		p([for (i in Context.getLocalImports()) [for (x in i.path) x.name].join(".") + ":" + Std.string(i.mode)].join(" "));
		p([for (u in Context.getLocalUsing()) u.get().name].join(" "));
		return macro null;
	}
	public static macro function importsBuild():Array<Field> {
		p([for (i in Context.getLocalImports()) [for (x in i.path) x.name].join(".")].join(" ") + "|" + [for (u in Context.getLocalUsing()) u.get().name].join(" "));
		return null;
	}

	#if macro
	static function tvarsString():String {
		var out = [for (k => v in Context.getLocalTVars()) k + ":" + v.t.toString()];
		out.sort(Reflect.compare);
		return "[" + out.join(" ") + "]";
	}
	#end
	public static macro function tvars() { p(tvarsString()); return macro null; }
	public static macro function tvarsBuild():Array<Field> { p(tvarsString()); return null; }

	public static macro function gmeMacro() { p(Context.getMainExpr()); return macro null; }
	public static macro function gmeGenerate() { Context.onGenerate(function(_) { var m = Context.getMainExpr(); p(m == null ? "null" : m.toString()); }); return macro null; }
	public static macro function gmeAfterTyping() { Context.onAfterTyping(function(_) { var m = Context.getMainExpr(); p(m == null ? "null" : m.toString()); }); return macro null; }
	public static macro function gmeAfterGenerate() { Context.onAfterGenerate(function() { var m = Context.getMainExpr(); p(m == null ? "null" : m.toString()); }); return macro null; }

	public static macro function rmdOk() { Context.registerModuleDependency("P", "dep.txt"); p("ok"); return macro null; }
	public static macro function rmdMissing() { Context.registerModuleDependency("Nope", "dep.txt"); p("ok"); return macro null; }
	public static macro function rmdNullModule() { Context.registerModuleDependency(null, "dep.txt"); p("ok"); return macro null; }
	public static macro function rmdNullFile() { Context.registerModuleDependency("P", null); p("ok"); return macro null; }
	public static macro function rmdEmptyModule() { Context.registerModuleDependency("", "dep.txt"); p("ok"); return macro null; }
	public static macro function rmdEmptyFile() { Context.registerModuleDependency("P", ""); p("ok"); return macro null; }
	public static macro function rmdStd() { Context.registerModuleDependency("haxe.ds.StringMap", "dep.txt"); p("ok"); return macro null; }

	public static macro function reBasic() { Context.reportError("bad thing", pos()); p("after"); return macro null; }
	public static macro function reTwice() { Context.reportError("first", pos()); Context.reportError("second", pos()); return macro null; }
	public static macro function reNullPos() { Context.reportError("x", null); p("after"); return macro null; }
	public static macro function reNullMsg() { Context.reportError(null, pos()); p("after"); return macro null; }
	public static macro function reDepth1() { Context.reportError("deep", pos(), 1); return macro null; }
	public static macro function reCaught() { try { Context.reportError("x", pos()); p("no throw"); } catch (e:Dynamic) p("caught " + e); return macro null; }
	public static macro function feBasic() { p("before"); Context.fatalError("fatal thing", pos()); p("after"); return macro null; }
	public static macro function feNullPos() { Context.fatalError("x", null); return macro null; }
	public static macro function feNullMsg() { Context.fatalError(null, pos()); return macro null; }
	public static macro function feDepth1() { Context.fatalError("deep", pos(), 1); return macro null; }
	public static macro function feCaught() { try { Context.fatalError("x", pos()); } catch (e:Dynamic) p("caught " + e); p("after"); return macro null; }
	public static macro function feBuild():Array<Field> { Context.fatalError("fatal in build", pos()); return null; }
	public static macro function feGenerate() { Context.onGenerate(function(_) Context.fatalError("fatal in generate", pos())); return macro null; }
	public static macro function reGenerate() { Context.onGenerate(function(_) { Context.reportError("reported in generate", pos()); p("after"); }); return macro null; }

	public static macro function oagBasic() { Context.onAfterGenerate(function() p("after generate")); return macro null; }
	public static macro function oagTwice() { Context.onAfterGenerate(function() p("one")); Context.onAfterGenerate(function() p("two")); return macro null; }
	public static macro function oagThrows() { Context.onAfterGenerate(function() throw "boom"); return macro null; }
	public static macro function oagNull() { Context.onAfterGenerate(null); p("registered"); return macro null; }
	public static macro function oagWithError() { Context.onAfterGenerate(function() p("after generate")); Context.reportError("err", pos()); return macro null; }
	public static macro function oagNested() { Context.onAfterGenerate(function() { p("outer"); Context.onAfterGenerate(function() p("inner")); }); return macro null; }
	public static macro function oagFromGenerate() { Context.onGenerate(function(_) Context.onAfterGenerate(function() p("from generate"))); return macro null; }
	public static macro function oagError() { Context.onAfterGenerate(function() Context.error("error in after generate", pos())); return macro null; }

	public static macro function woInlineOff() { p(Context.withOptions({allowInlining: false}, function() return Context.typeExpr(macro MH.inl(1))).toString()); return macro null; }
	public static macro function woInlineDefault() { p(Context.typeExpr(macro MH.inl(1)).toString()); return macro null; }
	public static macro function woInlineOn() { p(Context.withOptions({allowInlining: true}, function() return Context.typeExpr(macro MH.inl(1))).toString()); return macro null; }
	public static macro function woTransformOff() { p(Context.withOptions({allowTransform: false}, function() return Context.typeExpr(macro { var s = 0; for (i in 0...3) s += i; s; })).toString()); return macro null; }
	public static macro function woTransformDefault() { p(Context.typeExpr(macro { var s = 0; for (i in 0...3) s += i; s; }).toString()); return macro null; }
	public static macro function woTransformOffProperty() { p(Context.withOptions({allowTransform: false}, function() return Context.typeExpr(macro new PropHolder().v)).toString()); return macro null; }
	public static macro function woEmpty() { p(Context.withOptions({}, function() return Context.typeExpr(macro MH.inl(1))).toString()); return macro null; }
	public static macro function woNull() { p(Context.withOptions(null, function() return "ran")); return macro null; }
	public static macro function woNullCode() { p(Context.withOptions({allowInlining: false}, null)); return macro null; }
	public static macro function woThrows() { try Context.withOptions({allowInlining: false}, function() { throw "boom"; return 1; }) catch (e:Dynamic) p("caught " + e); p(Context.typeExpr(macro MH.inl(1)).toString()); return macro null; }
	public static macro function woNested() { p(Context.withOptions({allowInlining: false}, function() return Context.withOptions({allowInlining: true}, function() return Context.typeExpr(macro MH.inl(1))).toString() + "|" + Context.typeExpr(macro MH.inl(1)).toString())); return macro null; }
	public static macro function woReturn() { p(Context.withOptions({allowInlining: false}, function() return "X")); return macro null; }

	#if macro
	static function locString(pp:Position):String { var l = PositionTools.toLocation(pp); return l.file + " " + l.range.start.line + ":" + l.range.start.character + "-" + l.range.end.line + ":" + l.range.end.character; }
	#end
	public static macro function locBasic() { p(locString(pos())); return macro null; }
	public static macro function locNull() { p(locString(null)); return macro null; }
	public static macro function locMade() { p(locString(PositionTools.make({file: "P.hx", min: 0, max: 5}))); return macro null; }
	public static macro function locUnknownFile() { p(locString(PositionTools.make({file: "nope.hx", min: 0, max: 3}))); return macro null; }
	public static macro function locNegative() { p(locString(PositionTools.make({file: "P.hx", min: -1, max: -1}))); return macro null; }
	public static macro function locMultiline() { p(locString(PositionTools.make({file: "P.hx", min: 2, max: 60}))); return macro null; }
	public static macro function locReversed() { p(locString(PositionTools.make({file: "P.hx", min: 10, max: 2}))); return macro null; }

	public static macro function incNope() { Compiler.include("nope.pkg"); p("ok"); return macro null; }
	public static macro function incNopeStrict() { Compiler.include("nope.pkg", true, null, null, true); p("ok"); return macro null; }
	public static macro function incNull() { Compiler.include(null); p("ok"); return macro null; }
	public static macro function incEmpty() { Compiler.include(""); p("ok"); return macro null; }
	public static macro function incHaxeDs() { Compiler.include("haxe.ds", false); p("ok"); return macro null; }
	public static macro function incIgnore() { Compiler.include("haxe.ds", false, ["haxe.ds.Vector", "haxe.ds.GenericStack"]); p("ok"); return macro null; }
	public static macro function incClassPathNope() { Compiler.include("haxe.ds", false, null, ["nope/dir"], true); p("ok"); return macro null; }
	public static macro function excNope() { Compiler.exclude("nope"); p("ok"); return macro null; }
	public static macro function excNull() { Compiler.exclude(null); p("ok"); return macro null; }
	public static macro function excHaxeDs() { Compiler.exclude("haxe.ds"); p("ok"); return macro null; }
	public static macro function keepNope() { Compiler.keep("Nope"); p("ok"); return macro null; }
	public static macro function keepNull() { Compiler.keep(null); p("ok"); return macro null; }
	public static macro function keepBoth() { Compiler.keep("P", ["P", "Nope"], false); p("ok"); return macro null; }
	public static macro function keepPackage() { Compiler.keep("haxe.ds"); p("ok"); return macro null; }

	public static macro function outGet() { p("[" + Compiler.getOutput() + "]"); return macro null; }
	public static macro function outSetGet() { Compiler.setOutput("out.dir"); p("[" + Compiler.getOutput() + "]"); return macro null; }
	public static macro function outSetNull() { Compiler.setOutput(null); p("[" + Compiler.getOutput() + "]"); return macro null; }

	public static macro function rcdBasic() { Compiler.registerCustomDefine({define: "my_def", doc: "my doc"}); p(Context.defined("my_def")); return macro null; }
	public static macro function rcdNull() { Compiler.registerCustomDefine(null); p("ok"); return macro null; }
	public static macro function rcdNullName() { Compiler.registerCustomDefine({define: null, doc: "x"}); p("ok"); return macro null; }
	public static macro function rcdNullDoc() { Compiler.registerCustomDefine({define: "d3", doc: null}); p("ok"); return macro null; }
	public static macro function rcdBadPlatform() { Compiler.registerCustomDefine({define: "d2", doc: "x", platforms: [cast "nope"]}); p("ok"); return macro null; }
	public static macro function rcdPlatforms() { Compiler.registerCustomDefine({define: "d4", doc: "x", platforms: [cast "js", cast "cpp"], params: ["a"], links: ["http://x"]}, "src"); p("ok"); return macro null; }
	public static macro function rcdTwice() { Compiler.registerCustomDefine({define: "d5", doc: "x"}); Compiler.registerCustomDefine({define: "d5", doc: "y"}); p("ok"); return macro null; }
	public static macro function rcdExisting() { Compiler.registerCustomDefine({define: "js", doc: "x"}); p("ok"); return macro null; }
	public static macro function rcmBasic() { Compiler.registerCustomMetadata({metadata: "myMeta", doc: "x"}); p("ok"); return macro null; }
	public static macro function rcmBadTarget() { Compiler.registerCustomMetadata({metadata: "m2", doc: "x", targets: [cast "nope"]}); p("ok"); return macro null; }
	public static macro function rcmTargets() { Compiler.registerCustomMetadata({metadata: "m3", doc: "x", targets: [cast "TClass", cast "TClassField"], platforms: [cast "js"], params: ["a"], links: ["l"]}, "src"); p("ok"); return macro null; }
	public static macro function rcmNull() { Compiler.registerCustomMetadata(null); p("ok"); return macro null; }
	public static macro function rcmNullName() { Compiler.registerCustomMetadata({metadata: null, doc: "x"}); p("ok"); return macro null; }
	public static macro function rcmExisting() { Compiler.registerCustomMetadata({metadata: "keep", doc: "x"}); p("ok"); return macro null; }

	public static macro function gdpNone() { p(Compiler.getDisplayPos()); return macro null; }
	public static macro function gdmNone() { p(Context.getDisplayMode()); return macro null; }
	public static macro function omcrRegister() { Context.onMacroContextReused(function() return true); p("ok"); return macro null; }
	public static macro function omcrNull() { Context.onMacroContextReused(null); p("ok"); return macro null; }

	public static macro function errCaught() { try { Context.error("err x", pos()); p("not here"); } catch (e:Dynamic) p("caught " + e); p("after"); return macro null; }
	public static macro function errGenerate() { Context.onGenerate(function(_) { Context.error("err in generate", pos()); p("not here"); }); return macro null; }
	public static macro function errAfterGenerate() { Context.onAfterGenerate(function() { Context.error("err in after generate", pos()); p("not here"); }); return macro null; }
	public static macro function errBuild():Array<Field> { Context.error("err in build", pos()); return null; }
	public static macro function errNested() { try { Context.typeExpr(macro MH.errCaught()); p("typed"); } catch (e:Dynamic) p("caught " + e); return macro null; }
	public static macro function tou() { Context.typeof(macro nope.Nope.x); return macro "s"; }
	public static macro function fullPathEmpty() { p("[" + sys.FileSystem.fullPath("") + "]"); return macro null; }
	public static macro function fullPathDot() { p(sys.FileSystem.fullPath(".").length > 0); return macro null; }
	public static macro function fullPathNull() { p(sys.FileSystem.fullPath(null)); return macro null; }
	public static macro function gmBadPackage() { Context.getModule("badpack.BP"); p("after"); return macro null; }
	public static macro function gmBadPackageCaught() { try { Context.getModule("badpack.BP"); p("after"); } catch (e:haxe.macro.Expr.Error) p("caught " + e.message); return macro null; }
	public static macro function woTransformOffToString() { p(Context.withOptions({allowTransform: false}, function() return Context.typeExpr(macro "a" + new PropHolder())).toString()); return macro null; }
	public static macro function woTransformDefaultToString() { p(Context.typeExpr(macro "a" + new PropHolder()).toString()); return macro null; }
	public static macro function woTransformOffOptional() { p(Context.withOptions({allowTransform: false}, function() return Context.typeExpr(macro MH.opt(1))).toString()); return macro null; }
	public static macro function woTransformDefaultOptional() { p(Context.typeExpr(macro MH.opt(1)).toString()); return macro null; }
	public static macro function woTransformOffUsing() { p(Context.withOptions({allowTransform: false}, function() return Context.typeExpr(macro (1 : Wrap).twice())).toString()); return macro null; }
	public static macro function woTransformDefaultUsing() { p(Context.typeExpr(macro (1 : Wrap).twice()).toString()); return macro null; }
	public static macro function woTransformOffArray() { p(Context.withOptions({allowTransform: false}, function() return Context.typeExpr(macro (1 : Wrap)[2])).toString()); return macro null; }
	public static macro function woTransformDefaultArray() { p(Context.typeExpr(macro (1 : Wrap)[2]).toString()); return macro null; }
	public static macro function woBadOption() { p(Context.withOptions(cast {allowInlining: 1}, function() return "ran")); return macro null; }
	public static function opt(a:Int, ?b:Int, ?c:String) return a;
}
