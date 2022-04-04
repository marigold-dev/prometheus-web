(lang dune 2.9)
(name prometheus-app)

(version 1.0.0)

(generate_opam_files true)

(source (github marigold-dev/prometheus-web))
(license Apache-2.0)
(authors "Thomas Leonard" "David Scott" "Ulrik Strid")
(maintainers "contact@marigold.dev")

(package
 (name prometheus-app-pure)
 (synopsis "Client library for Prometheus monitoring")
 (description "Subset of `prometheus-app` which doesn't depend on a webserver implementation")
 (depends
  (prometheus (>= 1.1.0))
  fmt
  re))

(package
 (name prometheus-dream)
 (synopsis "Client library for Prometheus monitoring")
 (description "Use Dream to serve metrics")
 (depends
  (cmdliner (>= 1.1.0))
  dream
  prometheus
  lwt
  (prometheus-app-pure (= :version))))

(package
 (name prometheus-piaf)
 (synopsis "Client library for Prometheus monitoring")
 (description "Use Piaf to serve metrics")
 (depends
  (cmdliner (>= 1.1.0))
  piaf
  prometheus
  lwt
  (prometheus-app-pure (= :version))))