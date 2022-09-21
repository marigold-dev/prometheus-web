(lang dune 2.9)

(name prometheus-app)

(version 1.0.0)

(generate_opam_files true)

(source
 (github marigold-dev/prometheus-web))

(license BSD3)

(authors "Ulrik Strid")

(maintainers "contact@marigold.dev")

(package
 (name prometheus-dream)
 (synopsis "Client library for Prometheus monitoring")
 (description "Use Dream to serve metrics")
 (depends
  (cmdliner
   (>= 1.1.0))
  dream
  prometheus
  lwt
  prometheus-app-pure))

(package
 (name prometheus-piaf)
 (synopsis "Client library for Prometheus monitoring")
 (description "Use Piaf to serve metrics")
 (depends
  (cmdliner
   (>= 1.1.0))
  piaf
  prometheus
  lwt
  prometheus-app-pure))
