class MJITD {
	public static macro function go() {
		Sys.println("in macro");
		if (Sys.args().length > 1000) eval.luv.Dns.createNameRequest();
		return macro null;
	}
}
