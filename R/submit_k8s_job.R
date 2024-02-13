#' Submit a Kubernetes Job from an R Function
#'
#' This function allows you to submit a job to a Kubernetes cluster by modifying a YAML template
#' with specific parameters and using the `kubectl` command.
#' 
#' @param job_name The name of the job to be submitted.
#' @param generate_name A generated name (UUID) for the job.
#' @param user_tag A user-defined tag for the job.
#' @param program_full_name The full path and name of the R program to be executed.
#' @param service_user The service user account name.
#' @param cpu_limit The CPU limit for the job.
#' @param memory_limit The memory limit for the job (in MB).
#' @return Invisible NULL, the function is called for its side effect.
#' @export
#' @examples
#' submit_k8s_job("my-job", "my-job-", "special-tag", "/path/to/my-script.R", "my-user", 1, 512)
#'
#' @importFrom yaml read_yaml
#' @importFrom yaml write_yaml
#' @importFrom stringr str_replace
submit_k8s_job <- function(job_name, user_tag, program_full_name, service_user, cpu_limit, memory_limit) {
  # Load required libraries
  library(yaml)
  library(stringr)
  
  # Load the YAML file
  yaml_file <- "path_to_yaml_file.yaml"
  yaml_content <- read_yaml(yaml_file)
  
  # Replace placeholders with function arguments
  yaml_content$metadata$name <- job_name
  yaml_content$metadata$generateName <- generate_uuid()
  yaml_content$template$metadata$generateName <- generate_name
  yaml_content$template$metadata$annotations$USER_TAG_0 <- user_tag
  yaml_content$template$metadata$annotations$name <- basename(program_full_name)
  yaml_content$template$spec$containers[[1]]$args[3] <- 
    sub("PROGRAM_FULL_NAME", program_full_name, yaml_content$template$spec$containers[[1]]$args[3])
  yaml_content$template$spec$containers[[1]]$env[[1]]$value <- paste0("/home/", service_user)
  yaml_content$template$spec$volumes[[1]]$nfs$path <- paste0("/home/", service_user)
  yaml_content$template$spec$containers[[1]]$resources$limits$cpu <- as.character(cpu_limit)
  yaml_content$template$spec$containers[[1]]$resources$limits$memory <- memory_limit
  

  
  # Save the modified YAML
  temp_yaml <- tempfile(fileext = ".yaml")
  write_yaml(yaml_content, temp_yaml)
  
  # Run kubectl command to submit the job
  system(paste("kubectl apply -f", temp_yaml))
  
  # Optionally delete the temporary YAML file
  unlink(temp_yaml)
}


