# Get log for every job specified in an input vector/list

Get log for every job specified in an input vector/list

## Usage

``` r
abba_get_k8s_job_log_local(
  job_ids,
  namespace = getOption("abba.k8s.namespace")
)
```

## Arguments

- job_ids:

  A list of job IDs to get logs for

- namespace:

  Kubernetes namespace to search for job

## Value

A list of job logs. Each list entry will contain complete log for a job

## Examples

``` r
if (FALSE) { # \dontrun{
logs <- abba_get_k8s_job_log_local(c("job-sdtm-abc123", "job-adam-def456"))
} # }
```
