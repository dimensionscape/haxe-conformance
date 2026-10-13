import haxe.macro.Context;

class MAT {
	static var defined = false;

	public static macro function order() {
		Context.onAfterTyping(function(_) Sys.println("first"));
		Context.onAfterTyping(function(_) Sys.println("second"));
		return macro null;
	}

	public static macro function rounds() {
		Context.onAfterTyping(function(types) {
			var names = [];
			for (t in types) switch (t) {
				case TClassDecl(c) if (c.get().name.indexOf("Gen") == 0): names.push(c.get().name);
				case _:
			}
			names.sort(Reflect.compare);
			Sys.println("called with " + (types.length > 50 ? "many" : Std.string(types.length)) + " types, gen: " + names.join(","));
			if (!defined) {
				defined = true;
				Context.defineType({pack: [], name: "GenA", pos: Context.currentPos(), kind: TDClass(), fields: []});
			}
		});
		return macro null;
	}

	public static macro function nullSafetyReporters() {
		var on:Dynamic = @:privateAccess Context.load("on_null_safety_report", 1);
		on(function(errors:Array<{msg:String, pos:haxe.macro.Expr.Position}>)
			Sys.println("A " + [for (e in errors) Context.getPosInfos(e.pos).min].join(",")));
		on(function(errors:Array<{msg:String, pos:haxe.macro.Expr.Position}>) Sys.println("B " + errors.length));
		return macro null;
	}
}
