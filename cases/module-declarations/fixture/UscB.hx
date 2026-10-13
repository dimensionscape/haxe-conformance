class UscB {
	public static function b() {
		var c = haxe.macro.Context.getLocalClass();
		if (c != null) Sys.println("built " + c.toString());
		return null;
	}
}
