{
  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    idris2-elab-util = {
      url = "github:stefan-hoeck/idris2-elab-util/v0.5.0";
      flake = false;
    };

    idris2-sop = {
      url = "github:stefan-hoeck/idris2-sop/v0.5.0";
      flake = false;
    };

    idris2-pretty-show = {
      url = "github:stefan-hoeck/idris2-pretty-show/v0.5.0";
      flake = false;
    };

    idris2-hedgehog = {
      url = "github:stefan-hoeck/idris2-hedgehog/v0.5.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, idris2-elab-util, idris2-sop, idris2-pretty-show, idris2-hedgehog }:
    let
      par-system = system:
        let
          pkgs = import nixpkgs { inherit system; };

          idris2 = pkgs.idris2;

          idris2-nix = pkgs.callPackage ./. { };

          buildIdris2Package = idris2-nix.build;

          buildIdris2PackagePath = idris2-nix.buildPackagePath pkgs.lib;

        in
        {
          packages =
            rec {
              inherit idris2;
              elab-util = buildIdris2Package { name = "elab-util"; src = idris2-elab-util; };
              sop = buildIdris2Package { name = "sop"; src = idris2-sop; deps = [ elab-util ]; };
              pretty-show = buildIdris2Package { name = "pretty-show"; src = idris2-pretty-show; deps = [ elab-util sop ]; };
              hedgehog = buildIdris2Package { name = "hedgehog"; src = idris2-hedgehog; deps = [ elab-util sop pretty-show ]; };
            };
        };
    in
    # "i686-linux" fails when `nix flake check`
    # (flake-utils.lib.eachSystem [ "x86_64-linux" ] par-system)
    (flake-utils.lib.eachDefaultSystem par-system)
    // {
      overlay = final: prev:
        let
          idris2 = final.idris2;

          idris2-nix = prev.callPackage ./. { pkgs = prev; };

          buildIdris2PackagePath = idris2-nix.buildPackagePath;
        in
        {
          lib = prev.lib // {
            inherit buildIdris2PackagePath;
          };
        };
    };
}
