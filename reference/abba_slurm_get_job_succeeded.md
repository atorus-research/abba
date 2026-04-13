# Check whether SLURM jobs have been fully executed.

Check whether SLURM jobs have been fully executed.

## Usage

``` r
abba_slurm_get_job_succeeded(job_ids, ...)
```

## Arguments

- job_ids:

  a list/vector of valid SLURM job IDs

- ...:

  other parameters that will be ignored

## Value

a named boolean vector. TRUE if job finished running and has 'COMPLETED'
status, FALSE otherwise. If job has not finished running, a NULL will be
returned.

## Examples

``` r
if (FALSE) { # \dontrun{
job_statuses <- abba_slurm_get_job_succeeded(c('job-id-1', 'job-id-2'))
} # }
```
