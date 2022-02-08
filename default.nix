{ pkgs
, idris2
}:

let
  inherit (pkgs) lib;

  build-package-path = lib.makeSearchPath "lib/idris2-${idris2.version}";

  extract-version = f: with builtins;
    head (match "^.*n?[[:space:]]*version[[:space:]]*=[[:space:]]*([[:alnum:].]+).*" (readFile f));

in
rec {
  buildPackagePath = lib.makeSearchPath "lib/idris2-${idris2.version}";

  build =
    { name, src, ipkg ? "${name}.ipkg", deps ? [ ] }:
    pkgs.stdenv.mkDerivation {
      pname = "idris2-${name}";
      version = extract-version "${src}/${ipkg}";

      inherit src;

      nativeBuildInputs = [ idris2 ];

      configurePhase = ''
        export IDRIS2_PACKAGE_PATH=${buildPackagePath deps}
      '';

      buildPhase = ''
        idris2 --build ${ipkg}
      '';

      installPhase = ''
        IDRIS2_PREFIX=$out/lib idris2 --install ${ipkg}
      '';
    };
}
        
