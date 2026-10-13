class MJIT {
	public static macro function go() {
		Sys.println("in macro");
		if (Sys.args().length > 1000) MJITHelper.missing();
		return macro null;
	}
}

class MJITHelper {
	public static extern function missing():Int;
}
