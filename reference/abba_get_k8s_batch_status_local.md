# Get status of all jobs in a batch

Get status of all jobs in a batch

## Usage

``` r
abba_get_k8s_batch_status_local(
  batch_id,
  namespace = getOption("abba.k8s.namespace")
)
```

## Arguments

- batch_id:

  unique identifier for a batch

- namespace:

  Kubernetes namespace

## Value

list of statuses for every job in a batch

## Examples

``` r
if (FALSE) { # \dontrun{
status <- abba_get_k8s_batch_status_local("batch-sdtm-abc123")
} # }
```
