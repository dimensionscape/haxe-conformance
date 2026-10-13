class MEXIT {
	public static macro function expr() {
		Sys.println("exiting");
		Sys.exit(2);
		return macro null;
	}

	public static macro function build():Array<haxe.macro.Expr.Field> {
		Sys.println("build");
		Sys.exit(4);
		return null;
	}

	public static macro function buildNative():Array<haxe.macro.Expr.Field> {
		var f:Dynamic = 5;
		eval.luv.Timer.init(eval.luv.Loop.init().resolve()).resolve().start(f, 1);
		return null;
	}
}
