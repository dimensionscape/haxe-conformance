import haxe.io.Bytes;
#if macro
import mbedtls.SslAuthmode;
import mbedtls.SslEndpoint;
import mbedtls.SslPreset;
import mbedtls.SslTransport;
#end

class MSSL {
	static var PRIV = "-----BEGIN RSA PRIVATE KEY-----\nProc-Type: 4,ENCRYPTED\nDEK-Info: DES-EDE3-CBC,AE34A89AA63FDD47\n\n/kUM/ePW36lW0pg7X6bujFLISlf6r2u28VJ6sZ2TzS4o6x6o8imzX7q0lmTMYCJa\nfpjWp9DJPhY6p1a6uEJoyuIJIWKeb1Hc40cpyrC216kHSkdbizlkcqBVGvSZfL1f\nKTuLgM3JvRi/i0YYxI6FlLZcAHPQ5mIwr7Jf45azcotNHKlEf0y5RJEzoOGfAAgK\nwsVTU7tvJ7E0NJy+DxTuNKzja95jDiCA/DtCqOHVBRkw1sFSOQEISza5HnPce9PG\n/bjwI/I9c/UV0hSRo2clSOslljnH3HsroZw94Ek9OJbHWSTcY7/YHyXVI5bbcU9d\nfOATh3RLuaRQ6NxgHGLVbcJL6cM+ZqSnLDEAft3UFfxd1KOFDKj6XCJtnJd/UZYv\nrq4hEY6RJI8SzbUs3LVnVrNaZjLop+tCK45a2kwWuZztGGMGPZSn3VP0VAts2Iyo\n221a9NN+gzQ2CekU/cz1hi8SiRN6g7zwZwwcFZwFUzTdt4ARZTDbf0GSBaqp9QFK\nt8LpPR0SsKOFcrpyFDTJ0Ik0YS9K0hruvYWa1g2bcYVRK5hI1qVPgBP46+CwocPA\nbUOdenpC3wpAeqrPsRY9jCYc1yeClZaceLe7aRUJkOggyrzRzDn6kbO20IuSRXBS\nCSgYNOnoQD2tSqEXq5ui2Ti/JL7qybHYNG4GMhz3waKyyOl1JdmyvqxI91kp2Iwh\nSwG1KfWejIvL1UUvuyZI4qrzUnub498vEmqe2l3U7yS8ggu6D3k6lT42LQ6Rzgey\nSqOvWugED/b91dP5AXPq0VJAT1A0Rn75YYYpBuq8SFZRfXmFr5K3qgeCFA3hB+TD\nqVHxjirxIGM6umV8tJXWeRLWgIPRoBjTi6zYvckhy5hDCw17GCgwe9jHb3xDfpyx\nuoTYcPADk4kwq0ylsp4HIsfZ5AjPMDEXi+2A0a9wREJpK8jAF56SaSHRIAfQNeGn\niuihj9fqM6pDL4jx0lIAMH4c8vypraGFTWO4amMtd/67tVMhO4V1el5w61U5qXXl\nRYFVQ6TExpX3uKXgomIcWvs214c1ZOdmpC/OZciqv1ga8+zaswQ4zsIuAQD8BYRe\nTBEwNUhRg5PqE0Z6I+beWtkD1giLeaKweJ0Dymh9D2mhX7e1WJIuI9j0m8+kT6/k\njURamNaQYLDnIOpUDPm4TqQ4kH6PYX/I7XHx78cfL+Ki58tyCR0Kgk8TJH4o05pZ\nhujvigWTp7WM4bL/0GGVTTsGGT36a300rronkOJGh1gWX9HtSAk3QdnxiNJqrhP6\nZP3mWHaa/qZUr2tfvk5pg7vQ9u1Qny9Xo7JkrNWMUCfvgimYE37BgO8uGsKwjx1a\nIMsFlGStF+KKUeCrt2nI+JUFPvQtu//kmnHuqP4dNvr3GTHigS7t2MFYHzKpyIsC\nObNZXrv+q5eMpineWTTetTwfMXX/4oVfAED415i2frAbDeGEH7MFEZcJmkcQY88M\nwuvjR5hB9UTMYQPZvRVysrTzCBskKVafMarAeGat42gHVDBKTc5FJ3D4FeQnHN9T\nLidMKXdXhV2XNArLSksIaqO3HWiCVwHCsXhwNuYaHuwi2/S2pS6uuzur74fQLYjw\n-----END RSA PRIVATE KEY-----\n";
	static var PUB64 = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy0+P8DyzLT52TQ6v7Z8eScRP6QaTQUUa7kyN9mDi2GgvELZB2caBC8uNDNkovLSzMMnM2c3aMkNmKz0NN+IsMV8uFMX2mIiTBDzGuvR6NfEiUIenfcn1ZeX7cWsu0DpJtPCME8nc7MH6FxvK2zZalXO2a2cIDUicI0a4Z1kRaRym2UE+2V6hoT/g5/1e9AxAdCmDzMj4RMhWjRP2XVAZN/6toYMfLmu1aWZr6KJscsS4mG+xDPs3DuCtswLAaMLIrdLNT75ULN170PggUbMSbN/U/SPBjVokq1AX9eVg+0ncrMH/wKA3XosK9Wl10eAnPlnnLm6Wo6T59wJVfOI0xQIDAQAB";
	static var CERTS = "-----BEGIN CERTIFICATE-----\nMIIC5DCCAcygAwIBAgIJAJWLSmriPMaaMA0GCSqGSIb3DQEBCwUAMBYxFDASBgNV\nBAoMC1Rlc3QgRGV2IENBMB4XDTE2MDQwNTE5MzE0NVoXDTE3MDQwNTE5MzE0NVow\nEjEQMA4GA1UEAwwHZm9vLmJhcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC\nggEBAOPjbM5TJTt6jw6Uc7Yz9/60Krl9zK2Ym1iwO72dXyMKhE+PgxbVPzk4rW+G\nyzZ1f3FsOhR/eYNjnYFzf3Zy6sQSZYAGgN50pEBp/toHJOEZs226x6b9TzkG5iTf\n3LQocdQKJ4QiMWPah6pktin+3QShIku6Re3AGQd1SvierdaHZog5iolxhj79xIKn\nNTTwIC1G5MPSp3GR+V/QK+OtKcWq1UK2gW/Er5EcwpqIkipGmDO6NfhEsaMNeavl\nMcjyByacnlcgfAbYZjjAR7Ai14538Pac/GElhj8NAu9iz9+ZZknqjtIEPEMDDKbN\nlDH6LSEAwM5eWF7C/2FWQ5R3CMECAwEAAaM5MDcwCQYDVR0TBAIwADALBgNVHQ8E\nBAMCBeAwHQYDVR0RBBYwFIIHZm9vLmJhcoIJKi5mb28uYmFyMA0GCSqGSIb3DQEB\nCwUAA4IBAQDXNBkh3eX8le0sCThAixyiz1JuHbL8Tafe2wIg4HyMzyIjuXpxWfW7\njyev8uyCygi0pf8TyNsKody7HFiQoOVWRnC0LbePyqR2h1p7vT2BgGsIiaSIHbW4\nrQoKt0y/KdWiGJLUSMHLEVgWPklGiA9ishReDOGvCVgVd304fvUP6ZV/mxf4ELMT\nNp5OwAWm5fI34hFaiE0r0RrIH5+8w/gVHSfd/rIjj8fDOY+sVtfzqrKPQphCyGLF\nn/v3xUnxsxxifJh/2MRYfE/O2u30/ykqA1y7X4eIABCbgCC+rz9TVZ/DyjD4BygV\n28oMByzQLr93aM98ckvjO5wxRy6Mo71K\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\nMIIC6jCCAdKgAwIBAgIJAJWLSmriPMaZMA0GCSqGSIb3DQEBCwUAMBYxFDASBgNV\nBAoMC1Rlc3QgRGV2IENBMB4XDTE2MDQwNTE5MzE0NVoXDTE3MDQwNTE5MzE0NVow\nFDESMBAGA1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB\nCgKCAQEA0VoP00HD8xWuUIgwWBrBPX1Gnbja8fhSvmnNV/jOuM2MXqvFNkuAyQFF\n1SpwkIy1ooRLoBdo8choXe9BjPjTC2YH+Vwemn0J+cIV9aIZnXpmHS5ZCLBW+HDa\n2b0AhaabwsxBA1vG+FR8o/BRFkv66NvGbLcsIzu1QioEm2Sd2/oPiyDTmrjPPcEM\na2aZiupJTZ+3KCpLwiU+BysHOkGlrKyjw82UPjN1LQAMuh25MMR+RsupQvACK8Zh\nPxWrNK8mrXW8riRhtOk/IVNYlZzNQDn6OiRaVSJ8qGkCPqm7MnHN6WMpFBK3wQ02\n2y3NNbeFjp4jYbeQHOEzlHtK6g9YCwIDAQABoz0wOzAJBgNVHRMEAjAAMAsGA1Ud\nDwQEAwIF4DAhBgNVHREEGjAYgglsb2NhbGhvc3SCCyoubG9jYWxob3N0MA0GCSqG\nSIb3DQEBCwUAA4IBAQD1msPYV9RtW38bt8lpPQMF4Y4BdAJLn4pOVAD055vIWNVw\naBUxLWwcbrQaumBW3umC431htJ5tNNAJotO948j6lXXbRh9VJ4+MOW8XOr+/1zND\n/5V3Cz5H4164pNnDpHZ5rW+TqzGSxsrTZ0FERxoCFhQo0oEN+AYV8B6eIddpiNWt\nMccLWmDU6orMFKgr00yCrXEaGTii6WDxp4EvY+cu/a7XgABJ/OFFe+zEw0gZR1IC\nSNEHn0VdnXaqmzA95EK7N0bBQ/95InK1DGU91UdTeERGM2hDxTTfV9VLHqHSgwWC\n0unMCkyljEla27PLNyDnNEFc77cscjtUUEt2V0Jv\n-----END CERTIFICATE-----\n";

