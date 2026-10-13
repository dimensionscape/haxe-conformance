package mm;
import haxe.macro.Context;
class MMRules {
	public static macro function rules() { var c = haxe.macro.Compiler.getConfiguration(); var ks = [for (k => v in c.packageRules) k + ":" + Std.string(v)]; ks.sort(Reflect.compare); Sys.println(ks.join(" ")); return macro null; }
}
