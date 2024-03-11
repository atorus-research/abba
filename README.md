
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **abba**

**abba** enables users to submit programs for background execution,
allowing you to continue work as usual and not concern yourself with the
job being terminated when you end your interactive session. Furthermore,
by combining **abba** with services like Posit Connect, you can schedule
jobs to run on a routine basis, such as nightly. While services like
Connect allow you to run your work within a designated R environment,
**abba** expands these capabilities by allowing you to send your work to
a server or cluster environment, such as Kubernetes, in a secure manner.

**abba** has three major components:

- End user job submission functions
- Cluster/server interface functions
- Server API template

The server API template serves as the driver for the actual submission
of jobs where they need to execute. This is intentionally separated to
ensure job submission can be done securely, without giving an end user
too much power or access.

The cluster/server interface functions simplify the management of job
submission into a cluster. Currently only Kubernetes is supported. These
methods manage that process and are utilized on within the API template.

The end user job submission functions are what the typical **abba** user
will utilize. These functions provide a simple interface to target what
the end user must concern themselves with, such as the program being
submitted, the resources necessary, the container environment to run
within, and necessary mounts.

# Run a Program

Using function in **abba**, users can send a program to run and retrieve
the results.

``` r
abba_submit_and_get_log(
  "/home/mike.stackhouse/repos/abba/test_programs/test_program.R"
)
```

# Create a Batch File

**abba** has some convenience functions to simplify the setup of a job
that you intend to schedule.

``` r
create_batch_job()
```

This creates an Rmd file in your local directory following a simple
template.

# Create an **abba** API

**abba** also makes it simple to create the necessary **plumber** API
when setting up within your own environment.

``` r
create_batch_api()
```

## Support

If in need of support, contact <support@atorusresearch.com>
