import haxe.macro.Context;

class MF {
	static function m2() return ["x" => 1, "y" => 2];
	public static macro function forIterable() { var it:Iterable<Int> = null; for (x in it) {} return macro null; }
	public static macro function forArray() { var a:Array<Int> = null; for (x in a) {} return macro null; }
	public static macro function forIterator() { var i:Iterator<Int> = null; for (x in i) {} return macro null; }
	public static macro function forKeyValue() { var m:Map<String, Int> = null; for (k => v in m) {} return macro null; }
	public static macro function foldNull() { Lambda.fold(null, function(x:Int, r:Int) return r, 0); return macro null; }
	public static macro function toFieldNull() { haxe.macro.MacroStringTools.toFieldExpr(null); return macro null; }
	public static macro function foldArray() { Sys.println(Lambda.fold([1, 2], function(x:Int, r:Int) return r + x, 0)); return macro null; }
	public static macro function mapKv() { var m:Map<String, Int> = null; m.keyValueIterator(); return macro null; }
	public static macro function stringMapKv() { var s:haxe.ds.StringMap<Int> = null; s.keyValueIterator(); return macro null; }
	public static macro function newKvIter() { var s = new haxe.ds.StringMap<Int>(); s.set("a", 1); var it = new haxe.iterators.MapKeyValueIterator(s); Sys.println(it.hasNext()); return macro null; }
	public static macro function newKvIterNull() { var it = new haxe.iterators.MapKeyValueIterator((null : haxe.ds.StringMap<Int>)); return macro null; }
	public static macro function stdIterExplicit() { var o = new haxe.iterators.MapKeyValueIterator<String, Int>(null); Sys.println("after"); return macro null; }
	public static macro function mapLoops() { var m = ["b" => 2, "a" => 1]; var ks = [for (k in m.keys()) k]; ks.sort(Reflect.compare); var vs = [for (v in m) v]; vs.sort(Reflect.compare); var kvs = [for (k => v in m) k + "=" + v]; kvs.sort(Reflect.compare); Sys.println(ks.join(",") + " " + vs.join(",") + " " + kvs.join(",")); return macro null; }
	public static macro function arrayIters() { var a = [1, 2, 3]; var it = a.iterator(); var s = 0; while (it.hasNext()) s += it.next(); var kv = [for (i => v in a) i * v]; Sys.println(s + " " + kv.join(",") + " " + Lambda.count(a) + " " + Lambda.array(m2()).length); return macro null; }
	public static macro function intMapKv() { var m = [1 => "a", 2 => "b"]; var kvs = [for (k => v in m) k + v]; kvs.sort(Reflect.compare); Sys.println(kvs.join(",")); var it = m.keyValueIterator(); Sys.println(it.hasNext()); return macro null; }
	public static macro function listAndDyn() { var l = new List<Int>(); l.add(1); l.add(2); var s = 0; for (x in l) s += x; var d:Dynamic = [4, 5]; var t = 0; for (x in (d : Array<Int>)) t += x; Sys.println(s + " " + t); return macro null; }
}
