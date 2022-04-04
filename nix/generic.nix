{ pkgs, stdenv, lib, ocamlPackages, static ? false, doCheck }:

with ocamlPackages; rec {
  asetmap = stdenv.mkDerivation rec {
    version = "0.8.1";
    pname = "asetmap";
    src = pkgs.fetchurl {
      url =
        "https://github.com/dbuenzli/asetmap/archive/refs/tags/v0.8.1.tar.gz";
      sha256 = "051ky0k62xp4inwi6isif56hx5ggazv4jrl7s5lpvn9cj8329frj";
    };

    nativeBuildInputs = with ocamlPackages; [ topkg findlib ocamlbuild ocaml ];

    inherit (ocamlPackages.topkg) buildPhase installPhase;
  };

  prometheus = buildDunePackage rec {
    version = "1.1.0";
    pname = "prometheus";
    src = pkgs.fetchurl {
      url =
        "https://github.com/mirage/prometheus/releases/download/v1.1/prometheus-v1.1.tbz";
      sha256 = "1r4rylxmhggpwr1i7za15cpxdvgxf0mvr5143pvf9gq2ijr8pkzv";
    };

    propagatedBuildInputs = with ocamlPackages; [
      astring
      asetmap
      fmt
      re
      lwt
      alcotest
    ];
  };

  prometheus-app-pure = buildDunePackage {
    pname = "prometheus-app-pure";
    version = "1.0.0";

    src = lib.filterGitSource {
      src = ./..;
      dirs = [ "src/prometheus-app-pure" ];
      files = [ "dune-project" "prometheus-app-pure.opam" ];
    };

    checkInputs = [ ];

    propagatedBuildInputs = [ prometheus fmt re ];

    inherit doCheck;

    meta = { description = "Client library for Prometheus monitoring"; };
  };

  prometheus-dream = buildDunePackage {
    pname = "prometheus-dream";
    version = "1.0.0";

    src = lib.filterGitSource {
      src = ./..;
      dirs = [ "src/prometheus-dream" ];
      files = [ "dune-project" "prometheus-dream.opam" ];
    };

    checkInputs = [ ];

    propagatedBuildInputs =
      [ prometheus prometheus-app-pure dream lwt cmdliner ];

    inherit doCheck;

    meta = { description = "Dream integration for prometheus"; };
  };

  prometheus-piaf = buildDunePackage {
    pname = "prometheus-piaf";
    version = "1.0.0";

    src = lib.filterGitSource {
      src = ./..;
      dirs = [ "src/prometheus-piaf" ];
      files = [ "dune-project" "prometheus-piaf.opam" ];
    };

    checkInputs = [ ];

    propagatedBuildInputs =
      [ prometheus prometheus-app-pure piaf lwt cmdliner ];

    inherit doCheck;

    meta = { description = "Dream integration for prometheus"; };
  };
}
