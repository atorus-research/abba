# abba Options

*abba* has several configurable options to control the scope of what
users are permitted to do in their job submission. These options are
applied **on the API side**, and should be considered by the individual
setting up the API deployment.

Note that the CPU and memory thresholds are exceptionally important
considerations for Kubernetes. Kubernetes will accept any specification
that means the schema of its API, and its on the ownership of the job
submitter to consider if the submitted job can physically be executed
within their specific cluster. If you specify a job with 512 bytes of
RAM, the job will try to run and fail because the container cannot
successfully launch in the first place. If you submit a job requesting
5000 cores, Kubernetes will continue waiting until is has an available
node with 5000 cores. We say this from experience, so save yourself the
trouble and make sure these options are configured appropriately!

| Option                    | Default                   | Description                                                                                                                                                                                                |
|---------------------------|---------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| abba.lower.cpu.limit      | 0.001                     | The lower threshold of CPU allowed during a job submission                                                                                                                                                 |
| abba.cpu.limit            | 2                         | The upper threshold of CPU allowed during a job submission                                                                                                                                                 |
| abba.lower.memory.limit   | ‘128M’                    | The lower threshold of memory allowed during a job submission                                                                                                                                              |
| abba.memory.limit         | ‘1G’                      | The upper threshold of memory allowed during a job submission                                                                                                                                              |
| abba.permitted.containers | NULL                      | A character vector containing the list of containers permitted for job executing. Use this option to prevent users from using unauthorized container environments. When NULL, no restrictions are applied. |
| abba.default.container    | NULL                      | The default container used for job submission. When the `container` parameter is left empty, this container will be used.                                                                                  |
| abba.r.versions.path      | ‘/etc/rstudio/r-versions’ | Path to the Posit Workbench R versions configuration file. Override this if your Workbench installation uses a non-standard location.                                                                      |
