{ pkgs, stdenv, lib, fetchFromGitHub, buildDunePackage, ocaml, topkg, findlib, ocamlbuild, astring, fmt, re, lwt, alcotest, piaf-lwt, dream, cmdliner, logs, prometheus_source }:

rec {
  asetmap = stdenv.mkDerivation rec {
    version = "0.8.1";
    pname = "asetmap";
    src = pkgs.fetchurl {
      url =
        "https://github.com/dbuenzli/asetmap/archive/refs/tags/v0.8.1.tar.gz";
      sha256 = "051ky0k62xp4inwi6isif56hx5ggazv4jrl7s5lpvn9cj8329frj";
    };

    strictDeps = true;

    nativeBuildInputs = [ topkg findlib ocamlbuild ocaml ];
    buildInputs = [ topkg ];

    inherit (topkg) buildPhase installPhase;
  };

  prometheus = buildDunePackage rec {
    version = "1.2.0";
    pname = "prometheus";
    src = prometheus_source;

    strictDeps = true;

    propagatedBuildInputs = [
      astring
      asetmap
      fmt
      re
      lwt
      alcotest
    ];
  };

  prometheus-reporter = buildDunePackage {
    pname = "prometheus-reporter";
    version = "1.2.0";

    src = prometheus_source;

    checkInputs = [ alcotest ];

    propagatedBuildInputs = [ prometheus fmt cmdliner lwt logs fmt ];

    doCheck = true;

    meta = { description = "Client library for Prometheus monitoring"; };
  };

  prometheus-dream = buildDunePackage {
    pname = "prometheus-dream";
    version = "1.2.0";

    src = ./..;

    checkInputs = [ ];

    propagatedBuildInputs =
      [ prometheus prometheus-reporter dream lwt cmdliner ];

    doCheck = true;

    meta = { description = "Dream integration for prometheus"; };
  };

  prometheus-piaf = buildDunePackage {
    pname = "prometheus-piaf";
    version = "1.2.0";

    src = ./..;

    checkInputs = [ ];

    propagatedBuildInputs =
      [ prometheus prometheus-reporter piaf-lwt lwt cmdliner ];

    doCheck = true;

    meta = { description = "Dream integration for prometheus"; };
  };
}
