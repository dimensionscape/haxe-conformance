import haxe.macro.Compiler;
import haxe.macro.Context;

class MTP {
	public static macro function patches() {
		Compiler.addMetadata("@:patched", "MTPT");
		Compiler.addMetadata("@:patched", "MTPA");
		Compiler.addMetadata("@:patched", "MTPC");
		Compiler.addMetadata("@:patched", "MTPE");
		switch (Context.getType("MTPT")) {
			case TType(t, _): Sys.println("typedef " + t.get().meta.has(":patched"));
			case _:
		}
		switch (Context.getType("MTPA")) {
			case TAbstract(a, _):
				Sys.println("abstract " + a.get().meta.has(":patched"));
				Sys.println("implementation " + a.get().impl.get().meta.has(":patched"));
			case _:
		}
		switch (Context.getType("MTPC")) {
			case TInst(c, _): Sys.println("class " + c.get().meta.has(":patched"));
			case _:
		}
		switch (Context.getType("MTPE")) {
			case TEnum(e, _): Sys.println("enum " + e.get().meta.has(":patched"));
			case _:
		}
		return macro null;
	}
}
