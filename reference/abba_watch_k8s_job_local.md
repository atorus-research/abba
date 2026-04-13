# Watch a K8S job that has been submitted to Workbench, periodically polling it's execution status.

Watch a K8S job that has been submitted to Workbench, periodically
polling it's execution status.

## Usage

``` r
abba_watch_k8s_job_local(
  job_id = "",
  poll_interval_seconds = 3,
  timeout_seconds = 600,
  namespace = getOption("abba.k8s.namespace")
)
```

## Arguments

- job_id:

  Job ID. Typically obtained as a return value from submit_job and
  similar functions

- poll_interval_seconds:

  Time interval for polling job status in seconds

- timeout_seconds:

  Total time to wait before timeout in seconds

- namespace:

  Kubernetes namespace

## Value

a list of pods, their IDs and execution statuses

## Examples

``` r
if (FALSE) { # \dontrun{
result <- abba_watch_k8s_job_local("job-sdtm-f0bf6848-46de-45b8-9fae-0e732b104760", 10, 3000)
} # }
```
