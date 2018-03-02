#' Path to Apache Tika
#'
#' A library for text and data extraction
#' @return A character vector of length one describing the path to the particular  \code{tika-app-X.XX.jar}.
#' @examples
#' jar = tika_jar()
#' # see help
#' sys::exec_wait('java',c('-jar',jar, '--help'))
#' # detect language of web page
#' sys::exec_wait('java',c('-jar',jar, '--language','https://tika.apache.org/'))
#' @export
tika_jar <- function() {
  base::normalizePath(
    system.file(
      "java"
      , "tika-app-1.17.jar"
      , package = "rtika"
    )
    , mustWork = TRUE
  )
}
