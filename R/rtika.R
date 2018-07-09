#' rtika: R Interface to 'Apache Tika' 
#'
#' Extract text or metadata from over a thousand file types. Get either plain text or structured XHTML content.
#' 
#' @section Installing:
#' 
#' If you have not done so already, finish installing \pkg{rtika} by typing in the R console:
#'
#' \code{install_tika()}
#'   
#' @section Getting Started:
#' 
#' The \code{\link{tika_text}} function will extract plain text from many types of documents. It is a good place to start. Please read the Vignette also.
#' Other main functions include \code{\link{tika_xml}} and \code{\link{tika_html}} that get a structured XHMTL rendition. The \code{\link{tika_json}} function gets metadata as `.json`, with XHMTL content. 
#' 
#' The \code{\link{tika_json_text}} function gets metadata as `.json`, with plain text content.
#' 
#' \code{\link{tika}} is the main function the others above inherit from. 
#'  
#' Use \code{\link{tika_fetch}} to download files with a file extension matching the Content-Type.
#'
#' @docType package
#' @name rtika
NULL