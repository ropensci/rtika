.onLoad <- function(libname, pkgname) {
  cat('If you see Java version 7 or higher, you are good to go. If not, check the documentation. \n')
  tmp= sys::exec_wait('java','-version')
}