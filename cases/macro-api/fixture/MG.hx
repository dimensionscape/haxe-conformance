import haxe.macro.Context;

class MG {
	static function p(v:Dynamic) Sys.println(Std.string(v));

	public static macro function jsonParseNull() { p(haxe.Json.parse(null)); return macro null; }
	public static macro function jsonParseEmpty() { p(haxe.Json.parse("")); return macro null; }
	public static macro function jsonParseOpenBrace() { p(haxe.Json.parse("{")); return macro null; }
	public static macro function jsonParseTrailingComma() { p(haxe.Json.parse("[1,]")); return macro null; }
	public static macro function jsonParseBadExponent() { p(haxe.Json.parse("1e")); return macro null; }
	public static macro function jsonParseBadUnicode() { p(haxe.Json.parse("\"\\u12\"")); return macro null; }
	public static macro function jsonParseTru() { p(haxe.Json.parse("tru")); return macro null; }
	public static macro function jsonParseTwoValues() { p(haxe.Json.parse("1 2")); return macro null; }
	public static macro function jsonParseSpaces() { p(haxe.Json.parse("  ")); return macro null; }
	public static macro function jsonParseNested() { p(haxe.Json.parse("{\"a\":[1,{\"b\":null}],\"c\":\"\\u00e9\"}").c); return macro null; }
	public static macro function jsonParseBigInt() { p(haxe.Json.parse("12345678901234")); return macro null; }
	public static macro function jsonParseNegZero() { p(haxe.Json.parse("-0")); return macro null; }
	public static macro function jsonStringifyNull() { p(haxe.Json.stringify(null)); return macro null; }
	public static macro function jsonStringifyFunction() { p(haxe.Json.stringify(function() return 1)); return macro null; }
	public static macro function jsonStringifyInfinity() { p(haxe.Json.stringify(Math.POSITIVE_INFINITY)); return macro null; }
	public static macro function jsonStringifyNaN() { p(haxe.Json.stringify(Math.NaN)); return macro null; }
	public static macro function jsonStringifyIndent() { p(haxe.Json.stringify({a: 1, b: [1, 2]}, null, "  ")); return macro null; }
	public static macro function jsonStringifyReplacer() { p(haxe.Json.stringify({a: 1, b: 2}, function(k, v) return k == "a" ? null : v)); return macro null; }
	public static macro function jsonStringifyEnum() { p(haxe.Json.stringify(haxe.ds.Option.Some(1))); return macro null; }
	public static macro function jsonStringifyMap() { p(haxe.Json.stringify(["a" => 1])); return macro null; }
	public static macro function jsonStringifyCycle() { var o:Dynamic = {}; o.self = o; p(haxe.Json.stringify(o)); return macro null; }
	public static macro function jsonStringifyControl() { p(haxe.Json.stringify("a\tb\u0001c")); return macro null; }

	public static macro function pathNull() { p(new haxe.io.Path(null).toString()); return macro null; }
	public static macro function pathEmpty() { var x = new haxe.io.Path(""); p(x.dir + "|" + x.file + "|" + x.ext + "|" + x.toString()); return macro null; }
	public static macro function pathWithoutExtensionNull() { p(haxe.io.Path.withoutExtension(null)); return macro null; }
	public static macro function pathJoinNull() { p(haxe.io.Path.join([null, "a"])); return macro null; }
	public static macro function pathJoinEmpty() { p(haxe.io.Path.join([])); return macro null; }
	public static macro function pathNormalizeUp() { p(haxe.io.Path.normalize("a/../../b/./c//d/")); return macro null; }
	public static macro function pathAddTrailingSlashEmpty() { p(haxe.io.Path.addTrailingSlash("") + "|" + haxe.io.Path.removeTrailingSlashes("a///")); return macro null; }
	public static macro function pathIsAbsoluteNull() { p(haxe.io.Path.isAbsolute(null)); return macro null; }
	public static macro function pathExtensionTar() { p(haxe.io.Path.extension("a.tar.gz") + "|" + haxe.io.Path.withoutDirectory("a/b/") + "|" + haxe.io.Path.directory("a")); return macro null; }
	public static macro function pathBackslashes() { var x = new haxe.io.Path("C:\\a\\b.c"); p(x.dir + "|" + x.file + "|" + x.ext + "|" + x.backslash); return macro null; }

