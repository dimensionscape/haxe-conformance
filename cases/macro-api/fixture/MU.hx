import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;

class MU {
	public static macro function typeNotFoundThrows() {
		Context.onTypeNotFound(function(s) { throw "tnf " + s; });
		return macro (null : nope.Missing);
	}
}
