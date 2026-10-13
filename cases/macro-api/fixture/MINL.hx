import haxe.macro.Context;

class MINL {
	public static function typed() {
		Context.onAfterTyping(function(types) {
			for (t in types) switch (t) {
				case TClassDecl(c) if (c.get().name == "P"):
					for (cf in c.get().statics.get()) if (cf.name == "g")
						Sys.println(haxe.macro.TypedExprTools.toString(cf.expr(), true));
				case _:
			}
		});
	}
}
