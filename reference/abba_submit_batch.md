# Submit programs for execution in order defined by structure of input list. Programs inside sublists will be executed in parallel, and sublists themselves would be submitted sequentially.

Submit programs for execution in order defined by structure of input
list. Programs inside sublists will be executed in parallel, and
sublists themselves would be submitted sequentially.

## Usage

``` r
abba_submit_batch(
  prog_list,
  sequential = FALSE,
  submit_func = abba_rslauncher_submit_job_local,
  wait_func = abba_rslauncher_watch_job_local,
  succeed_func = abba_rslauncher_get_job_succeeded_local,
  col_name = "run_group",
  halt_on_error = TRUE,
  rerun_unchanged_programs = TRUE,
  update_cache = FALSE,
  cache_folder = getOption("abba.default_cache_folder"),
  ...
)
```

## Arguments

- prog_list:

  A list of R program paths to execute

- sequential:

  when sequential=TRUE, prog_list is flattened and everything is
  executed sequentially.

- submit_func:

  function that will be used to submit jobs

- wait_func:

  function that checks job status and returns when job finishes
  executing

- succeed_func:

  function that returns TRUE if job finished running without errors and
  FALSE otherwise

- col_name:

  Name of the column that contains run group numbers when prog_list is a
  data frame

- halt_on_error:

  If TRUE: if prog_list contains program inputs/outputs - programs that
  depend on failed program will not be executed; if prog_list contains
  only program paths - when program fails, entire batch will stop
  executing. TRUE by default

- rerun_unchanged_programs:

  If FALSE: will not re-run programs whose code and inputs have not been
  modified since last batch run with update_cache=TRUE.

- update_cache:

  if TRUE, file hash for programs and their inputs will be calculated
  and written to `cache_folder` after the batch run. If FALSE, the cache
  will not be created or updated. FALSE by default.

- cache_folder:

  Path to the folder where hash-sums of programs and their inputs will
  be stored. Required when `update_cache=TRUE` or
  `rerun_unchanged_programs=FALSE`. The default value can be set via the
  `abba.default_cache_folder` option; abba never falls back to writing
  caches under the user's filespace.

- ...:

  arguments that will be passed to submit_func and wait_func functions

## Value

list job IDs associated with executed programs

## Examples

``` r
if (FALSE) { # \dontrun{
job_ids <- abba_submit_batch(list(
  c("/mnt/work_drive/proj/comp/prot/task/development/prod/program/sdtm/dm.sas"),
  c("/mnt/work_drive/proj/comp/prot/task/development/prod/program/sdtm/ae.sas"),
  c("/mnt/work_drive/proj/comp/prot/task/development/prod/program/tfl/t1_dm.sas",
    "/mnt/work_drive/proj/comp/prot/task/development/prod/program/tfl/t1_ae.sas")))
 } # }
```
