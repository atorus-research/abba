## Resubmission

This is a resubmission of {abba} 0.2.0. The 0.1.0 submission was reviewed on
2026-04-21 by Benjamin Altmann. This release addresses each item from that
review:

* **Software names quoted.** `'Kubernetes'`, `'SLURM'`, and `'Posit Workbench'`
  are now in single quotes in the Title and Description.

* **LICENSE file removed.** The package has no additional license restrictions
  beyond Apache 2.0. The standalone `LICENSE` file has been removed and the
  DESCRIPTION `License` field is now `Apache License (>= 2)` without the
  `| file LICENSE` pointer.

* **No default writes to user filespace.** Functions that previously had
  defaults writing under the user's filespace
  (`create_batch_api()`, `create_batch_job()`, `abba_slurm_submit_job()`,
  `abba_rslauncher_submit_job_local()`, `abba_rslauncher_submit_logrx_job_local()`,
  and the caching path inside `abba_submit_batch()` /
  `abba_submit_batch_and_get_results()`) now require the corresponding
  argument (`path`, `log_path`, or `cache_folder`) to be supplied explicitly
  and raise a clear error when it is missing. Examples and vignettes have
  been updated to use `tempdir()` or explicit user-supplied paths.

* **Method references.** The package does not implement methods from a
  published paper, so no references have been added to the Description.

Breaking changes are documented in `NEWS.md`.

## R CMD check results

0 errors | 0 warnings | 1 note

### NOTEs

1. **New submission**

   abba 0.1.0 was auto-processed but was not accepted, so {abba} has not
   previously landed on CRAN.

## Test environments

- Local macOS (aarch64-apple-darwin20), R 4.5.1
- win-builder (R-devel)
- win-builder (R-release)
- GitHub Actions: windows-latest (R-release), macOS-latest (R-release),
  ubuntu-22.04 (R-release, R-devel), ubuntu-latest (R-release, R-devel)

## Downstream dependencies

There are currently no downstream dependencies for this package.
