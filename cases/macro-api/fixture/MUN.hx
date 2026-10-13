import haxe.macro.Context;
import haxe.macro.TypeTools;

class MUN {
	public static macro function unify() {
		for (pair in [["Int", "Float"], ["Float", "Int"], ["String", "Dynamic"], ["Dynamic", "String"],
				["MUN.AB", "Array"], ["Int", "MUN.AF"], ["MUN.AF", "Int"], ["Int", "MUN.AF2"], ["MUN.AF2", "Int"],
				["MUN.AF2", "Float"], ["String", "MUN.AF2"], ["MUN.NI", "Int"], ["Int", "MUN.NI"],
				["MUN.S1", "MUN.S2"], ["MUN.S2", "MUN.S1"], ["MUN.E1", "EnumValue"], ["Bool", "Int"]])
			Sys.println(pair[0] + " -> " + pair[1] + ": " + Context.unify(Context.getType(pair[0]), Context.getType(pair[1])));
		var m = Context.makeMonomorph();
		Sys.println("mono -> Int: " + Context.unify(m, Context.getType("Int")) + " then " + TypeTools.toString(Context.follow(m)));
		return macro null;
	}
}

abstract AB(Array<Int>) {}

abstract AF(Int) from Int to Int {}

abstract AF2(String) {
	@:from static function fromInt(i:Int):AF2 return new AF2(Std.string(i));
	@:to function toFloat():Float return 1.5;
	function new(s) this = s;
}

typedef NI = Null<Int>;
typedef S1 = {a:Int};
typedef S2 = {a:Int, b:String};

enum E1 { A; }
