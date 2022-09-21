(* This code is borrowed from https://github.com/mirage/prometheus
 * which is distributed under the Apache License 2.0
 *)

open Prometheus
open Prometheus_reporter

module Unix_runtime = struct
  let start_time = Unix.gettimeofday ()

  let simple_metric ~metric_type ~help name fn =
    let info =
      {
        MetricInfo.name = MetricName.v name;
        help;
        metric_type;
        label_names = [];
      } in
    let collect () = LabelSetMap.singleton [] [Sample_set.sample (fn ())] in
    (info, collect)

  let process_start_time_seconds =
    simple_metric ~metric_type:Counter "process_start_time_seconds"
      (fun () -> start_time)
      ~help:"Start time of the process since unix epoch in seconds."

  let metrics = [process_start_time_seconds]
end

let () =
  let add (info, collector) =
    CollectorRegistry.(register default) info collector in
  List.iter add Unix_runtime.metrics

type config = int option

let listen_prometheus =
  let open! Cmdliner in
  let doc =
    Arg.info ~docs:"MONITORING OPTIONS" ~docv:"PORT"
      ~doc:"Port on which to provide Prometheus metrics over HTTP."
      ["listen-prometheus"] in
  Arg.(value @@ opt (some int) None doc)

let opts : config Cmdliner.Term.t = listen_prometheus

let serve : config -> unit Lwt.t = function
  | None -> Lwt.return ()
  | Some port ->
    Dream.serve ~interface:"0.0.0.0" ~port (fun _ ->
        let open Lwt.Syntax in
        let* data = Prometheus.CollectorRegistry.(collect default) in
        let body = Fmt.to_to_string TextFormat_0_0_4.output data in
        Dream.respond
          ~headers:[("Content-Type", "text/plain; version=0.0.4")]
          body)
