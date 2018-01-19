.onLoad <- function(libname, pkgname) {
 cat('If you see Java version 8 or higher, you are good to go. If not, see the documentation. \n')
 tmp= sys::exec_wait('java','-version')
}