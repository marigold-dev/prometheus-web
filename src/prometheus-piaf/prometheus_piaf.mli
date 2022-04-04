(* This code is inspired by https://github.com/mirage/prometheus
 * which is distributed under the Apache License 2.0
 *)

(** Report metrics for Prometheus.
    See: https://prometheus.io/

    Notes:

    - This module is intended to be used by applications that export Prometheus metrics.
      Libraries should only link against the `Prometheus` module.

    - This module automatically initialises itself and registers some standard collectors relating to
      GC statistics, as recommended by Prometheus.

    - This extends [Prometheus_app] with support for cmdliner option parsing, a server pre-configured
      for Unix, and a start-time metric that uses [Unix.gettimeofday].
 *)

type config

val serve : config -> unit Lwt.t
(** [serve config] starts a Piaf server according to config.
    It returns a promise containing the thread to monitor,
    or an empty list if no server is configured. *)

val opts : config Cmdliner.Term.t
(** [opts] is the extra command-line options to offer Prometheus
    monitoring. *)
