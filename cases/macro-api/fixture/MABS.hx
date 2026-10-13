import haxe.macro.Context;
import haxe.macro.Expr;

class MABS {
	public static function show():Array<Field> {
		var fs = Context.getBuildFields();
		Sys.println("-- build " + Context.getLocalClass().get().name);
		for (f in fs) {
			var acc = [for (a in f.access) Std.string(a)].join(",");
			var meta = [for (m in f.meta) m.name].join(",");
			var args = switch (f.kind) {
				case FFun(fn): [for (a in fn.args) a.name + "@" + (a.meta == null ? "" : [for (m in a.meta) m.name].join("/"))].join(",");
				case FVar(_, e): "var" + (e == null ? "" : "=" + haxe.macro.ExprTools.toString(e));
				case FProp(g, s, _, _): "prop(" + g + "," + s + ")";
			};
			Sys.println(f.name + " acc=[" + acc + "] meta=[" + meta + "] args=[" + args + "]");
		}
		return null;
	}

	public static function addValues():Array<Field> {
		var fs = Context.getBuildFields();
		var p = Context.currentPos();
		fs.push({name: "Blue", pos: p, kind: FVar(null, null), access: []});
		if (Context.getLocalClass().get().name == "Color2_Impl_")
			fs.push({name: "Cyan", pos: p, kind: FVar(null, macro 40), access: []});
		return fs;
	}

	public static function typed() {
		Context.onAfterTyping(function(types) {
			for (t in types) switch (t) {
				case TClassDecl(c) if (StringTools.endsWith(c.get().name, "_Impl_") && c.get().module == "P"):
					Sys.println("-- typed " + c.get().name);
					for (cf in c.get().statics.get()) {
						var tv = switch (cf.expr()) {
							case {expr: TFunction(tf)}: " args=" + [for (a in tf.args) a.v.name + "@" + [for (m in a.v.meta.get()) m.name].join("/")].join(",");
							case _: "";
						};
						Sys.println(cf.name + " meta=[" + [for (m in cf.meta.get()) m.name].join(",") + "] type=" + haxe.macro.TypeTools.toString(cf.type) + tv);
					}
				case _:
			}
		});
	}
}
