import haxe.macro.Context;

class MGM {
	public static macro function load(name:String) {
		Context.getModule(name);
		return macro null;
	}
}
