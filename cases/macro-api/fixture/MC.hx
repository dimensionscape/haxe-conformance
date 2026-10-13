import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;

class MC {
	public static macro function defineThenDefined() { Compiler.define("sweep3_flag", "v1"); Sys.println(Context.definedValue("sweep3_flag")); return macro null; }
	public static macro function defineTwice() { Compiler.define("sweep3_x", "1"); Compiler.define("sweep3_x", "2"); Sys.println(Context.definedValue("sweep3_x")); return macro null; }
	public static macro function allowPackageNull() { Compiler.allowPackage(null); return macro null; }
	public static macro function removeFieldNull() { Compiler.removeField(null, null); return macro null; }
	public static macro function setCustomJSGeneratorNull() { Compiler.setCustomJSGenerator(null); return macro null; }
	public static macro function addClassPathNull() { Compiler.addClassPath(null); return macro null; }
	public static macro function excludeFileNull() { Compiler.excludeFile(null); return macro null; }
	public static macro function patchTypesNull() { Compiler.patchTypes(null); return macro null; }
	public static macro function includeFileBadPosition() { Compiler.includeFile("MC.hx", "nowhere"); return macro null; }
	public static macro function flushDiskCacheCall() { Compiler.flushDiskCache(); return macro null; }
	public static macro function getConfigurationPlatform() { Sys.println(Compiler.getConfiguration().platform); return macro null; }
	public static macro function addNativeLibUnknown() { Compiler.addNativeLib("sweep3_nope.lib"); return macro null; }
	public static macro function addNativeLibNull() { Compiler.addNativeLib(null); return macro null; }
	public static macro function addNativeArgCall() { Compiler.addNativeArg("-sweep3"); return macro null; }
	public static macro function toStringNull() { Sys.println(haxe.macro.TypeTools.toString(null)); return macro null; }
	public static macro function positionMakeNegative() { var p = haxe.macro.PositionTools.make({file: "MC.hx", min: -5, max: -1}); Sys.println(haxe.macro.PositionTools.getInfos(p).min); return macro null; }
	public static macro function positionHerePrint() { Sys.println(haxe.macro.PositionTools.here().getInfos().file); return macro null; }
	public static macro function typeGetClassNonClass() { Sys.println(haxe.macro.TypeTools.getClass(Context.getType("Int")) == null); return macro null; }
}