	static function t(label:String, f:Void->Dynamic) {
		var r = try Std.string(f()) catch (e:Dynamic) "EXC " + Std.string(e);
		Sys.println(label + " => " + r);
	}

	public static macro function certificates() {
		t("authmode", () -> [SslAuthmode.SSL_VERIFY_NONE, SslAuthmode.SSL_VERIFY_OPTIONAL, SslAuthmode.SSL_VERIFY_REQUIRED]);
		t("endpoint", () -> [SslEndpoint.SSL_IS_CLIENT, SslEndpoint.SSL_IS_SERVER]);
		t("preset", () -> [SslPreset.SSL_PRESET_DEFAULT, SslPreset.SSL_PRESET_SUITEB]);
		t("transport", () -> [SslTransport.SSL_TRANSPORT_STREAM, SslTransport.SSL_TRANSPORT_DATAGRAM]);
		for (c in [0, -0x6900, -0x3D00, -0x1E80, -0x2180, -0x7280, -0x7780, -0x0050, -0x4080, 0x7780])
			t("strerror " + c, () -> mbedtls.Error.strerror(c));
		var crt = new mbedtls.X509Crt();
		t("crt parse pem", () -> crt.parse(Bytes.ofString(CERTS)));
		t("crt parse garbage", () -> new mbedtls.X509Crt().parse(Bytes.ofString("garbage")));
		t("crt parse empty", () -> new mbedtls.X509Crt().parse(Bytes.alloc(0)));
		t("crt parse_file missing", () -> new mbedtls.X509Crt().parse_file("nope.pem"));
		t("crt parse_path missing", () -> new mbedtls.X509Crt().parse_path("nope_dir"));
		var cert = sys.ssl.Certificate.fromString(CERTS);
		t("commonName", () -> cert.commonName);
		t("altNames", () -> cert.altNames);
		t("notBefore", () -> cert.notBefore.getFullYear() + "-" + cert.notBefore.getMonth() + "-" + cert.notBefore.getDate());
		t("notAfter", () -> cert.notAfter.getFullYear() + "-" + cert.notAfter.getMonth() + "-" + cert.notAfter.getDate());
		t("issuer O", () -> cert.issuer("O"));
		t("issuer X", () -> cert.issuer("X"));
		t("subject CN", () -> cert.subject("CN"));
		t("bad fromString", () -> sys.ssl.Certificate.fromString("garbage").commonName);
		t("empty altNames", () -> sys.ssl.Certificate.fromString("garbage").altNames);
		return macro null;
	}

