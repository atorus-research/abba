# Watch SLURM job, periodically polling its execution status.

Watch SLURM job, periodically polling its execution status.

## Usage

``` r
abba_slurm_watch_job(
  job_id = "",
  poll_interval_seconds = 3,
  timeout_seconds = 300,
  ...
)
```

## Arguments

- job_id:

  job ID that was specified when submitting jobs

- poll_interval_seconds:

  Time interval for polling job status in seconds

- timeout_seconds:

  Total time to wait before timeout in seconds

- ...:

  other positional/keyword arguments that will be ignored

## Value

a list of job ID(s) and status(es)

## Examples

``` r
if (FALSE) { # \dontrun{
result <- abba_slurm_watch_job("5195", 10, 3000)
} # }
```
