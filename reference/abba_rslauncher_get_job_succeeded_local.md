# Check whether Workbench jobs have been fully executed.

Check whether Workbench jobs have been fully executed.

## Usage

``` r
abba_rslauncher_get_job_succeeded_local(job_ids, ...)
```

## Arguments

- job_ids:

  a list/vector of Workbench job IDs

- ...:

  other positional/keyword arguments that will be ignored

## Value

a named boolean vector. FALSE value indicates that job did not fully
execute

## Examples

``` r
if (FALSE) { # \dontrun{
job_statuses <- abba_rslauncher_get_job_succeeded_local(c('job-id-1', 'job-id-2'))
} # }
```