	public static macro function keys() {
		t("readPEM bad", () -> sys.ssl.Key.readPEM("garbage", false));
		t("readPEM encrypted", () -> sys.ssl.Key.readPEM(PRIV, false, "testpassword"));
		t("loadFile missing", () -> sys.ssl.Key.loadFile("nope.key"));
		t("loadFile pub missing", () -> sys.ssl.Key.loadFile("nope.key", true));
		var ctr = new mbedtls.CtrDrbg();
		t("ctr seed", () -> ctr.seed(new mbedtls.Entropy()));
		t("ctr seed custom", () -> new mbedtls.CtrDrbg().seed(new mbedtls.Entropy(), "custom"));
		t("ctr random", () -> {
			var b = Bytes.alloc(16);
			var r = ctr.random(b, 16);
			r + " " + (b.toHex() != "00000000000000000000000000000000");
		});
		t("pk parse_public_key bad", () -> new mbedtls.PkContext().parse_public_key(Bytes.ofString("garbage")));
		t("pk parse_key bad", () -> new mbedtls.PkContext().parse_key(Bytes.ofString("garbage"), null, ctr));
		t("pk parse_key enc nopass", () -> new mbedtls.PkContext().parse_key(Bytes.ofString(PRIV), null, ctr));
		t("pk parse_key enc pass", () -> new mbedtls.PkContext().parse_key(Bytes.ofString(PRIV), "testpassword", ctr));
		t("pk parse_key enc badpass", () -> new mbedtls.PkContext().parse_key(Bytes.ofString(PRIV), "wrong", ctr));
		t("pk parse_key enc emptypass", () -> new mbedtls.PkContext().parse_key(Bytes.ofString(PRIV), "", ctr));
		t("pk parse_keyfile missing", () -> new mbedtls.PkContext().parse_keyfile("nope.key", null, ctr));
		t("pk parse_public_keyfile missing", () -> new mbedtls.PkContext().parse_public_keyfile("nope.key"));
		return macro null;
	}

