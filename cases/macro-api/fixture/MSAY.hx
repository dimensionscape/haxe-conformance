class MSAY {
	public static macro function say(s:String) {
		Sys.println("typed " + s);
		return macro null;
	}
}
