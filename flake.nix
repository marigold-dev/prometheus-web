{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    ocaml-overlay.url = "github:anmonteiro/nix-overlays";
    ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";
    ocaml-overlay.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ocaml-overlay }:
    let
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      out = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ ocaml-overlay.overlay ];
          };
          inherit (pkgs) lib;
          myPkgs = pkgs.ocaml-ng.ocamlPackages.callPackage ./nix/generic.nix { doCheck = true; };
          myDrvs = lib.filterAttrs (_: value: lib.isDerivation value) myPkgs;
        in {
          devShell = (pkgs.mkShell {
            inputsFrom = builtins.attrValues myDrvs;
            buildInputs = with myPkgs; [ prometheus ];
            nativeBuildInputs = with pkgs;
              with ocamlPackages; [
                ocaml-lsp
                ocamlformat
                odoc
                ocaml
                dune_3
                nixfmt
              ];
          });
        };
    in with flake-utils.lib;
    eachSystem systems out // {
      overlays.default = final: prev: {
        ocaml-ng = builtins.mapAttrs (_: ocamlVersion:
          ocamlVersion.overrideScope' (oself: osuper:
            ocamlVersion.callPackage ./nix/generic.nix {
              doCheck = true;
            })) prev.ocaml-ng;
      };
    };

}
