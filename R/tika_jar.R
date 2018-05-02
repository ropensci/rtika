#' Path to Apache Tika
#'
#' Gets the path to the Tika App \code{.jar} installed by \code{tika_install()}.
#' @return A string describing the file path to the Tika App \code{.jar} file. If not found, \code{NA}.
#' @examples
#' \donttest{
#' jar <- tika_jar()
#' # see help
#' sys::exec_wait('java',c('-jar',jar, '--help'))
#' # detect language of web page
#' sys::exec_wait('java',c('-jar',jar, '--language','https://tika.apache.org/'))
#' }
#' @section Details:
#' The \code{tika_jar()} function also checks if the \code{.jar} is actually on the file system.
#'
#' The file path is used by all of the \code{tika()} functions by default.
#'
#' @section Alternative Uses:
#' You can call Apache Tika directly,
#' as shown in the examples here.
#' 
#' It is better to use the \code{sys} package and avoid \code{system2()},
#' which has caused erratic, intermittent errors with Tika.
#'
#' @export
tika_jar <- function() {
  path <- file.path(
    rappdirs::user_data_dir("rtika"),
    paste0("tika-app.jar")
  )

  tryCatch(
    normalizePath(path, mustWork = TRUE),
    error = function(x) {
      return(as.character(NA))
    }
  )
}
