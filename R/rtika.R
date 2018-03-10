#' rtika: R Interface to 'Apache Tika' 
#'
#' Extract text or metadata from over a thousand file types. Get either plain text or structured XHTML content.
#' 
#' @section Installing:
#' 
#' If you have not done so already, to finish installing \pkg{rtika} type:
#'
#' \code{\link{install_tika}}
#'   
#' @section Key Features:
#' 
#' \code{\link{tika_text}} to extract plain text.
#'  
#' \code{\link{tika_xml}} and \code{\link{tika_html}} to get a structured XHMTL rendition.
#'  
#' \code{\link{tika_json}} to get metadata as `.json`, with XHMTL content. 
#' 
#' \code{\link{tika_json_text}} to get metadata as `.json`, with plain text content.
#' 
#' \code{\link{tika}} is the main function the others above inherit from. 
#'  
#' \code{\link{tika_fetch}} to download files with a file extension matching the Content-Type.
#'
#' @docType package
#' @name rtika
NULL