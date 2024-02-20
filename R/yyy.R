.onLoad <- function(libname, pkgname) {
  options(abba.cpu.limit = 4L,
          abba.memory.limit=2048
  )
  invisible()
}
