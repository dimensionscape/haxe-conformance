import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;

class MWI {
	#if macro
	static function strings(e:Expr):Array<String> {
		return switch (e.expr) {
			case EArrayDecl(a): [for (x in a) ExprTools.getValue(x)];
			case _: throw "an array literal";
		}
	}

	static function exprs(e:Expr):Array<Expr> {
		return switch (e.expr) {
			case EArrayDecl(a): a;
			case _: throw "an array literal";
		}
	}

	static function probe(types:Array<String>, el:Array<Expr>):Void {
		for (s in types)
			Sys.println("type " + s + " = " + (try TypeTools.toString(Context.getType(s)) catch (e:Dynamic) "ERR " + Std.string(e)));
		for (x in el)
			Sys.println("expr " + ExprTools.toString(x) + " = " + (try TypeTools.toString(Context.typeExpr(x).t) catch (e:Dynamic) "ERR " + Std.string(e)));
	}

	static function run(imports:Array<String>, usings:Array<String>, types:Array<String>, el:Array<Expr>, after:Array<String>):Void {
		var r = Context.withImports(imports, usings, function() { probe(types, el); return "done"; });
		Sys.println("returned " + r);
		probe(after, []);
	}

	static function caught(f:Void->Dynamic):Void {
		Sys.println("got " + (try Std.string(f()) catch (e:Dynamic) "caught " + Std.string(e)));
	}

	public static function init(name:String):Void {
		switch (name) {
			case "unterminated-string": run(['a"b'], [], [], [], []);
			case "missing-semicolon": run(['a.'], [], [], [], []);
			case "using-missing-name": run([], ['a.'], [], [], []);
			case "type": run(['haxe.ds.StringMap'], [], ['StringMap'], [], ['StringMap']);
			case "module": run(['wipk.WMod'], [], ['WMod', 'Sub', 'En', 'TD', 'Priv'], [], ['WMod']);
			case "in-alias": run(['haxe.ds.StringMap in SM'], [], ['SM'], [], ['SM']);
			case "wildcard": run(['haxe.ds.*'], [], ['StringMap', 'IntMap'], [], []);
			case "wildcard-after": run(['haxe.ds.*'], [], [], [], ['StringMap']);
			case "using-missing-module": run([], ['nope.Nope'], [], [], []);
			case "no-statics": run(['wipk.WMod.TD.*'], [], [], [], []);
			case "type-expr": run(['haxe.ds.StringMap'], [], [], [macro new StringMap<Int>()], []);
			case "callback-throws": Context.withImports([], [], function() { throw "boom"; return 1; });
			case _: throw "no case " + name;
		}
	}
	#end

	public static macro function check(imports:Expr, usings:Expr, types:Expr, el:Expr, after:Expr):Expr {
		run(strings(imports), strings(usings), strings(types), exprs(el), strings(after));
		return macro null;
	}

	public static macro function nested():Expr {
		Context.withImports(['haxe.ds.StringMap'], [], function() {
			Context.withImports(['haxe.ds.IntMap'], [], function() { probe(['StringMap', 'IntMap'], []); return 1; });
			probe(['StringMap', 'IntMap'], []);
			return 1;
		});
		probe(['StringMap'], []);
		return macro null;
	}

	public static macro function callbackValue():Expr {
		Sys.println("got " + Context.withImports([], [], function() return "a value"));
		Context.withImports([], [], function() {});
		Sys.println("void callback ran");
		return macro null;
	}

	public static macro function callbackReports():Expr {
		Sys.println("got " + Context.withImports([], [], function() { Context.error("reported", Context.currentPos()); return 1; }));
		return macro null;
	}

	public static macro function callbackThrows():Expr {
		caught(function() return Context.withImports([], [], function() { throw "boom"; return 1; }));
		return macro null;
	}

	public static macro function callbackThrowsMacroError():Expr {
		caught(function() return Context.withImports([], [], function() { throw new haxe.macro.Expr.Error("thrown", Context.currentPos()); return 1; }));
		return macro null;
	}

	public static macro function callbackApiError():Expr {
		caught(function() return Context.withImports([], [], function() return Context.typeExpr(macro undefinedThing)));
		return macro null;
	}

	public static macro function badArgument(which:Expr):Expr {
		var f:Void->Dynamic = switch (ExprTools.getValue(which)) {
			case "null-callback": function() return Context.withImports([], [], null);
			case "not-a-function": function() return Context.withImports([], [], cast 3);
			case "null-imports": function() return Context.withImports(null, [], function() return 1);
			case "null-usings": function() return Context.withImports([], null, function() return 1);
			case "null-element": function() return Context.withImports([null], [], function() return 1);
			case "parse-before-callback": function() return Context.withImports(['a"b'], [], null);
			case "imports-before-usings": function() return Context.withImports(['a"b'], null, null);
			case _: throw "no case";
		}
		caught(f);
		return macro null;
	}

	public static macro function escapesTry(which:Expr):Expr {
		caught(switch (ExprTools.getValue(which)) {
			case "parse": function() return Context.withImports(['a"b'], [], function() return 1);
			case "using-load": function() return Context.withImports([], ['nope.Nope'], function() return 1);
			case "no-statics": function() return Context.withImports(['wipk.WMod.TD.*'], [], function() return 1);
			case _: throw "no case";
		});
		return macro null;
	}
}
