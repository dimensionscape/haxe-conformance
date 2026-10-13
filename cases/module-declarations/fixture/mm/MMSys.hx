package mm;
import haxe.macro.Context;
class MMSys {
	public static macro function useSys() { Sys.println(sys.FileSystem.exists("x")); return macro null; }
}
