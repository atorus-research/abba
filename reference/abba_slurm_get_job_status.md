# Return descriptive job status for slurm jobs

Return descriptive job status for slurm jobs

## Usage

``` r
abba_slurm_get_job_status(job_ids, ...)
```

## Arguments

- job_ids:

  a list/vector of Slurm job IDs

- ...:

  other positional/keyword arguments that will be ignored

## Value

a named character vector with job statuses as values and job IDs as
names.

## Examples

``` r
if (FALSE) { # \dontrun{
job_statuses <- slurm_get_job_status(c('job-id-1', 'job-id-2'))
} # }
```
