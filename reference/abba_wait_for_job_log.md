# Monitor job status and retrieve its log when the job finishes running

Monitor job status and retrieve its log when the job finishes running

## Usage

``` r
abba_wait_for_job_log(
  job_id,
  poll_interval_seconds = 3,
  timeout_seconds = 600,
  api_address = Sys.getenv("ABBA_API_ADDRESS"),
  api_key = Sys.getenv("ABBA_API_KEY"),
  ...
)
```

## Arguments

- job_id:

  unique job identificator

- poll_interval_seconds:

  Total time to wait before timeout in seconds

- timeout_seconds:

  Total time to wait before timeout in seconds

- api_address:

  URL to send requests to, hosted in Posit Connect. Defaults to
  environment variable ABBA_API_ADDRESS.

- api_key:

  API Key for accessing restricted endpoints. Defaults to environment
  variable ABBA_API_KEY

- ...:

  Other arguments that will be ignored

## Value

list with 2 attributes: job_id for submitted job\`s id, and its logs

## Examples

``` r
if (FALSE) { # \dontrun{
response <- abba_wait_for_job_log('sdfj4-asdjlk-bjslk')} # }
```
