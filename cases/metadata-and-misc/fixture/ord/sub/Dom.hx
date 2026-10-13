package ord.sub;

@:deprecated
typedef DomErr = { a:Int };

extern class Dom {
	static function handle(e:DomErr):Void;
}
