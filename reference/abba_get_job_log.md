# Send GET request to get logs of specified Jobs

Send GET request to get logs of specified Jobs

## Usage

``` r
abba_get_job_log(
  job_ids,
  api_address = Sys.getenv("ABBA_API_ADDRESS"),
  api_key = Sys.getenv("ABBA_API_KEY")
)
```

## Arguments

- job_ids:

  A list of job IDs to get logs for

- api_address:

  URL to send requests to, hosted in Posit Connect. Defaults to
  environment variable ABBA_API_ADDRESS.

- api_key:

  API Key for accessing restricted endpoints. Defaults to environment
  variable ABBA_API_KEY

## Value

body of request\`s response in a list format

## Examples

``` r
if (FALSE) { # \dontrun{
response <- abba_get_job_log('1234j-13j4l5k-ajslfd')} # }
```
