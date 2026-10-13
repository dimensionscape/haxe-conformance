package mm;
import haxe.macro.Context;
class MMAllow {
	public static macro function allowThenUse() { haxe.macro.Compiler.allowPackage("cpp"); Context.getType("cpp.Lib"); Sys.println("ok"); return macro null; }
}