	public static macro function listFirstEmpty() { var l = new List<Int>(); p(l.first() + "|" + l.last() + "|" + l.pop() + "|" + l.length); return macro null; }
	public static macro function listRemoveNull() { var l = new List<String>(); l.add("a"); l.add(null); p(l.remove(null) + "|" + l.length + "|" + l.toString()); return macro null; }
	public static macro function listMapNull() { var l = new List<Int>(); l.add(1); p(l.map(null)); return macro null; }
	public static macro function listFilterNull() { var l = new List<Int>(); l.add(1); p(l.filter(null)); return macro null; }
	public static macro function listJoinNull() { var l = new List<Int>(); l.add(1); l.add(2); p(l.join(null)); return macro null; }
	public static macro function listNested() { var l = new List<List<Int>>(); var i = new List<Int>(); i.add(1); l.add(i); p(l.toString() + "|" + l.first().first()); return macro null; }
	public static macro function listIterModify() { var l = new List<Int>(); l.add(1); l.add(2); var s = 0; for (x in l) { s += x; if (x == 1) l.add(3); } p(s); return macro null; }

	public static macro function templateNull() { p(new haxe.Template(null).execute({})); return macro null; }
	public static macro function templateUnterminated() { p(new haxe.Template("a ::x").execute({x: 1})); return macro null; }
	public static macro function templateMissingVar() { p(new haxe.Template("a ::x:: b").execute({})); return macro null; }
	public static macro function templateExecuteNull() { p(new haxe.Template("a ::x:: b").execute(null)); return macro null; }
	public static macro function templateIfForeach() { p(new haxe.Template("::if x::y::else::n::end:: ::foreach l::[::__current__::]::end::").execute({x: false, l: [1, 2]})); return macro null; }
	public static macro function templateUnknownMacro() { p(new haxe.Template("$$nope(1)").execute({})); return macro null; }
	public static macro function templateMacro() { p(new haxe.Template("$$f(::x::)").execute({x: 2}, {f: function(r, v) return "<" + v + ">"})); return macro null; }
	public static macro function templateBadExpr() { p(new haxe.Template("::(x +::").execute({x: 1})); return macro null; }

	public static macro function exceptionNullMessage() { var e = new haxe.Exception(null); p(e.message + "|" + e.details().length); return macro null; }
	public static macro function exceptionThrownUncaught() { throw new haxe.Exception("boom6"); return macro null; }
	public static macro function exceptionThrownStringCaught() { try throw "s" catch (e:haxe.Exception) p(e.message + "|" + e.previous); return macro null; }
	public static macro function exceptionStackString() { var e = new haxe.Exception("x"); p(e.stack.toString().length > 0); return macro null; }
	public static macro function exceptionWithPrevious() { var e = new haxe.Exception("outer", new haxe.Exception("inner")); p(e.previous.message + "|" + e.toString()); return macro null; }

	public static macro function dateToolsFormatNull() { p(DateTools.format(null, "%Y")); return macro null; }
	public static macro function dateToolsFormatUnknown() { p(DateTools.format(new Date(2020, 0, 1, 0, 0, 0), "%Q")); return macro null; }
	public static macro function dateToolsFormatDangling() { p(DateTools.format(new Date(2020, 0, 1, 0, 0, 0), "%")); return macro null; }
	public static macro function dateToolsParseNull() { p(DateTools.parse(null)); return macro null; }
	public static macro function dateToolsDeltaNull() { p(DateTools.delta(null, 1)); return macro null; }
	public static macro function dateToolsFormatAll() { p(DateTools.format(new Date(2020, 1, 3, 4, 5, 6), "%d/%m/%Y %H:%M:%S %j %w %y %b %B %a %A %I %p %e %%")); return macro null; }

	public static macro function intIteratorReversed() { var it = new IntIterator(3, 1); p(it.hasNext()); return macro null; }
	public static macro function intIteratorNull() { p(new IntIterator(null, null).hasNext()); return macro null; }

	public static macro function sysToolsQuoteNull() { p(haxe.SysTools.quoteUnixArg(null)); return macro null; }
	public static macro function sysToolsQuoteWinNull() { p(haxe.SysTools.quoteWinArg(null, true)); return macro null; }
	public static macro function sysToolsQuote() { p(haxe.SysTools.quoteUnixArg("a b'c") + "|" + haxe.SysTools.quoteWinArg("a \"b\" c\\", true) + "|" + haxe.SysTools.quoteUnixArg("")); return macro null; }

