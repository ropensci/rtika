#' Extract json of file and all embedded documents
#'
#'  Tika can parse and extract text from almost anything, including zip, tar, tar.bz2, and other archives that contain documents. 
#'  If you have a zip file with 100 text files in it, you can get the text and metadata for each file nested inside of the zip file.
#'  This recursive output is currently used for the jsonified mode. The text content of documents is in the "X-TIKA:content" field.
#'   See:  https://wiki.apache.org/tika/RecursiveMetadata
#'
#' @param input Character vector describing the paths and/or urls to the input documents.
#' @param ... Other parameters to be sent to `tika`.
#' @return A character vector in the same order and with the same length as \code{input}. Unprocessed files are \code{as.character(NA)}.
#' @examples
#' \donttest{
#' input= 'https://cran.r-project.org/doc/manuals/r-release/R-data.pdf'
#' output = tika_json(input)
#' cat(output)
#' }
#' @export
tika_json <- function(input, ...){
  tika(input=input, output="jsonRecursive", ...)
}
