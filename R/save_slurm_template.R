#' Save Slurm SBATCH job file in temporary directory.
#'
#' @param slurm_obj A character vector representing Slurm SBATCH job file
#' @param file_path Optional. Full filepath for to-be-saved SBATCH job config
#'
#' @return Full path to the saved SBATCH job config
#' @noRd
save_slurm_template <- function(slurm_obj, file_path=''){

  config_path <- if(file_path=='') tempfile(fileext = '.submit') else file_path

  writeLines(slurm_obj, config_path)

  return(config_path)
}
