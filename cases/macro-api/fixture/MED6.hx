private class MedErr6 extends haxe.Exception {}

private class MedPlain6 {
	public var v:Int;
	public function new(v) this.v = v;
	public function toString() return "Plain(" + v + ")";
}

private enum MedKind6 { Bad(s:String); }

class MED6 {
	static function t(label:String, f:Void->Dynamic) {
		var r = try {
			var v:Dynamic = f();
			"= " + Std.string(v);
		} catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " " + r);
	}

	static function describe(e:Dynamic):String {
		return Std.string(e) + " / " + Type.getClassName(Type.getClass(e)) + " / isEx " + Std.isOfType(e, haxe.Exception);
	}

	public static macro function run() {
		t("string as Exception", () -> try throw "boom" catch (e:haxe.Exception) describe(e) + " msg " + e.message);
		t("string as ValueException", () -> try throw "boom" catch (e:haxe.ValueException) describe(e) + " value " + e.value);
		t("string as String", () -> try throw "boom" catch (e:String) describe(e));
		t("string as Dynamic", () -> try throw "boom" catch (e:Dynamic) describe(e));
		t("int as Int", () -> try throw 5 catch (e:Int) describe(e));
		t("int as String then Dynamic", () -> try throw 5 catch (e:String) "string " + e catch (e:Dynamic) "dyn " + describe(e));
		t("plain as Exception", () -> try throw new MedPlain6(1) catch (e:haxe.Exception) describe(e) + " msg " + e.message);
		t("plain as Plain", () -> try throw new MedPlain6(2) catch (e:MedPlain6) describe(e));
		t("enum as Exception", () -> try throw Bad("x") catch (e:haxe.Exception) describe(e) + " msg " + e.message);
		t("enum as Kind", () -> try throw Bad("y") catch (e:MedKind6) describe(e));
		t("MyErr as Exception", () -> try throw new MedErr6("m1") catch (e:haxe.Exception) describe(e) + " msg " + e.message);
		t("MyErr as MyErr", () -> try throw new MedErr6("m2") catch (e:MedErr6) describe(e));
		t("MyErr as Dynamic", () -> try throw new MedErr6("m3") catch (e:Dynamic) describe(e));
		t("MyErr as String", () -> try throw new MedErr6("m4") catch (e:String) "string" catch (e:haxe.Exception) "ex " + e.message);
		t("Exception as Dynamic", () -> try throw new haxe.Exception("e1") catch (e:Dynamic) describe(e));
		t("ValueException thrown", () -> try throw new haxe.ValueException("v1") catch (e:String) "string " + e catch (e:Dynamic) "dyn " + describe(e));
		t("ValueException as VE", () -> try throw new haxe.ValueException(7) catch (e:haxe.ValueException) describe(e) + " value " + e.value);
		t("rethrow wrapped", () -> try { try throw "inner" catch (e:haxe.Exception) throw e; } catch (e:String) "outer string " + e catch (e:Dynamic) "outer dyn " + describe(e));
		t("rethrow native", () -> try { try throw "inner2" catch (e:Dynamic) throw e; } catch (e:haxe.Exception) "outer ex " + e.message);
		t("previous", () -> try { try throw "first" catch (e:haxe.Exception) throw new haxe.Exception("second", e); } catch (e:haxe.Exception) e.message + " <- " + (e.previous == null ? "null" : e.previous.message));
		t("details", () -> try throw new haxe.Exception("d") catch (e:haxe.Exception) e.details().split("\n")[0]);
		t("native of wrapped", () -> try throw "n" catch (e:haxe.Exception) Std.string(e.native));
		t("unwrap", () -> try throw "u" catch (e:haxe.Exception) Std.string(@:privateAccess e.unwrap()));
		t("null thrown", () -> try throw null catch (e:haxe.Exception) "ex " + e.message catch (e:Dynamic) "dyn " + e);
		t("catch order", () -> try throw "o" catch (e:Int) "int" catch (e:haxe.Exception) "ex" catch (e:String) "string");
		t("any", () -> try throw 3.5 catch (e:Any) Std.string(e));
		t("exceptionStack type", () -> { try throw "s" catch (e:Dynamic) {}; haxe.CallStack.exceptionStack().length >= 0; });
		t("nested finally-like", () -> { var log = []; try { try throw "a" catch (e:String) { log.push("caught " + e); throw "b"; } } catch (e:String) log.push("outer " + e); log.join(";"); });
		t("error in catch type test", () -> try throw new MedPlain6(3) catch (e:MedErr6) "myerr" catch (e:MedPlain6) "plain " + e.v);
		return macro null;
	}
}
