import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
using haxe.macro.Tools;

class ME {
	static function p(e:Expr) Sys.println(ExprTools.toString(e));
	static function pt(t:TypeDefinition) Sys.println(new haxe.macro.Printer().printTypeDefinition(t));
	public static macro function vNull() { p(macro $v{null}); return macro null; }
	public static macro function vFloatWhole() { p(macro $v{1.0}); return macro null; }
	public static macro function vFloatFrac() { p(macro $v{1.5}); return macro null; }
	public static macro function vNegInt() { p(macro $v{-1}); return macro null; }
	public static macro function vNegFloat() { p(macro $v{-2.5}); return macro null; }
	public static macro function vNaN() { p(macro $v{Math.NaN}); return macro null; }
	public static macro function vInfinity() { p(macro $v{Math.POSITIVE_INFINITY}); return macro null; }
	public static macro function vNegInfinity() { p(macro $v{Math.NEGATIVE_INFINITY}); return macro null; }
	public static macro function vBigFloat() { p(macro $v{1e21}); return macro null; }
	public static macro function vSmallFloat() { p(macro $v{1e-7}); return macro null; }
	public static macro function vBool() { p(macro $v{true}); return macro null; }
	public static macro function vString() { p(macro $v{"s"}); return macro null; }
	public static macro function vEmptyString() { p(macro $v{""}); return macro null; }
	public static macro function vArray() { p(macro $v{[1, "a", null]}); return macro null; }
	public static macro function vNested() { p(macro $v{[[1], [2, 3]]}); return macro null; }
	public static macro function vObject() { p(macro $v{{a: 1, b: "x"}}); return macro null; }
	public static macro function vObjectOrder() { p(macro $v{{z: 1, a: 2, m: 3}}); return macro null; }
	public static macro function vEnumNoArgs() { p(macro $v{haxe.ds.Option.None}); return macro null; }
	public static macro function vEnumArgs() { p(macro $v{haxe.ds.Option.Some(1)}); return macro null; }
	public static macro function vMap() { p(macro $v{["a" => 1]}); return macro null; }
	public static macro function vFunction() { p(macro $v{function() return 1}); return macro null; }
	public static macro function vClass() { p(macro $v{String}); return macro null; }
	public static macro function vDate() { p(macro $v{new Date(2020, 0, 1, 0, 0, 0)}); return macro null; }
	public static macro function vBytes() { p(macro $v{haxe.io.Bytes.ofString("ab")}); return macro null; }
	public static macro function vExpr() { p(macro $v{macro 1}); return macro null; }
	public static macro function vIntString() { p(macro $v{Std.string(12)}); return macro null; }
	public static macro function iPlain() { p(macro $i{"foo"}); return macro null; }
	public static macro function iSpaces() { p(macro $i{"foo bar"}); return macro null; }
	public static macro function iEmpty() { p(macro $i{""}); return macro null; }
	public static macro function iNull() { p(macro $i{null}); return macro null; }
	public static macro function iDotted() { p(macro $i{"a.b"}); return macro null; }
	public static macro function iTyped() { var s = "x"; Sys.println(Context.typeof(macro { var x = 1; $i{s}; }).toString()); return macro null; }
	public static macro function pPath() { p(macro $p{["a", "b", "c"]}); return macro null; }
	public static macro function pSingle() { p(macro $p{["a"]}); return macro null; }
	public static macro function pEmpty() { p(macro $p{[]}); return macro null; }
	public static macro function pNull() { p(macro $p{null}); return macro null; }
	public static macro function aArgs() { p(macro f($a{[macro 1, macro 2]})); return macro null; }
	public static macro function aEmpty() { p(macro f($a{[]})); return macro null; }
	public static macro function aNull() { p(macro f($a{null})); return macro null; }
	public static macro function aWithNullElement() { p(macro f($a{[macro 1, null]})); return macro null; }
	public static macro function aArrayDecl() { p(macro [$a{[macro 1, macro 2]}]); return macro null; }
	public static macro function aBlock() { p(macro { $a{[macro 1, macro 2]}; }); return macro null; }
	public static macro function aBlockEmpty() { p(macro { $a{[]}; }); return macro null; }
	public static macro function eNull() { p(macro 1 + $e{null}); return macro null; }
	public static macro function eBraceNull() { p(macro 1 + ${null}); return macro null; }
	public static macro function bBlock() { p(macro $b{[macro 1, macro 2]}); return macro null; }
	public static macro function bEmpty() { p(macro $b{[]}); return macro null; }
	public static macro function bNull() { p(macro $b{null}); return macro null; }
	public static macro function ctNull() { var ct:ComplexType = null; p(macro (x : $ct)); return macro null; }
	public static macro function ctVar() { var ct = macro :Int; p(macro var x:$ct = 1); return macro null; }
	public static macro function ctParam() { var ct = macro :String; p(macro new Map<$ct, Int>()); return macro null; }
	public static macro function ctParamNull() { var ct:ComplexType = null; p(macro new Map<$ct, Int>()); return macro null; }
	public static macro function ctHint() { var ct = macro :Array<Int>; p(macro function(a:$ct):$ct return a); return macro null; }
	public static macro function posMeta() { var pp = Context.makePosition({file: "Other.hx", min: 1, max: 2}); var e = macro @:pos(pp) 1; Sys.println(Context.getPosInfos(e.pos).file); return macro null; }
	public static macro function posMetaNull() { var pp:Position = null; var e = macro @:pos(pp) 1; Sys.println(e.pos == null); return macro null; }
	public static macro function reifyPos() { var e = macro 1; var i = Context.getPosInfos(e.pos); var c = Context.getPosInfos(Context.currentPos()); Sys.println(i.file + " " + (i.min == c.min)); return macro null; }
	public static macro function printFunction() { p(macro function f(a:Int, ?b:String = "x"):Void {}); return macro null; }
	public static macro function printArrow() { p(macro (a, b) -> a + b); return macro null; }
	public static macro function printVars() { p(macro var x:Int, y = 2); return macro null; }
	public static macro function printSwitchGuard() { p(macro switch (x) { case A(_) if (y): 1; case _: 2; }); return macro null; }
	public static macro function printForKeyValue() { p(macro for (k => v in m) f(k, v)); return macro null; }
	public static macro function printDoWhile() { p(macro do { x++; } while (x < 3)); return macro null; }
	public static macro function printCast() { p(macro cast(x, Int)); return macro null; }
	public static macro function printUntyped() { p(macro untyped x); return macro null; }
	public static macro function printCheckType() { p(macro (x : Int)); return macro null; }
	public static macro function printIs() { p(macro (x is Int)); return macro null; }
	public static macro function printNew() { p(macro new C<Int>(1)); return macro null; }
	public static macro function printMeta() { p(macro @:pure @a(1) x); return macro null; }
	public static macro function printTernary() { p(macro a ? b : c); return macro null; }
	public static macro function printStringInterp() { p(macro 'a$b${c.d}'); return macro null; }
	public static macro function printRegex() { p(macro ~/a+/gi); return macro null; }
	public static macro function printReturnVoid() { p(macro { return; }); return macro null; }
	public static macro function printThrow() { p(macro throw "x"); return macro null; }
	public static macro function printFieldCall() { p(macro a.b.c(1)); return macro null; }
	public static macro function tdClass() { var tp = {pack: [], name: "Base"}; pt(macro class C extends $tp implements I { var x:Int = 1; public function f() return x; }); return macro null; }
	public static macro function tdClassParams() { pt(macro class G<T:Base> { var t:T; }); return macro null; }
	public static macro function tdClassName() { var td = macro class X {}; Sys.println(td.name + " " + td.pack.length + " " + Context.getPosInfos(td.pos).file); return macro null; }
	public static macro function tdDefineAndUse() { Context.defineType(macro class Defined5 { public static function f() return 5; }); Sys.println(Context.getType("Defined5").toString()); return macro null; }
	public static macro function tdFieldsCount() { var td = macro class Y { var a:Int; function b() {} static var c = 1; }; Sys.println(td.fields.length + " " + td.fields[0].name + " " + Std.string(td.fields[2].access)); return macro null; }
}
