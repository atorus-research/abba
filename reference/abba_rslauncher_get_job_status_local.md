# Get Workbench job status for a given vector/list of job IDs

Get Workbench job status for a given vector/list of job IDs

## Usage

``` r
abba_rslauncher_get_job_status_local(job_ids, ...)
```

## Arguments

- job_ids:

  A list/vector of job IDs

- ...:

  other positional/keyword arguments that will be ignored

## Value

a vector of job ID statuses

## Examples

``` r
if (FALSE) { # \dontrun{
job_statuses <- abba_rslauncher_get_job_status_local(c('job-id-1', 'job-id-2'))
} # }
```
