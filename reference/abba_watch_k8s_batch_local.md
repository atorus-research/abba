# Watch a K8S batch that has been submitted to Workbench, periodically polling it's execution status.

Watch a K8S batch that has been submitted to Workbench, periodically
polling it's execution status.

## Usage

``` r
abba_watch_k8s_batch_local(
  batch_group_id = "",
  poll_interval_seconds = 3,
  timeout_seconds = 600,
  namespace = getOption("abba.k8s.namespace")
)
```

## Arguments

- batch_group_id:

  Batch ID that was specified when submitting a group of jobs

- poll_interval_seconds:

  Time interval for polling batch status in seconds

- timeout_seconds:

  Total time to wait before timeout in seconds

- namespace:

  Kubernetes namespace

## Value

a list of jobs IDs and statuses that belong to batch named
batch_group_id

## Examples

``` r
if (FALSE) { # \dontrun{
result <- abba_watch_k8s_batch_local("safety-tfls-f0bf6848-46de-45b8-9fae-0e732b104760", 10, 3000)
} # }
```
