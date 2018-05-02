#' Get json Metadata and XHTML Content 
#'
#'  Tika can parse and extract text from almost anything, including zip, tar, tar.bz2, and other archives that contain documents.
#'  If you have a zip file with 100 text files in it, you can get the text and metadata for each file nested inside of the zip file.
#'  This recursive output is currently used for the jsonified mode. See:  https://wiki.apache.org/tika/RecursiveMetadata
#'  
#'  The document content is XHTML in the "X-TIKA:content" field.
#'   
#'  If \code{output_dir} is specified, files will have the \code{.json} file extension.
#'
#' @param input Character vector describing the paths and/or urls to the input documents.
#' @param ... Other parameters to be sent to \code{tika()}.
#' @return A character vector in the same order and with the same length as \code{input}, of unparsed \code{json}. Unprocessed files are \code{as.character(NA)}.
#' @examples
#' \donttest{
#' batch <- c(
#'  system.file("extdata", "jsonlite.pdf", package = "rtika"),
#'  system.file("extdata", "curl.pdf", package = "rtika"),
#'  system.file("extdata", "table.docx", package = "rtika"),
#'  system.file("extdata", "xml2.pdf", package = "rtika"),
#'  system.file("extdata", "R-FAQ.html", package = "rtika"),
#'  system.file("extdata", "calculator.jpg", package = "rtika"),
#'  system.file("extdata", "tika.apache.org.zip", package = "rtika")
#' )
#' json <- tika_json(batch)
#' }
#' @export
tika_json <- function(input, ...) {
  tika(input = input, output = "jsonRecursive", ...)
}
