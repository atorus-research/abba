# abba 0.2.0

## Breaking changes

This release removes implicit file writes to the user's filespace in order to
comply with CRAN policy. Several functions now require arguments that
previously defaulted to a location derived from other inputs. Update call
sites to pass these arguments explicitly.

### `create_batch_api()` and `create_batch_job()`

* `path` is now required. The previous default of `"."` (the working
  directory) has been removed.
* Before: `create_batch_api()` wrote `plumber.R` to `getwd()`.
* After: callers must supply an explicit path, e.g.
  `create_batch_api("path/to/api_directory")`.
* Also fixes a bug where a `path` containing `.` (for example
  `"~/api_directory/plumber.R"`) was silently rewritten to
  `"./plumber.R"`. The user-supplied path is now respected.

### `abba_slurm_submit_job()`, `abba_rslauncher_submit_job_local()`, `abba_rslauncher_submit_logrx_job_local()`

* `log_path` is now required. There is no longer a default that writes the
  log next to the submitted program.
* Before: omitting `log_path` caused the log to be written to
  `dirname(program_path)`.
* After: callers must pass `log_path` explicitly, e.g.
  `abba_slurm_submit_job("/path/to/script.R", log_path = "/path/to/logs")`.
* When using `abba_submit_batch()` with a Workbench or SLURM submit function,
  pass `log_path` through the `...` arguments, e.g.
  `abba_submit_batch(progs, submit_func = abba_rslauncher_submit_job_local, log_path = "/path/to/logs")`.

### `abba_submit_batch()` and `abba_submit_batch_and_get_results()`

* `cache_folder` is now required whenever `update_cache = TRUE` or
  `rerun_unchanged_programs = FALSE`. The previous fallback that wrote a
  `.abba_cache` directory next to each program has been removed.
* Before: caching silently wrote to `dirname(program_path)/.abba_cache`.
* After: callers must supply `cache_folder` explicitly or set it via the
  `abba.default_cache_folder` option. A clear error is raised if caching is
  requested without a `cache_folder`.
* When `update_cache = FALSE` and `rerun_unchanged_programs = TRUE` (the
  defaults), no cache writes occur and no `cache_folder` is required.

## Internal

* Cache helper functions (`cache_match()`, `abba_save_file_cache()`) now
  require `cache_folder` and error clearly when it is missing. This also
  stops an existing code path from writing a cache into the program's
  directory when the top-level call did not request caching.

## Documentation

* Package Title and Description now quote external software names
  (`'Kubernetes'`, `'SLURM'`, `'Posit Workbench'`) per CRAN conventions.
* Examples and vignettes updated to show explicit paths for `create_batch_*`,
  `log_path`, and `cache_folder` rather than defaults.
* The standalone `LICENSE` file has been removed; `License` in `DESCRIPTION`
  is now `Apache License (>= 2)` without the `file LICENSE` pointer, which
  is the correct form when there are no additional restrictions.

# abba 0.1.0

* Initial CRAN release
* Support for Kubernetes job submission and monitoring via `kubectl`
* Support for SLURM job submission and monitoring via `sbatch`/`scontrol`/`sacct`
* Support for Posit Workbench job submission via RSLauncher
* Batch execution with parallel and sequential modes
* File-based caching to skip unchanged programs in batch reruns
* `logrx` integration for detailed execution logging
* Plumber API template for secure identity segregation on Posit Connect
