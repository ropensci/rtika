#' Check Tika against a checksum
#'
#' This is used by \code{install_tika()} internally, 
#' or can be called directly on a \code{jar} file.
#' The latest \code{jar} files and checksums are at https://tika.apache.org/download.html.
#'
#' @param digest Character vector of length one with the target checksum. 
#' @param jar Optional alternative path to a Tika \code{jar} file.
#' @param algo Optional algorithm used to create checksum. Defaults to SHA512. 
#' @return logical if the \code{jar} checksum matches \code{digest}.
#' @export
tika_check <- function(digest, jar = tika_jar(), algo='sha512') {
  base::stopifnot(
    length(digest) == 1
    , class(digest) == "character"
  )
    #tools::md5sum(jar) == md5_sum 
    digest::digest(jar, file = TRUE, algo = algo) == digest
 
}
