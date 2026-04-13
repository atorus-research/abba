# Send job and poll for status. This function sends multiple requests so it won't time out on heavy jobs

Send job and poll for status. This function sends multiple requests so
it won't time out on heavy jobs

## Usage

``` r
abba_submit_and_get_log(
  file_path,
  batch_group_id = "",
  user_tag = "",
  cpu_limit = 1L,
  memory_limit = "512M",
  container = "",
  mounts = "",
  auto_mount_home = FALSE,
  home_nfs_ip_address = getOption("abba.home.nfs.ip.address"),
  poll_interval_seconds = 3,
  timeout_seconds = 600,
  api_address = Sys.getenv("ABBA_API_ADDRESS"),
  api_key = Sys.getenv("ABBA_API_KEY")
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

  list that contains container name and image name

- mounts:

  Specifically formatted list with information bout volumes that
  container would have access to during the run

- auto_mount_home:

  set to TRUE to mount service user home directory

- home_nfs_ip_address:

  IP address for mounting service user home directory

- poll_interval_seconds:

  Total time to wait before timeout in seconds

- timeout_seconds:

  Total time to wait before timeout in seconds

- api_address:

  URL to send requests to, hosted in Posit Connect. Defaults to
  environment variable ABBA_API_ADDRESS.

- api_key:

  API Key for accessing restricted endpoints. Defaults to environment
  variable ABBA_API_KEY.

## Value

list with 2 attributes: job_id for submitted job\`s id, and its logs

## Examples

``` r
if (FALSE) { # \dontrun{
response <- abba_submit_and_get_log('/path/to/R/program.R', batch_group_id='SDTM')} # }
```
