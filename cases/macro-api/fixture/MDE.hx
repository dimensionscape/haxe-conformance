class MDE {
	public static macro function broken() { var x:Int = "s"; return macro null; }
	public static macro function fine() { Sys.println("ran"); return macro null; }
	public static macro function alsoBroken() { return nope5.Missing.x(); }
}
