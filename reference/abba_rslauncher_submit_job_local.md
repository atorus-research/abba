# Create a job for executing an R program

Create a job for executing an R program

## Usage

``` r
abba_rslauncher_submit_job_local(p, log_path = NULL, user_tag = "", ...)
```

## Arguments

- p:

  path to program

- log_path:

  optional; path to directory where log will be saved

- user_tag:

  optional; any user tags user might want to add to the job

- ...:

  other arguments that will be passed to internal rslauncher_submit_job
  function

## Value

job id

## Examples

``` r
if (FALSE) { # \dontrun{
job_id <- abba_rslauncher_submit_job_local("/path/to/program.R")
} # }
```
