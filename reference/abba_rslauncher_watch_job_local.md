# Periodically poll Workbench jobs for status and return their IDs when all job statuses arrive at 'Finished' state

Periodically poll Workbench jobs for status and return their IDs when
all job statuses arrive at 'Finished' state

## Usage

``` r
abba_rslauncher_watch_job_local(
  job_ids,
  poll_interval_seconds = 1,
  timeout_seconds = 300,
  ...
)
```

## Arguments

- job_ids:

  a list/vector of Workbench job IDs

- poll_interval_seconds:

  how often job statuses should be updated

- timeout_seconds:

  maximum amount of time in seconds after which job IDs will be returned
  regardless of job statuses

- ...:

  other positional/keyword arguments that will be ignored

## Value

a vector of job IDs

## Examples

``` r
if (FALSE) { # \dontrun{
job_statuses <- abba_rslauncher_watch_job_local(c('job-id-1', 'job-id-2'))
} # }
```
