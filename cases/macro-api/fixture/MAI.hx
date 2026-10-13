import haxe.macro.Context;
import haxe.macro.Expr;

class MAI {
	#if macro
	static function pos():Position {
		return Context.makePosition({min: 3, max: 8, file: "MAI.hx"});
	}

	static function helper():Void {
		throw "deep";
	}

	static function withChildren():haxe.macro.Expr.Error {
		var e = new haxe.macro.Expr.Error("parent", pos());
		@:privateAccess e.childErrors = [
			new haxe.macro.Expr.Error("child1", Context.makePosition({min: 10, max: 12, file: "MAI.hx"})),
			new haxe.macro.Expr.Error("child2", Context.makePosition({min: 14, max: 16, file: "MAI.hx"}))
		];
		return e;
	}

	public static function init(name:String):Void {
		switch (name) {
			case "throws":
				Context.onAfterInitMacros(function() throw "late");
			case "print":
				Context.onAfterInitMacros(function() Sys.println("callback ran"));
			case "throw-then-print":
				Context.onAfterInitMacros(function() throw "late");
				Context.onAfterInitMacros(function() Sys.println("second ran"));
			case "print-then-throw":
				Context.onAfterInitMacros(function() Sys.println("first ran"));
				Context.onAfterInitMacros(function() throw "late");
			case "error-then-print":
				Context.onAfterInitMacros(function() Context.error("e1", pos()));
				Context.onAfterInitMacros(function() Sys.println("second ran"));
			case "error-then-throw":
				Context.onAfterInitMacros(function() Context.error("e1", pos()));
				Context.onAfterInitMacros(function() throw "late");
			case "report-error-then-print":
				Context.onAfterInitMacros(function() Context.reportError("re", pos()));
				Context.onAfterInitMacros(function() Sys.println("second ran"));
			case "macro-error":
				Context.onAfterInitMacros(function() throw new haxe.macro.Expr.Error("me", pos()));
				Context.onAfterInitMacros(function() Sys.println("second ran"));
			case "fatal":
				Context.onAfterInitMacros(function() Context.fatalError("fe", pos()));
				Context.onAfterInitMacros(function() Sys.println("second ran"));
			case "native-fails":
				Context.onAfterInitMacros(function() Context.getType("Nope"));
				Context.onAfterInitMacros(function() Sys.println("second ran"));
			case "typing-fails":
				Context.onAfterInitMacros(function() Context.typeof(macro nope));
				Context.onAfterInitMacros(function() Sys.println("second ran"));
			case "helper":
				Context.onAfterInitMacros(function() helper());
			case "bound-method":
				Context.onAfterInitMacros(helper);
			case "registered-while-running":
				Context.onAfterInitMacros(function() {
					Sys.println("first ran");
					Context.onAfterInitMacros(function() throw "later");
				});
				Context.onAfterInitMacros(function() Sys.println("second ran"));
			case "caught":
				Context.onAfterInitMacros(function() try throw "x" catch (e:Dynamic) Sys.println("caught " + e));
			case "register":
				haxe.macro.Compiler.registerCustomDefine({define: "mai-flag", doc: "A flag of the fixture."}, "mai");
				haxe.macro.Compiler.registerCustomMetadata({metadata: ":maiMeta", doc: "A metadata of the fixture."}, "mai");
			case "warn":
				Context.warning("careful", pos());
			case "error":
				Context.error("init error", pos());
			case "children":
				throw withChildren();
			case "empty-children":
				var e = new haxe.macro.Expr.Error("parent", pos());
				@:privateAccess e.childErrors = [];
				throw e;
			case "bad-child":
				var e = new haxe.macro.Expr.Error("parent", pos());
				@:privateAccess e.childErrors = [cast "not an error"];
				throw e;
			case "options-children":
				Context.withOptions({}, function() { throw withChildren(); return 1; });
			case "after-init-children":
				Context.onAfterInitMacros(function() throw withChildren());
			case "after-typing-children":
				Context.onAfterTyping(function(_) throw withChildren());
			case "generate-children":
				Context.onGenerate(function(_) throw withChildren());
			case "after-generate-children":
				Context.onAfterGenerate(function() throw withChildren());
			case "type-not-found-children":
				Context.onTypeNotFound(function(_) throw withChildren());
			case _:
				throw "no case " + name;
		}
	}
	#end

	public static macro function throwChildren():Expr {
		throw withChildren();
	}
}
