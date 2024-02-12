
<!-- README.md is generated from README.Rmd. Please edit that file -->

# abba

**abba** provides management of remote batch execution of programs into
a cluster through a simple programming interface, and additional provide
proper segregation of security identities via API abstraction.

<!-- badges: start -->
<!-- badges: end -->

- Users can submit non-interactive jobs to run on Kubernetes
- Non-interactive jobs can be sent to Kubernetes from Posit Connect
- Jobs sent to Kubernetes from Posit Connect can be called through an R
  function 
- Jobs sent to Kubernetes from Posit Connect can see R programs stored
  in a shared storage space.
- While the job is running on Kubernetes, the submitting function
  monitors the job and waits for its completion
- Upon completion of the job, the resulting log file is collected and is
  viewable
- When executing from Posit Connect, the job is submitted using the
  kubectl utility locally
- The kubectl utility on Posit Connect can only be run under a service
  account identity, and the user submitting the jobs cannot be modifed
- The service account identity must be granted explicit access to files
  it may have to access

## Accessing the dev Kubernetes cluster

workbench-dev.atorusresearch.com

1.  Ensure you have the cluster configured at ~/.kube/configured (Eli
    will do this)

2.  Run jobs via `kubectl apply -f <file>` where file is your YAML file.

3.  check jobs with `kubectl get jobs -n rstuido`

4.  Get job output with `kubectl logs -n rstudio <jobname>`
