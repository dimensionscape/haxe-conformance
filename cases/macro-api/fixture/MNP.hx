import haxe.macro.Context;
import haxe.macro.Expr;
class MNP {
	public static macro function bare():Expr return {expr: ENew({pack: [], name: "Nope"}, []), pos: Context.currentPos()};
	public static macro function reified():Expr return macro new Nope2();
	public static macro function withArgs():Expr return macro new Nope4(1, "x");
	public static macro function roundTrip(e:Expr):Expr return e;
}
