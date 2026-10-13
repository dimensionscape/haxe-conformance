#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class MB {
#if macro
	public static var notAMethod:Int = 1;
#end
}
