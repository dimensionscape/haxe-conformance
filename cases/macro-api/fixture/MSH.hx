import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class MSH {
	static var out:Array<String> = null;

	static function say(s:String) {
		if (out != null) out.push(s) else Sys.println(s);
	}

	static function show(label:String, o:Dynamic) {
		var fs = Reflect.fields(o);
		fs.sort(Reflect.compare);
		var parts = [];
		for (f in fs) {
			var v:Dynamic = Reflect.field(o, f);
			var s = if (v == null) "null" else if (Std.isOfType(v, Bool) || Std.isOfType(v, Int) || Std.isOfType(v, String)) Std.string(v) else if (Reflect.isFunction(v)) "fn" else if (Std.isOfType(v, Array)) "[" + (v : Array<Dynamic>).length + "]" else "obj";
			parts.push(f + "=" + s);
		}
		say(label + ": " + parts.join(" "));
	}

	public static macro function build():Array<Field> {
		for (f in Context.getBuildFields()) {
			show("Field " + f.name, f);
			switch (f.kind) {
				case FFun(fn):
					show("Function " + f.name, fn);
					for (a in fn.args) show("FunctionArg " + f.name + "." + a.name, a);
					for (tp in fn.params) show("TypeParamDecl " + f.name + "." + tp.name, tp);
				case _:
			}
		}
		return null;
	}

	public static macro function typed() {
		Context.onAfterTyping(function(types) {
			var blocks = new Map<String, Array<String>>();
			for (t in types) {
				out = [];
				var key = switch (t) {
					case TClassDecl(r): r.get().name;
					case TAbstract(r): r.get().name;
					case TTypeDecl(r): r.get().name;
					case TEnumDecl(r): r.get().name;
				};
				switch (t) {
				case TClassDecl(r) if (r.get().name == "C" || r.get().name == "Sub" || r.get().name == "Gen_Int"):
					var c = r.get();
					show("ClassType " + c.name, c);
					say("  kind " + c.name + ": " + Std.string(c.kind));
					say("  init " + c.name + ": " + (c.init != null));
					say("  overrides " + c.name + ": " + [for (o in c.overrides) o.get().name].join(","));
					say("  statics order " + c.name + ": " + [for (s in c.statics.get()) s.name].join(","));
					for (f in c.fields.get()) show("ClassField " + c.name + "." + f.name, f);
					for (f in c.statics.get()) show("ClassField static " + c.name + "." + f.name, f);
				case TAbstract(r) if (r.get().name == "Ab"):
					show("AbstractType " + r.get().name, r.get());
					say("  impl kind: " + Std.string(r.get().impl.get().kind));
				case TTypeDecl(r) if (r.get().name == "Td"):
					show("DefType " + r.get().name, r.get());
				case TEnumDecl(r) if (r.get().name == "En"):
					show("EnumType " + r.get().name, r.get());
					for (n in r.get().names) show("EnumField " + n, r.get().constructs.get(n));
					case _:
				}
				if (out.length > 0) blocks.set(key, out);
			}
			out = null;
			var keys = [for (k in blocks.keys()) k];
			keys.sort(Reflect.compare);
			for (k in keys) for (l in blocks.get(k)) Sys.println(l);
		});
		return macro null;
	}
}
