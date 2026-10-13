import haxe.macro.Context;
import haxe.macro.Expr;
class MCN {
	static function shape(v:Dynamic, depth:Int = 0):String {
		if (v == null) return "null";
		if (Std.isOfType(v, Bool) || Std.isOfType(v, Int) || Std.isOfType(v, Float)) return Std.string(v);
		if (Std.isOfType(v, String)) return '"' + v + '"';
		if (depth > 3) return "..";
		if (Reflect.isEnumValue(v)) return Type.enumConstructor(v) + "(" + [for (p in Type.enumParameters(v)) shape(p, depth + 1)].join(",") + ")";
		if (Std.isOfType(v, Array)) return "[#" + (v : Array<Dynamic>).length + (v.length > 0 ? " " + shape(v[0], depth + 1) : "") + "]";
		if (Reflect.isFunction(v)) return "fn";
		if (Std.isOfType(v, haxe.ds.StringMap)) { var ks = [for (k in (v : haxe.ds.StringMap<Dynamic>).keys()) k]; return "StringMap#" + ks.length; }
		var fs = Reflect.fields(v);
		fs.sort(Reflect.compare);
		return "{" + [for (f in fs) f + ":" + shape(Reflect.field(v, f), depth + 1)].join(" ") + "}";
	}
	static function line(label:String, f:Void->Dynamic) {
		var s = try shape(f()) catch (e:Dynamic) "THROWS " + Std.string(e);
		Sys.println(label + " = " + s);
	}
	public static macro function probe(e:Expr) {
		line("currentPos", () -> Context.getPosInfos(Context.currentPos()));
		line("makePosition", () -> Context.getPosInfos(Context.makePosition({min: 1, max: 5, file: "x.hx"})));
		line("getLocalClass", () -> Context.getLocalClass());
		line("getLocalClass.get.name", () -> Context.getLocalClass().get().name);
		line("getLocalType", () -> Context.getLocalType());
		line("getLocalModule", () -> Context.getLocalModule());
		line("getLocalMethod", () -> Context.getLocalMethod());
		line("getLocalUsing", () -> Context.getLocalUsing());
		line("getLocalImports", () -> Context.getLocalImports());
		line("getLocalVars", () -> Context.getLocalVars());
		line("getLocalTVars", () -> Context.getLocalTVars());
		line("getDefines.has.macro", () -> Context.getDefines().exists("macro"));
		line("getType String", () -> Context.getType("String"));
		line("getModule StringMap", () -> Context.getModule("haxe.ds.StringMap"));
		line("typeof 1", () -> Context.typeof(macro 1));
		line("typeof arr", () -> Context.typeof(macro [1, 2]));
		line("typeExpr", () -> Context.typeExpr(macro 1 + 1));
		line("toComplexType Int", () -> Context.toComplexType(Context.getType("Int")));
		line("getExpectedType", () -> Context.getExpectedType());
		line("getCallArguments", () -> Context.getCallArguments());
		line("getMacroStack", () -> Context.getMacroStack());
		line("containsDisplayPosition", () -> Context.containsDisplayPosition(Context.currentPos()));
		line("getDisplayMode", () -> Context.getDisplayMode());
		line("resolvePath Main.hx", () -> Context.resolvePath("Main.hx").split("\\").pop().split("/").pop());
		line("getMessages", () -> Context.getMessages());
		line("parse", () -> Context.parse("a.b(1)", Context.currentPos()));
		line("parseInlineString", () -> Context.parseInlineString("{ x; }", Context.currentPos()));
		line("meta get", () -> Context.getLocalClass().get().meta.get());
		line("meta extract", () -> Context.getLocalClass().get().meta.extract(":keep"));
		line("meta has", () -> Context.getLocalClass().get().meta.has(":keep"));
		line("follow", () -> Context.follow(Context.getType("Null"), false));
		line("unify", () -> Context.unify(Context.getType("Int"), Context.getType("Float")));
		line("isAbstract? getType Int", () -> Context.getType("Int"));
		line("signature", () -> Context.signature(1).length);
		line("storeTypedExpr", () -> Context.storeTypedExpr(Context.typeExpr(macro 1)));
		line("getPosInfos e", () -> Context.getPosInfos(e.pos));
		return macro null;
	}
}
