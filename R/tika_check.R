#' Check Tika against a md5 checksum
#'
#' This is used by \code{install_tika()} internally, 
#' or can be called directly on a \code{jar} file.
#' The latest \code{jar} files and checksums are at https://tika.apache.org/download.html.
#' The \code{tools::md5sum()} function is used here. 
#' Optionally, a user may install and use the \code{digest::digest()} function
#' to double check the \code{SHA-512} checksum
#' for the \code{tika_jar()} file.
#'
#' @param md5_sum Character vector of length one with the target md5 checksum.
#' @param jar Optional alternative path to a Tika \code{jar} file. 
#' @return logical if the \code{jar} checksum matches \code{md5_sum}.
#' @export
tika_check <- function(md5_sum, jar = tika_jar()) {
  base::stopifnot(
    length(md5_sum) == 1
    , class(md5_sum) == "character"
  )

  tools::md5sum(jar) == md5_sum
}
