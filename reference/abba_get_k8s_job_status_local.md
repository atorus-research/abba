# Get status of all pods that belong to a job

Get status of all pods that belong to a job

## Usage

``` r
abba_get_k8s_job_status_local(
  job_id,
  namespace = getOption("abba.k8s.namespace")
)
```

## Arguments

- job_id:

  unique identifier for a job

- namespace:

  Kubernetes namespace

## Value

list of statuses for every pod in a job(typically just one).

## Examples

``` r
if (FALSE) { # \dontrun{
status <- abba_get_k8s_job_status_local("job-sdtm-abc123")
} # }
```
