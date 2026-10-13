import haxe.macro.Context;

class MHB {
	static function f(v:Dynamic) {}
	public static macro function bad() { try {} catch (e:nope.Nope) f(e); return macro null; }
}
