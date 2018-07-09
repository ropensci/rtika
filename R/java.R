#' System Command to Run Java
#'
#' Gets the system command needed to run Java from the command line, as a string.
#' Typically, this is the string: 'java'. 
#' However, if the R session has the \code{JAVA_HOME} environmental variable set, it will use that to locate java instead. 
#' This can be persisted over sessions (see the Details below). 
#'
#' @return The system command needed to invoke Java, as a string.
#' @examples
#' \donttest{
#' # Typically, this function returns the string 'java'.
#' # If JAVA_HOME is set, it's a path to java in a 'bin' folder.
#' java()
#' }
#' @section Details:
#' This function is used by all of the \code{tika()} functions internally as the default value to its \code{java} parameter. 
#' 
#' This function tries to find an environmental variable using \code{Sys.getenv("JAVA_HOME")}.
#' It looks for the \code{java} executable inside the \code{bin} directory in the \code{JAVA_HOME} directory.
#' 
#' If you want to use a specific version of Java, set the \code{JAVA_HOME} variable using \code{Sys.setenv(JAVA_HOME = 'my path')},
#' where 'my path' is the path to a folder that has a \code{bin} directory with a \code{java} executable. 
#' 
#' For example, on Windows 10 \code{JAVA_HOME} might be \code{C:/Program Files (x86)/Java/jre1.8.0_171}. 
#' On Ubuntu and OS X, it might be the \code{/usr} directory.  
#' 
#' The \code{JAVA_HOME} variable can also be set to persist over sessions.
#' Add the path to the \code{.Rprofile} by adding \code{Sys.setenv(JAVA_HOME = 'my path')}, and it will use that every time R is started.
#' 
#' @export
java <- function() {
        JAVA_HOME = Sys.getenv("JAVA_HOME", unset = "")
        if(JAVA_HOME != ""){ 
            command = suppressWarnings(normalizePath(file.path(JAVA_HOME, "bin", "java"), winslash = "/"))
            return(command)
        } else {
            return('java')
        }
    }
