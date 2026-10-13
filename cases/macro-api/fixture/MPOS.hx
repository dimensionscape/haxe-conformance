import haxe.macro.Context;
import haxe.macro.Type;

class MPOS {
	public static function run(className:String, afterFilters:Bool) {
		function show(c:ClassType) {
			var all = c.statics.get().concat(c.fields.get());
			if (c.constructor != null) all.unshift(c.constructor.get());
			for (cf in all) {
				var e = cf.expr();
				if (e == null) continue;
				Sys.println(cf.name);
				function walk(e:TypedExpr, depth:Int) {
					var pi = Context.getPosInfos(e.pos);
					Sys.println(StringTools.lpad("", " ", depth) + pi.min + "-" + pi.max + " " + e.expr.getName());
					haxe.macro.TypedExprTools.iter(e, x -> walk(x, depth + 1));
				}
				walk(e, 1);
			}
		}
		if (afterFilters) Context.onGenerate(function(types) {
			for (t in types) switch (t) {
				case TInst(c, _) if (c.get().name == className): show(c.get());
				case _:
			}
		}) else Context.onAfterTyping(function(types) {
			for (t in types) switch (t) {
				case TClassDecl(c) if (c.get().name == className): show(c.get());
				case _:
			}
		});
	}
}
