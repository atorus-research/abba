# check if command executed via system2 produced any errors
# Generate R error with user specified message if exit code is not 0
system_command_error_check <- function(cmd_output, msg){
  err_msg <- if(is.null(attr(cmd_output, "errmsg"))) "" else paste("Error details:", attr(cmd_output, "errmsg"))
  if (!is.null(attr(cmd_output, "status")) && attr(cmd_output, "status") != 0){
    stop(sprintf(paste0(msg, " %s.\n%s"), cmd_output, err_msg))
  }
}
