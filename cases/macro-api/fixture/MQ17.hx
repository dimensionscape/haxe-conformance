class MQ17 {
	static function rec(n:Int):Int return n == 0 ? 0 : rec(n - 1) + 1;
	public static macro function d900() { Sys.println(rec(900)); return macro null; }
	public static macro function d995() { Sys.println(rec(995)); return macro null; }
	public static macro function d1005() { Sys.println(rec(1005)); return macro null; }
	public static macro function d1100() { Sys.println(rec(1100)); return macro null; }
}
