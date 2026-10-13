#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
#end

class MHT {
	#if macro
	static function show(label:String, f:Void->String):Void {
		Sys.println(label + " = " + (try f() catch (e:Dynamic) "ERR " + Std.string(e)));
	}

	static function te(e:Expr):String return TypeTools.toString(Context.typeExpr(e).t);

	public static function go(name:String):Void {
		switch (name) {
			case "type-expr-world": show("typeExpr(Context.currentPos())", () -> te(macro haxe.macro.Context.currentPos()));
			case "type-expr-plain": show("typeExpr(1 + 1)", () -> te(macro 1 + 1));
			case "type-expr-return": show("typeExpr(return 1)", () -> te(macro return 1));
			case "type-expr-this": show("typeExpr(this)", () -> te(macro this));
			case "type-expr-local": {
				show("typeExpr({var x = 1; x;})", () -> te(macro { var x = 1; x; }));
				show("getLocalVars", () -> Std.string([for (k in Context.getLocalVars().keys()) k]));
			}
			case "typeof": show("typeof('a')", () -> TypeTools.toString(Context.typeof(macro "a")));
			case "store-expr": show("storeExpr(1)", () -> { Context.storeExpr(macro 1); "ok"; });
			case "type-and-store": show("typeAndStoreExpr(1).type", () -> Std.string(Context.typeAndStoreExpr(macro 1).type) + " " + TypeTools.toString(Context.typeAndStoreExpr(macro 1).type.get()));
			case "get-typed-expr": show("getTypedExpr(typeExpr(1))", () -> ExprTools.toString(Context.getTypedExpr(Context.typeExpr(macro 1))));
			case "store-typed-expr": show("storeTypedExpr(typeExpr(1))", () -> { Context.storeTypedExpr(Context.typeExpr(macro 1)); "ok"; });
			case "unify": show("unify(Int, Float)", () -> Std.string(Context.unify(Context.getType("Int"), Context.getType("Float"))) + " " + Std.string(Context.unify(Context.getType("Float"), Context.getType("Int"))));
			case "resolve-type": show("resolveType(:Int)", () -> TypeTools.toString(Context.resolveType(macro :Int, Context.currentPos())));
			case "resolve-type-not-imported": show("resolveType(:StringMap)", () -> TypeTools.toString(Context.resolveType(macro :StringMap<Int>, Context.currentPos())));
			case "locals": {
				show("getLocalMethod", () -> "[" + Context.getLocalMethod() + "]");
				show("getLocalModule", () -> "[" + Context.getLocalModule() + "]");
				show("getLocalClass", () -> Std.string(Context.getLocalClass()));
				show("getLocalType", () -> Std.string(Context.getLocalType()));
				show("getLocalUsing", () -> Std.string(Context.getLocalUsing().length));
				show("getLocalImports", () -> Std.string(Context.getLocalImports().length));
				show("getLocalTVars", () -> Std.string([for (k in Context.getLocalTVars().keys()) k]));
			}
			case "with-imports-type-expr": show("withImports typeExpr", () -> Context.withImports(['haxe.ds.StringMap'], [], () -> te(macro new StringMap<Int>())));
			case "with-imports-using-type-expr": show("withImports using typeExpr", () -> Context.withImports([], ['StringTools'], () -> te(macro "abc".startsWith("a"))));
			case "wildcard-after": {
				Context.withImports(['haxe.ds.*'], [], () -> 1);
				show("getType(StringMap) after", () -> TypeTools.toString(Context.getType("StringMap")));
				show("typeExpr(new IntMap) after", () -> te(macro new IntMap<Int>()));
			}
			case "wildcard-set": Context.withImports(['haxe.ds.*'], [], () -> 1);
			case "wildcard-read": show("getType(StringMap) in a later init macro", () -> TypeTools.toString(Context.getType("StringMap")));
			case "after-init": Context.onAfterInitMacros(() -> show("after-init typeExpr(Context.currentPos())", () -> te(macro haxe.macro.Context.currentPos())));
			case "after-init-wildcard": {
				Context.withImports(['haxe.ds.*'], [], () -> 1);
				Context.onAfterInitMacros(() -> show("after-init getType(StringMap)", () -> TypeTools.toString(Context.getType("StringMap"))));
			}
			case "type-expr-error-uncaught": te(macro undefinedThing);
			case "type-expr-return-uncaught": te(macro return 1);
			case _: throw "no case " + name;
		}
	}
	#end

	public static macro function typeAndStore():Expr {
		var r = Context.typeAndStoreExpr(macro [1, 2]);
		Sys.println("expr = " + (switch (r.expr.expr) {
			case EMeta(m, {expr: EConst(CInt(_))}): "@" + m.name + "(<int>)";
			case _: ExprTools.toString(r.expr);
		}));
		Sys.println("type = " + Std.string(r.type) + " " + TypeTools.toString(r.type.get()));
		Sys.println("fields = " + Reflect.fields(r).join(","));
		return r.expr;
	}
}
