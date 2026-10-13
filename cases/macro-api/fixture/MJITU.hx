class MJITU {
	public static macro function go() {
		Sys.println("in macro");
		if (Sys.args().length > 1000) {
			var c:eval.luv.ConnectedUdp = null;
			c.trySend([]);
		}
		return macro null;
	}
}
