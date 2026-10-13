package ord;

@:deprecated
typedef UrlObj = { b:Int };

extern class Url {
	static function parse(s:String):UrlObj;
	static function format(o:UrlObj):String;
}
