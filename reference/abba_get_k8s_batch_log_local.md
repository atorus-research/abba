# Return list of logs for jobs that are marked with a given batch ID

Return list of logs for jobs that are marked with a given batch ID

## Usage

``` r
abba_get_k8s_batch_log_local(
  batch_id,
  namespace = getOption("abba.k8s.namespace")
)
```

## Arguments

- batch_id:

  string containing batch ID

- namespace:

  Kubernetes namespace to search for batch jobs

## Value

Job logs in a from of list consisting of character vectors

## Examples

``` r
if (FALSE) { # \dontrun{
logs <- abba_get_k8s_batch_log_local("batch-sdtm-abc123")
} # }
```
