import haxe.macro.Context;
import haxe.macro.Expr;

class MCP {
	#if macro
	static var depth = 0;

	static function recurse():Void {
		depth++;
		recurse();
	}

	static function helper():Void {
		throw "deep";
	}

	public static function init(name:String):Void {
		switch (name) {
			case "options-callback-throws":
				Context.withOptions({}, function() { throw "boom"; return 1; });
			case "callback-calls-a-throwing-helper":
				Context.withOptions({}, function() { helper(); return 1; });
			case "callback-native-fails":
				Context.withOptions({}, function() { Context.getType("Nope"); return 1; });
			case "callback-in-a-callback-throws":
				Context.withImports([], [], function() { Context.withOptions({}, function() { throw "inner"; return 1; }); return 1; });
			case "callback-throws-past-a-try":
				try Context.withOptions({}, function() { throw "boom"; return 1; }) catch (e:Dynamic) Sys.println("caught " + e);
			case "throws":
				throw "boom";
			case "native-fails":
				Context.getType("Nope");
			case "depth":
				try recurse() catch (e:Dynamic) Sys.println("depth " + depth + " " + e);
			case "error":
				Context.error("reported", Context.currentPos());
			case "error-in-a-callback-then-throws":
				Context.withOptions({}, function() { Context.error("reported", Context.currentPos()); return 1; });
				throw "after";
			case "after-init-throws":
				Context.onAfterInitMacros(function() throw "late");
			case _:
				throw "no case " + name;
		}
	}
	#end

	public static macro function error():Expr {
		Context.error("reported", Context.currentPos());
		return macro null;
	}

	public static macro function throws():Expr {
		throw "boom";
	}

	public static macro function callbackThrows():Expr {
		Context.withOptions({}, function() { throw "boom"; return 1; });
		return macro null;
	}

	public static macro function depthNow():Expr {
		try recurse() catch (e:Dynamic) Sys.println("depth " + depth + " " + e);
		return macro null;
	}

	public static macro function buildCallbackThrows():Array<Field> {
		Context.withOptions({}, function() { throw "boom"; return 1; });
		return null;
	}

	public static macro function buildThrows():Array<Field> {
		throw "boom";
	}

	public static macro function buildMacroError():Array<Field> {
		throw new haxe.macro.Expr.Error("thrown", Context.currentPos());
	}

	public static macro function buildTypeExprFails():Array<Field> {
		Context.typeExpr(macro undefinedThing);
		return null;
	}

	public static macro function buildDepth():Array<Field> {
		try recurse() catch (e:Dynamic) Sys.println("depth " + depth + " " + e);
		return null;
	}

	public static macro function typeThrows():ComplexType {
		throw "boom";
	}

	public static macro function typeCallbackThrows():ComplexType {
		Context.withOptions({}, function() { throw "boom"; return 1; });
		return null;
	}

	public static macro function typeReports():ComplexType {
		Context.error("reported", Context.currentPos());
		return null;
	}

	public static macro function typeDepth():ComplexType {
		try recurse() catch (e:Dynamic) Sys.println("depth " + depth + " " + e);
		return macro : Int;
	}

	public static macro function apiError():Expr {
		Context.typeExpr(macro undefinedThing);
		return macro 1;
	}
}
