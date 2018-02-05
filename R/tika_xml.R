#' Extract xml rendition
#'
#' @param input Character vector describing the paths and/or urls to the input documents.
#' @param ... Other parameters to be sent to `tika`.
#' @return A character vector in the same order and with the same length as \code{input}. Unprocessed files are \code{as.character(NA)}.
#' @examples
#' input= 'https://cran.r-project.org/doc/manuals/r-release/R-data.pdf'
#' output = tika_xml(input)
#' cat(output)


tika_xml <- function(input, ...){
  tika(input=input, output="xml", ...)
}