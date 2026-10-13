package pk;

class NoCtor {
	public static var x = 1;
}

@:structInit class Si {
	public var a:Int;
}

class Pc {
	private function new() {}
}

abstract AbsNoNew(Int) {
	public function f() return this;
}
