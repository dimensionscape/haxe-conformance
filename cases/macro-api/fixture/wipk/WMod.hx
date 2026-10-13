package wipk;

function modFn():Int return 1;

class WMod {
	public static function sfn():Int return 2;
	public static var sv:String = "x";
}

class Sub {
	public static function subFn():Float return 3.0;
}

enum En { A; B; C(i:Int); }

typedef TD = { x:Int };

private class Priv {}

class Ext {
	public static function twice(i:Int):Int return i * 2;
}
