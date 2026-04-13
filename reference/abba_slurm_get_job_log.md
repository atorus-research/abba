# Return job log for each submitted job ID

Return job log for each submitted job ID

## Usage

``` r
abba_slurm_get_job_log(job_ids, ...)
```

## Arguments

- job_ids:

  valid SLURM job IDs

- ...:

  other parameters that will be ignored

## Value

list of character vectors. each character vector would represent program
log.

## Examples

``` r
if (FALSE) { # \dontrun{
job_log <- abba_slurm_get_job_log("156")} # }
```
