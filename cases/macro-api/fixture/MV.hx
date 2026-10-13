import haxe.macro.Context;
import haxe.macro.Expr;

class MV {
	public static macro function dumpGenerated(prefix:String, withPos:Bool) {
		Context.onAfterTyping(function(types) {
			var out = [];
			for (t in types) switch (t) {
				case TClassDecl(r):
					var c = r.get();
					if (!StringTools.startsWith(c.name, prefix)) continue;
					var all = c.fields.get().concat(c.statics.get());
					if (c.constructor != null) all.push(c.constructor.get());
					for (f in all) {
						var n = 0;
						for (o in [f].concat(f.overloads.get())) {
							for (m in o.meta.get()) if (m.name == ":value" || m.name == ":haxe.arguments")
								out.push(c.name + "." + f.name + "#" + n + " " + m.name + " "
									+ [for (p in m.params) haxe.macro.ExprTools.toString(p)].join(",")
									+ (withPos ? " " + Std.string(m.pos) : ""));
							n++;
						}
					}
				case _:
			}
			out.sort(Reflect.compare);
			for (l in out) Sys.println(l);
		});
		return macro null;
	}

	public static macro function dumpLocalFunctions(cls:String) {
		Context.onAfterTyping(function(types) {
			var out = [];
			for (t in types) switch (t) {
				case TClassDecl(r) if (r.get().name == cls):
					for (f in r.get().statics.get()) {
						var e = f.expr();
						if (e == null) continue;
						function walk(e:haxe.macro.Type.TypedExpr) {
							switch (e.expr) {
								case TVar(v, init) if (init != null && init.expr.match(TFunction(_))):
									var ms = v.meta == null ? [] : v.meta.get();
									out.push(f.name + " " + v.name + " [" + [for (m in ms) m.name + "(" + [for (p in m.params) haxe.macro.ExprTools.toString(p)].join(",") + ")"].join(" ") + "]");
								case _:
							}
							haxe.macro.TypedExprTools.iter(e, walk);
						}
						walk(e);
					}
				case _:
			}
			out.sort(Reflect.compare);
			for (l in out) Sys.println(l);
		});
		return macro null;
	}
}
