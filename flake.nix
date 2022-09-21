{
  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    flake-utils.url = "github:numtide/flake-utils";

    prometheus_source.url = "github:ulrikstrid/prometheus?ref=5acd3509eb5679a26374316356fb6455c879cd5a";
    prometheus_source.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, prometheus_source }:
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
          };
          inherit (pkgs) lib;
          myPkgs = pkgs.ocaml-ng.ocamlPackages.callPackage ./nix/generic.nix { inherit prometheus_source; };
          myDrvs = lib.filterAttrs (_: value: lib.isDerivation value) myPkgs;
        in
        {
          devShell = (pkgs.mkShell {
            inputsFrom = with myDrvs; [ prometheus-dream prometheus-piaf ];
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

          packages = myPkgs;
        };
    in
    with flake-utils.lib;
    eachSystem systems out // {
      overlays.default = final: prev: {
        ocaml-ng = builtins.mapAttrs
          (_: ocamlVersion:
            ocamlVersion.overrideScope' (oself: osuper:
              ocamlVersion.callPackage ./nix/generic.nix { inherit prometheus_source; }))
          prev.ocaml-ng;
      };
    };

}
