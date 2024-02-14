#' Submit a Kubernetes Job from an R Function
#'
#' This function allows you to submit a job to a Kubernetes cluster by modifying a YAML template
#' with specific parameters and using the `kubectl` command.
#'
#' @param program_full_name The full path and name of the R program to be executed.
#' @param user_tag A user-defined tag for the job.
#' @param cpu_limit The CPU limit for the job.
#' @param memory_limit The memory limit for the job (in MB).
#' @return Invisible NULL, the function is called for its side effect.
#' @export
#' @examples
#' submit_k8s_job("/path/to/my-script.R", user_tag="DMC", cpu_limit=1L, memory_limit="1024M")
submit_k8s_job <- function(program_full_name, user_tag='', cpu_limit=1L, memory_limit="512M") {

  # Load the YAML file
  yaml_file <- load_yaml_template()

  # Replace placeholders with function arguments
  yaml_file_updated <- configure_yaml(yaml_file,
                                      file_path=program_full_name,
                                      user_tag=user_tag,
                                      cpu_limit=cpu_limit,
                                      memory_limit=memory_limit)



  # Save the modified YAML
  temp_yaml <- save_yaml(yaml_file_updated)

  # Run kubectl command to submit the job
  job_id <- submit_yaml(temp_yaml)

  return(job_id)
}


