# Submit a job profile for execution on a Kubernetes cluster

Submit a job profile for execution on a Kubernetes cluster

## Usage

``` r
submit_k8s_yaml(yaml_full_path)
```

## Arguments

- yaml_full_path:

  Path to YAML config file

## Value

A string containing Job ID

## Examples

``` r
if (FALSE) { # \dontrun{
job_id <- submit_k8s_yaml("/tmp/my_job.yaml")
} # }
```
