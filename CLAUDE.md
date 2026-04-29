# abba - Atorus Batch Backend API

## Package Overview

`abba` manages remote batch execution of R programs across distributed
computing environments (Kubernetes, SLURM, Posit Workbench) through a
simple programming interface with security identity segregation via API
abstraction.

**Version:** 0.0.0.9007 (development) **License:** Copyright 2024 Atorus
Research, Inc. (file LICENSE) **Maintainer:** Mike Stackhouse

## Architecture

Three-layer design:

1.  **End-user layer** (`R/api_requests.R`, `R/batch_submission.R`) -
    Functions users call to submit jobs via a Posit Connect-hosted
    plumber API. Authentication via `ABBA_API_ADDRESS` and
    `ABBA_API_KEY` environment variables.

2.  **API layer** (`inst/plumber.R` template) - Plumber REST API
    deployed to Posit Connect. Validates requests, enforces container
    permissions, and delegates to local execution functions. Template
    created via [`create_batch_api()`](reference/create_batch.md).

3.  **Local execution layer** - Cluster-specific functions that run
    server-side:

    - **Kubernetes:** `R/submit_job_k8s.R` - uses `kubectl` via
      [`system2()`](https://rdrr.io/r/base/system2.html)
    - **SLURM:** `R/submit_job_slurm.R`, `R/slurm_utils.R` - uses
      `sbatch`/`scontrol`/`sacct`/`squeue` via
      [`system2()`](https://rdrr.io/r/base/system2.html)
    - **Posit Workbench:** `R/submit_job_workbench.R` - uses
      [`rstudioapi::launcherSubmitJob()`](https://rstudio.github.io/rstudioapi/reference/launcherSubmitJob.html)

## Key Directories

    R/                  - 30 source files
    man/                - 32 .Rd documentation files (roxygen2-generated)
    tests/testthat/     - 27+ test files using testthat v3 + mockery
    vignettes/          - 6 Rmd vignettes + images/ directory
    inst/               - Templates: plumber.R, job.yaml, job.Rmd, slurm_job.submit,
                          regular_workbench_submission.R, logrx_workbench_submission.R

## Dependencies

**Imports:** yaml, uuid, stringr, httr2, magrittr, tools, rstudioapi,
digest, tidyr, logrx **Suggests:** testthat (\>= 3.0.0), mockery, knitr,
rmarkdown

## Key Source Files

| File                       | Purpose                                                                                                                     |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| `R/api_requests.R`         | End-user API submission functions (abba_submit_job, abba_submit_and_get_log, etc.)                                          |
| `R/batch_submission.R`     | Batch orchestration with parallel/sequential execution, caching                                                             |
| `R/batch_dataset.R`        | Converts data frames to batch lists, validates batch structures                                                             |
| `R/batch_flow_control.R`   | Controls execution flow, detects run groups, halt-on-error logic                                                            |
| `R/submit_job_k8s.R`       | Kubernetes job submission, status polling, watching via kubectl                                                             |
| `R/submit_job_slurm.R`     | SLURM job submission via sbatch, status/log retrieval                                                                       |
| `R/submit_job_workbench.R` | Posit Workbench job submission via rstudioapi launcher                                                                      |
| `R/configure_yaml.R`       | Replaces K8s YAML template placeholders with user values                                                                    |
| `R/yaml_validation.R`      | Validates mounts, containers, CPU/memory limits                                                                             |
| `R/calculate_file_hash.R`  | MD5 caching to skip unchanged programs in batch reruns                                                                      |
| `R/yyy.R`                  | `.onLoad()` options initialization + mcpu_to_cpu/memory_to_bytes utilities                                                  |
| `R/create_batch.R`         | [`create_batch_api()`](reference/create_batch.md) and [`create_batch_job()`](reference/create_batch.md) template generators |
| `R/read_r_versions.R`      | Reads Workbench R versions from /etc/rstudio/r-versions                                                                     |
| `R/system_utils.R`         | Error checking wrapper for system2() calls                                                                                  |

## Exported Functions (36)

- **End-user API:** `abba_submit_job`, `abba_submit_and_get_log`,
  `abba_submit_batch`, `abba_submit_batch_and_get_results`,
  `abba_get_job_status`, `abba_get_job_log`, `abba_get_batch_status`,
  `abba_get_batch_log`, `abba_wait_for_job_log`,
  `abba_wait_for_batch_log`
- **Kubernetes local:** `abba_submit_k8s_job_local`,
  `abba_submit_k8s_job_and_poll_local`, `abba_get_k8s_job_status_local`,
  `abba_get_k8s_batch_status_local`, `abba_get_k8s_job_log_local`,
  `abba_get_k8s_batch_log_local`, `abba_watch_k8s_job_local`,
  `abba_watch_k8s_batch_local`, `submit_k8s_yaml`
- **Workbench:** `abba_rslauncher_submit_job_local`,
  `abba_rslauncher_submit_logrx_job_local`,
  `abba_rslauncher_get_job_status_local`,
  `abba_rslauncher_get_job_succeeded_local`,
  `abba_rslauncher_watch_job_local`
- **SLURM:** `abba_slurm_submit_job`, `abba_slurm_get_job_status`,
  `abba_slurm_get_job_log`, `abba_slurm_get_job_succeeded`,
  `abba_slurm_watch_job`
- **Utilities:** `create_batch_api`, `create_batch_job`,
  `calculate_run_group`, `%>%`

## Package Options (set in .onLoad)

| Option                      | Default                   | Purpose                           |
|-----------------------------|---------------------------|-----------------------------------|
| `abba.lower.cpu.limit`      | 0.001                     | Min CPU for K8s containers        |
| `abba.cpu.limit`            | 2                         | Max CPU for K8s containers        |
| `abba.lower.memory.limit`   | ‘128M’                    | Min memory for K8s containers     |
| `abba.memory.limit`         | ‘1G’                      | Max memory for K8s containers     |
| `abba.permitted.containers` | NULL                      | Allowed container images          |
| `abba.default.container`    | NULL                      | Default container image           |
| `abba.k8s.namespace`        | ‘rstudio’                 | Kubernetes namespace              |
| `abba.home.nfs.ip.address`  | NULL                      | NFS mount IP for home dirs        |
| `abba.r.versions.path`      | ‘/etc/rstudio/r-versions’ | Path to Workbench R versions file |
| `abba.default_cache_folder` | NULL                      | Hash cache storage location       |
| `abba.slurm.cpu.cores`      | 1L                        | Default SLURM CPU cores           |
| `abba.slurm.memory`         | 1024L                     | Default SLURM memory (MB)         |

## Building and Testing

``` bash
# Run tests
Rscript -e 'devtools::test()'

# Build and check
R CMD build .
R CMD check abba_*.tar.gz

# Check as CRAN
R CMD check --as-cran abba_*.tar.gz

# Generate documentation
Rscript -e 'devtools::document()'
```

## External System Dependencies

The package interfaces with external tools via
[`system2()`](https://rdrr.io/r/base/system2.html): - **kubectl** -
Kubernetes CLI (K8s functions) - **sbatch/scontrol/sacct/squeue** -
SLURM scheduler commands - **id** - Linux user identity (`get_guid.R`) -
**rstudioapi** - Posit Workbench launcher API

## Notes

- All test external calls are mocked via `mockery` - no real
  kubectl/SLURM needed to run tests
- `rsconnect/` directory (gitignored) contains local Posit Connect
  deployment metadata
- Root-level `plumber.R` is a production deployment file (excluded via
  .Rbuildignore); `inst/plumber.R` is the distributable template
- `test_programs/` contains a simple test script used during development
