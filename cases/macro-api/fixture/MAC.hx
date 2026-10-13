import haxe.macro.Context;
import haxe.macro.Expr;

class MAC {
	public static macro function build():Array<Field> {
		var c = Context.getLocalClass().get();
		var s = c.superClass == null ? null : c.superClass.t.get();
		Sys.println(c.name + " own ctor: " + (c.constructor != null) + " super " + (s == null ? "none" : s.name + " ctor: " + (s.constructor != null)));
		if (s != null && s.constructor != null) {
			var cf = s.constructor.get();
			Sys.println("  super ctor type: " + haxe.macro.TypeTools.toString(cf.type) + " meta=" + [for (m in cf.meta.get()) m.name].join(","));
		}
		return null;
	}
}
