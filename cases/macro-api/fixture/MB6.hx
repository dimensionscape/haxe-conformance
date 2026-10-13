import haxe.macro.Context;
import haxe.macro.Expr;
class MB6 {
	public static macro function same():Array<Field> { return Context.getBuildFields(); }
}