	public static macro function serializeNull() { p(haxe.Serializer.run(null)); return macro null; }
	public static macro function serializeFunction() { p(haxe.Serializer.run(function() return 1)); return macro null; }
	public static macro function serializeCycle() { var o:Dynamic = {a: 1}; o.self = o; p(haxe.Serializer.run(o)); return macro null; }
	public static macro function serializeNested() { p(haxe.Serializer.run({a: ([1, "s", null, true] : Array<Dynamic>), b: haxe.ds.Option.Some(2), c: ["k" => 1]})); return macro null; }
	public static macro function unserializeEmpty() { p(haxe.Unserializer.run("")); return macro null; }
	public static macro function unserializeBadChar() { p(haxe.Unserializer.run("x")); return macro null; }
	public static macro function unserializeTruncated() { p(haxe.Unserializer.run("i")); return macro null; }
	public static macro function unserializeObject() { p(haxe.Unserializer.run("oy1:ai1g").a); return macro null; }
	public static macro function unserializeBadRef() { p(haxe.Unserializer.run("ay1:aR5h")); return macro null; }
	public static macro function unserializeNull() { p(haxe.Unserializer.run(null)); return macro null; }
	public static macro function unserializeUnknownClass() { p(haxe.Unserializer.run("cy4:Nopeg")); return macro null; }
	public static macro function unserializeRoundTrip() { var s = haxe.Serializer.run({a: ([1, "s"] : Array<Dynamic>), b: haxe.ds.Option.Some(2)}); var v = haxe.Unserializer.run(s); p(s + "|" + v.a[1] + "|" + v.b); return macro null; }

	public static macro function base64DecodeBad() { p(haxe.crypto.Base64.decode("!!").length); return macro null; }
	public static macro function base64EncodeNull() { p(haxe.crypto.Base64.encode(null)); return macro null; }
	public static macro function base64RoundTrip() { p(haxe.crypto.Base64.encode(haxe.io.Bytes.ofString("ab")) + "|" + haxe.crypto.Base64.decode("YWI=").toString() + "|" + haxe.crypto.Base64.encode(haxe.io.Bytes.ofString("ab"), false)); return macro null; }
	public static macro function md5Null() { p(haxe.crypto.Md5.encode(null)); return macro null; }
	public static macro function hashesEmpty() { p(haxe.crypto.Md5.encode("") + "|" + haxe.crypto.Sha1.encode("") + "|" + haxe.crypto.Sha256.encode("") + "|" + haxe.crypto.Sha224.encode("")); return macro null; }
	public static macro function hmacNullKey() { p(new haxe.crypto.Hmac(SHA256).make(null, haxe.io.Bytes.ofString("x"))); return macro null; }
	public static macro function hmacMake() { p(new haxe.crypto.Hmac(MD5).make(haxe.io.Bytes.ofString("k"), haxe.io.Bytes.ofString("x")).toHex()); return macro null; }
	public static macro function baseCodeOddBase() { p(new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("abc")).encodeString("x")); return macro null; }
	public static macro function baseCodeRoundTrip() { var b = new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("0123456789abcdef")); p(b.encodeString("hi") + "|" + b.decodeString("6869")); return macro null; }
	public static macro function adlerCrcNull() { p(haxe.crypto.Adler32.make(null)); return macro null; }
	public static macro function adlerCrc() { p(haxe.crypto.Adler32.make(haxe.io.Bytes.ofString("abc")) + "|" + haxe.crypto.Crc32.make(haxe.io.Bytes.ofString("abc"))); return macro null; }

	public static macro function bytesInputNull() { p(new haxe.io.BytesInput(null).readByte()); return macro null; }
	public static macro function bytesInputEof() { var i = new haxe.io.BytesInput(haxe.io.Bytes.ofString("a")); i.readByte(); p(i.readByte()); return macro null; }
	public static macro function bytesInputEofCaught() { var i = new haxe.io.BytesInput(haxe.io.Bytes.ofString("a")); i.readByte(); try i.readByte() catch (e:haxe.io.Eof) p("eof:" + e); return macro null; }
	public static macro function bytesInputNegative() { p(new haxe.io.BytesInput(haxe.io.Bytes.ofString("abc")).readString(-1)); return macro null; }
	public static macro function bytesInputInt32Short() { p(new haxe.io.BytesInput(haxe.io.Bytes.ofString("abc")).readInt32()); return macro null; }
	public static macro function bytesInputPosLen() { var i = new haxe.io.BytesInput(haxe.io.Bytes.ofString("abcdef"), 2, 3); p(i.readString(3) + "|" + i.position + "|" + i.length); return macro null; }
	public static macro function bytesOutputNull() { var o = new haxe.io.BytesOutput(); o.writeString(null); p(o.getBytes().length); return macro null; }
	public static macro function bytesOutputRoundTrip() { var o = new haxe.io.BytesOutput(); o.writeInt32(-2); o.writeDouble(1.5); o.writeString("x"); var b = o.getBytes(); var i = new haxe.io.BytesInput(b); p(b.length + "|" + i.readInt32() + "|" + i.readDouble() + "|" + i.readString(1)); return macro null; }
}
