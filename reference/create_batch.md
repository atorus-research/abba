# Create a Batch API or Job file template

This function create a batch API or job file template at the specified
location. The Batch API file template is a plumber API with the
necessary REST API server side to interface with the abba package. This
simplifies the process of setting up the receiver API for which jobs are
submitted. The job template file is a markdown file with the necessary
function calls to run a batch job.

## Usage

``` r
create_batch_api(path)

create_batch_job(path)
```

## Arguments

- path:

  A file path where the target file will be created. Must be supplied
  explicitly; no default is provided so that files are never written to
  an unexpected location.

## Value

No return value, called for side effects (file creation).

## Details

Note that to deploy an R api to Posit Connect, the file must be named
plumber.R.

## Examples

``` r
# Write the template to a temporary directory
create_batch_api(tempdir())
#> Batch API file created at /tmp/RtmpoVmq26
create_batch_job(tempdir())
#> Job file created at /tmp/RtmpoVmq26

if (FALSE) { # \dontrun{
create_batch_api("~/api_directory")
create_batch_api("~/api_directory/plumber.R")

create_batch_job("~/job_directory")
create_batch_job("~/job_directory/my_job.Rmd")
} # }
```
