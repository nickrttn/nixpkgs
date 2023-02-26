{ lib, fetchurl, stdenv, slang, popt, python, gettext }:

let
  pythonIncludePath = "${lib.getDev python}/include/python";
in
stdenv.mkDerivation rec {
  pname = "newt";
  version = "0.52.23";

  src = fetchurl {
    url = "https://releases.pagure.org/${pname}/${pname}-${version}.tar.gz";
    sha256 = "sha256-yqNykHsU7Oz+KY8NUSpi9B0zspBhAkSliu0Hu8WtoSo=";
  };

  postPatch = ''
    sed -i -e s,/usr/bin/install,install, -e s,-I/usr/include/slang,, Makefile.in po/Makefile

    substituteInPlace Makefile.in \
      --replace "ar rv" "${stdenv.cc.targetPrefix}ar rv"
  '';

  strictDeps = true;
  nativeBuildInputs = [ python ];
  buildInputs = [ slang popt gettext ];

  NIX_LDFLAGS = "-lncurses";

  preConfigure = ''
    # If CPP is set explicitly, configure and make will not agree about which
    # programs to use at different stages.
    unset CPP
  '';

  configureFlags = [
    "--without-tcl"
    "--with-python=${python}"
  ];

  makeFlags = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  meta = with lib; {
    homepage = "https://pagure.io/newt";
    description = "Library for color text mode, widget based user interfaces";

    license = licenses.lgpl2;
    platforms = platforms.unix;
    maintainers = [ maintainers.viric ];
  };
}
