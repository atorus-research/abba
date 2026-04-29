# Execute programs via logrx

Execute programs via logrx

## Usage

``` r
abba_rslauncher_submit_logrx_job_local(p, log_path, user_tag = "", ...)
```

## Arguments

- p:

  path to program

- log_path:

  Path to the directory where the log will be saved. Required; must be
  supplied explicitly so that logs are never written to an unexpected
  location in the user's filespace.

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
job_id <- abba_rslauncher_submit_logrx_job_local("/path/to/program.R",
                                                 log_path = "/path/to/logs")
} # }
```
