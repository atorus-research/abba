# Send GET request to get job status

Send GET request to get job status

## Usage

``` r
abba_get_job_status(
  job_id,
  api_address = Sys.getenv("ABBA_API_ADDRESS"),
  api_key = Sys.getenv("ABBA_API_KEY")
)
```

## Arguments

- job_id:

  job IDs to get status for

- api_address:

  URL to send requests to, hosted in Posit Connect. Defaults to
  environment variable ABBA_API_ADDRESS.

- api_key:

  API Key for accessing restricted endpoints. Defaults to environment
  variable ABBA_API_KEY.

## Value

body of request\`s response in a list format

## Examples

``` r
if (FALSE) { # \dontrun{
response <- abba_get_job_status('1234j-13j4l5k-ajslfd')} # }
```
