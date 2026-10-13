import haxe.macro.Context;
import haxe.macro.Expr;
class MFO {
	public static macro function build():Array<Field> {
		var fs = Context.getBuildFields();
		for (f in fs) {
			Sys.println("Field: " + Reflect.fields(f).join(","));
			switch (f.kind) {
				case FFun(fn): Sys.println("Function: " + Reflect.fields(fn).join(",")); for (a in fn.args) Sys.println("FunctionArg: " + Reflect.fields(a).join(","));
				case FVar(t, e):
					switch (t) { case TPath(p): Sys.println("TypePath: " + Reflect.fields(p).join(",")); case _: }
					if (e != null) Sys.println("Expr: " + Reflect.fields(e).join(","));
				case _:
			}
		}
		var c = Context.getLocalClass().get();
		Sys.println("ClassType: " + Reflect.fields(c).join(","));
		Sys.println("typeExpr: " + Reflect.fields(Context.typeExpr(macro 1)).join(","));
		Sys.println("imports: " + Reflect.fields(Context.getLocalImports()[0]).join(","));
		return null;
	}
}
