import haxe.macro.Context;
import haxe.macro.Expr;

class MX {
	public static macro function constructs() {
		var e = switch (Context.getType("E")) { case TEnum(r, _): r.get(); case _: null; };
		Sys.println("exists A: " + e.constructs.exists("A"));
		Sys.println("keys: " + [for (k in e.constructs.keys()) k].join(","));
		Sys.println("get A: " + e.constructs.get("A").name);
		Sys.println("values: " + [for (c in e.constructs) c.name].join(","));
		return macro null;
	}

	public static macro function ctorParams() {
		var e = switch (Context.getType("E")) { case TEnum(r, _): r.get(); case _: null; };
		for (n in e.names) {
			var c = e.constructs.get(n);
			Sys.println(n + " params=" + c.params.length);
			for (p in c.params) switch (p.t) {
				case TInst(pc, _): Sys.println("  " + p.name + " meta=" + [for (m in pc.get().meta.get()) m.name].join(","));
				case _:
			}
		}
		return macro null;
	}

	public static macro function build():Array<Field> {
		var fs = Context.getBuildFields();
		for (f in fs) Sys.println("build " + f.name + " doc=" + haxe.Json.stringify(f.doc));
		return fs;
	}

	public static macro function typedDocs() {
		Context.onAfterTyping(function(types) {
			var out = [];
			for (t in types) switch (t) {
				case TClassDecl(r) if (r.get().name == "C"):
					var c = r.get();
					out.push("class C doc=" + haxe.Json.stringify(c.doc));
					for (f in c.fields.get()) out.push("field " + f.name + " doc=" + haxe.Json.stringify(f.doc));
					for (f in c.statics.get()) out.push("static " + f.name + " doc=" + haxe.Json.stringify(f.doc));
				case TEnumDecl(r) if (r.get().name == "E"):
					var e = r.get();
					out.push("enum E doc=" + haxe.Json.stringify(e.doc));
					for (n in e.names) out.push("ctor " + n + " doc=" + haxe.Json.stringify(e.constructs.get(n).doc));
				case TTypeDecl(r) if (r.get().name == "T"):
					out.push("typedef T doc=" + haxe.Json.stringify(r.get().doc));
				case TAbstract(r) if (r.get().name == "A"):
					out.push("abstract A doc=" + haxe.Json.stringify(r.get().doc));
				case _:
			}
			out.sort(Reflect.compare);
			for (l in out) Sys.println(l);
		});
		return macro null;
	}

	public static macro function definedDocs() {
		var p = Context.currentPos();
		Context.defineType({pack: [], name: "GenC", pos: p, doc: " gen class doc ", kind: TDClass(),
			fields: [{name: "f", doc: " gen field doc ", pos: p, kind: FVar(macro : Int), access: [APublic]},
				{name: "g", pos: p, kind: FVar(macro : Int), access: [APublic]}]});
		Context.defineType({pack: [], name: "GenE", pos: p, doc: " gen enum doc ", kind: TDEnum,
			fields: [{name: "X", doc: " ctor X doc ", pos: p, kind: FVar(null)}, {name: "Y", pos: p, kind: FVar(null)}]});
		var c = switch (Context.getType("GenC")) { case TInst(r, _): r.get(); case _: null; };
		Sys.println("GenC doc=" + haxe.Json.stringify(c.doc));
		for (f in c.fields.get()) Sys.println("GenC." + f.name + " doc=" + haxe.Json.stringify(f.doc));
		var e = switch (Context.getType("GenE")) { case TEnum(r, _): r.get(); case _: null; };
		Sys.println("GenE doc=" + haxe.Json.stringify(e.doc));
		for (n in e.names) Sys.println("GenE." + n + " doc=" + haxe.Json.stringify(e.constructs.get(n).doc));
		return macro null;
	}

	public static macro function alias() {
		Context.defineType({pack: [], name: "AliasInt", pos: Context.currentPos(), kind: TDAlias(macro : Int), fields: []});
		Sys.println("alias: " + haxe.macro.TypeTools.toString(Context.getType("AliasInt")) + " -> "
			+ haxe.macro.TypeTools.toString(Context.follow(Context.getType("AliasInt"))));
		return macro null;
	}

	public static macro function moduleFields() {
		var p = Context.currentPos();
		Context.defineModule("gen.Fields", [
			{pack: ["gen"], name: "answer", pos: p, kind: TDField(FVar(macro : Int, macro 42), [APublic]), fields: []},
			{pack: ["gen"], name: "twice", pos: p, kind: TDField(FFun({args: [{name: "x", type: macro : Int}], ret: macro : Int, expr: macro return x * 2}), [APublic]), fields: []}
		]);
		return macro null;
	}

	public static macro function definePacked(last:String, name:String) {
		Context.defineType({pack: ["p", last], name: name, pos: Context.currentPos(), kind: TDClass(), fields: []});
		return macro null;
	}

	public static macro function moduleTypes(path:String) {
		Sys.println(path + ": " + [for (t in Context.getModule(path)) haxe.macro.TypeTools.toString(t)].join(","));
		return macro null;
	}

	public static macro function typeByPath(path:String) {
		Sys.println(path + ": " + haxe.macro.TypeTools.toString(Context.getType(path)));
		return macro null;
	}

	public static macro function generateOrder() {
		Context.onGenerate(function(_) Sys.println("a (persistent=false)"), false);
		Context.onGenerate(function(_) Sys.println("b"));
		Context.onGenerate(function(_) Sys.println("c (persistent=false)"), false);
		Context.onGenerate(function(_) Sys.println("d"));
		return macro null;
	}

	public static macro function localVars(cls:String) {
		Context.onAfterTyping(function(types) {
			var out = [];
			for (t in types) switch (t) {
				case TClassDecl(r) if (r.get().name == cls):
					for (f in r.get().statics.get()) {
						var e = f.expr();
						if (e == null) continue;
						function walk(x:haxe.macro.Type.TypedExpr) {
							switch (x.expr) {
								case TVar(v, _):
									var ex = v.extra == null ? "null" : "{params=" + v.extra.params.length + " expr=" + (v.extra.expr != null) + "}";
									out.push(f.name + " " + v.name + " capture=" + v.capture + " extra=" + ex);
								case _:
							}
							haxe.macro.TypedExprTools.iter(x, walk);
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
