class MT {
	#if macro
	public static function make():haxe.macro.Type {
		return haxe.macro.Context.getType("String");
	}

	public static function makeComplex():haxe.macro.Expr.ComplexType {
		return macro : Int;
	}

	public static function makePicked(n:Int):haxe.macro.Type {
		return haxe.macro.Context.getType(n == 1 ? "String" : "Int");
	}

	public static function makeNothing():haxe.macro.Type {
		return null;
	}

	public static function makeDefined():haxe.macro.Type {
		haxe.macro.Context.defineType({
			pack: [], name: "MTMade", pos: haxe.macro.Context.currentPos(),
			kind: TDClass(null, null, false, false, false),
			fields: [{
				name: "hi", pos: haxe.macro.Context.currentPos(), access: [AStatic, APublic],
				kind: FFun({args: [], ret: null, expr: macro return 42})
			}]
		});
		return haxe.macro.Context.getType("MTMade");
	}

	public static function makeRecursive():haxe.macro.Type {
		return haxe.macro.Context.getType("T");
	}
	#end
}
