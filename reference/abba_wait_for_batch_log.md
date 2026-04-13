# Monitor batch status and retrieve its log when the all jobs in batch finish running

Monitor batch status and retrieve its log when the all jobs in batch
finish running

## Usage

``` r
abba_wait_for_batch_log(
  batch_id,
  poll_interval_seconds = 3,
  timeout_seconds = 600,
  api_address = Sys.getenv("ABBA_API_ADDRESS"),
  api_key = Sys.getenv("ABBA_API_KEY")
)
```

## Arguments

- batch_id:

  unique batch identificator

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

## Value

list with 2 sublists: job_ids and their logs

## Examples

``` r
if (FALSE) { # \dontrun{
response <- abba_wait_for_batch_log('batch-sdtm-sdfj4-asdjlk-bjslk')} # }
```
