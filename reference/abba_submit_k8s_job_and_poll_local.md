# Submit a job profile for execution on a Kubernetes cluster and poll for completion

Submit a job profile for execution on a Kubernetes cluster and poll for
completion

## Usage

``` r
abba_submit_k8s_job_and_poll_local(
  file_path,
  batch_group_id = "",
  user_tag = "",
  cpu_limit = 1L,
  memory_limit = "512M",
  container = getOption("abba.default.container"),
  mounts = "",
  auto_mount_home = FALSE,
  home_nfs_ip_address = getOption("abba.home.nfs.ip.address"),
  namespace = getOption("abba.k8s.namespace"),
  username = NULL,
  poll_interval_seconds = 3,
  timeout_seconds = 600
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

  A valid container image name provided as a character string. Defaults
  to the option abba.default.container.

- mounts:

  Specifically formatted list with information bout volumes that
  container would have access to during the run

- auto_mount_home:

  set to TRUE to mount service user home directory

- home_nfs_ip_address:

  IP address for mounting service user home directory

- namespace:

  Kubernetes namespace to put the job in

- username:

  user whose authority will be used to run the program

- poll_interval_seconds:

  Time interval for polling job status in seconds

- timeout_seconds:

  Total time to wait before timeout in seconds

## Value

A "Job completed successfully" message, or a list of failed jobs and
their ID's.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- abba_submit_k8s_job_and_poll_local("path/to/your/job.yaml")
} # }

```
