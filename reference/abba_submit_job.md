# Send POST request to submit-job endpoint

Send POST request to submit-job endpoint

## Usage

``` r
abba_submit_job(
  file_path,
  batch_group_id = "",
  user_tag = "",
  cpu_limit = 1L,
  memory_limit = "512M",
  container = "",
  mounts = "",
  auto_mount_home = FALSE,
  home_nfs_ip_address = getOption("abba.home.nfs.ip.address"),
  api_address = Sys.getenv("ABBA_API_ADDRESS"),
  api_key = Sys.getenv("ABBA_API_KEY"),
  ...
)
```

## Arguments

- file_path:

  Full path to R file

- batch_group_id:

  Group ID for batch processing

- user_tag:

  Optional; a string that describes what kind of job will be scheduled
  to run

- cpu_limit:

  Maximum number of cores available for Kubernetes container

- memory_limit:

  Maximum amount of RAM available for Kubernetes container

- container:

  A string containing a permitted container name.

- mounts:

  Specifically formatted list with information bout volumes that
  container would have access to during the run

- auto_mount_home:

  set to TRUE to mount service user home directory

- home_nfs_ip_address:

  IP address for mounting service user home directory

- api_address:

  URL to send requests to, hosted in Posit Connect. Defaults to
  environment variable ABBA_API_ADDRESS.

- api_key:

  API Key for accessing restricted endpoints. Defaults to environment
  variable ABBA_API_KEY.

- ...:

  Other arguments that will be ignored

## Value

body of request\`s response in a list format

## Examples

``` r
if (FALSE) { # \dontrun{
response <- abba_submit_job('/path/to/R/program.R')} # }
```