	public static macro function keyErrorCodes() {
		t("readPEM pub bad", () -> sys.ssl.Key.readPEM("garbage", true));
		t("readDER pub", () -> sys.ssl.Key.readDER(haxe.crypto.Base64.decode(PUB64), true) != null);
		t("pk parse_public_key der", () -> new mbedtls.PkContext().parse_public_key(haxe.crypto.Base64.decode(PUB64)));
		return macro null;
	}

	public static macro function contexts() {
		var ctr = new mbedtls.CtrDrbg();
		ctr.seed(new mbedtls.Entropy());
		var crt = new mbedtls.X509Crt();
		crt.parse(Bytes.ofString(CERTS));
		var conf = new mbedtls.Config();
		t("defaults", () -> conf.defaults(SSL_IS_CLIENT, SSL_TRANSPORT_STREAM, SSL_PRESET_DEFAULT));
		t("defaults bad", () -> new mbedtls.Config().defaults(cast 7, cast 9, cast 3));
		t("authmode set", () -> { conf.authmode(SSL_VERIFY_REQUIRED); "done"; });
		t("rng", () -> { conf.rng(ctr); "done"; });
		t("ca_chain", () -> { conf.ca_chain(crt); "done"; });
		var ssl = new mbedtls.Ssl();
		t("setup", () -> ssl.setup(conf));
		t("set_hostname", () -> ssl.set_hostname("localhost"));
		t("get_peer_cert", () -> ssl.get_peer_cert());
		t("handshake no bio", () -> ssl.handshake());
		t("read no bio", () -> ssl.read(Bytes.alloc(4), 0, 4));
		t("write no bio", () -> ssl.write(Bytes.alloc(4), 0, 4));
		t("handshake not set up", () -> new mbedtls.Ssl().handshake());
		return macro null;
	}

	public static macro function decoders() {
		var conf = new mbedtls.Config();
		var cert = sys.ssl.Certificate.fromString(CERTS);
		var ssl = new mbedtls.Ssl();
		t("config bad this", () -> { (cast 1 : mbedtls.Config).authmode(SSL_VERIFY_NONE); "done"; });
		t("config bad authmode", () -> { conf.authmode(cast "x"); "done"; });
		t("config both bad", () -> { (cast 1 : mbedtls.Config).authmode(cast "x"); "done"; });
		t("ca_chain bad", () -> { conf.ca_chain(cast 1); "done"; });
		t("rng bad", () -> { conf.rng(1); "done"; });
		t("defaults all bad", () -> (cast 1 : mbedtls.Config).defaults(cast "e", cast "t", cast "p"));
		t("crt parse null", () -> new mbedtls.X509Crt().parse(null));
		t("crt parse_file null", () -> new mbedtls.X509Crt().parse_file(null));
		t("strerror null", () -> mbedtls.Error.strerror(cast null));
		t("strerror string", () -> mbedtls.Error.strerror(cast "x"));
		t("setSocket bad ssl", () -> sys.ssl.Mbedtls.setSocket(cast 1, cast 2));
		t("setSocket bad socket", () -> sys.ssl.Mbedtls.setSocket(new mbedtls.Ssl(), cast 2));
		t("subject bad field", () -> Reflect.callMethod(cert, Reflect.field(cert, "subject"), [1]));
		t("subject on non-certificate", () -> Reflect.callMethod({native: 1}, Reflect.field(cert, "subject"), ["CN"]));
		t("ssl read bad", () -> ssl.read(null, 0, 4));
		t("ssl read all bad", () -> (cast 1 : mbedtls.Ssl).read(null, cast "p", cast "l"));
		t("seed bad", () -> new mbedtls.CtrDrbg().seed(cast 1));
		t("pk parse_key bad rng", () -> new mbedtls.PkContext().parse_key(Bytes.ofString("x"), null, cast 1));
		t("pk parse_key bad pass", () -> new mbedtls.PkContext().parse_key(Bytes.ofString("x"), cast 1, new mbedtls.CtrDrbg()));
		t("loadDefaults bad", () -> @:privateAccess sys.ssl.Mbedtls.loadDefaults(cast 1));
		t("too many args", () -> Reflect.callMethod(null, Reflect.field(mbedtls.Error, "strerror"), [1, 2]));
		return macro null;
	}
}
