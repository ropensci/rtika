#' Check tika_jar() against a md5 checksum
#'
#' Checks the incuded Tika library, using the \code{tools::md5sum()} command.
#' The latest checksums are at https://tika.apache.org/download.html.
#' Note that these may ahead of the Tika version included in this package.
#'
#' @param md5_sum Character vector of length one with the target md5 checksum.
#' @return logical if the .jar matches the md5
#' @examples
#' tika_check('e2720c2392c1bd6634cc4a8801f7363a') #checksum of tika-app-1.17.jar
#' @export
tika_check <- function(md5_sum){
    
    base::stopifnot(length(md5_sum)==1
                    ,class(md5_sum)=='character')
    
    tools::md5sum(tika_jar())==md5_sum
}
