
rtika
=====

***Extract text or metadata from over a thousand file types.***

[![Travis-CI Build Status](https://travis-ci.org/predict-r/rtika.svg?branch=master)](https://travis-ci.org/predict-r/rtika) [![Coverage status](https://codecov.io/gh/predict-r/rtika/branch/master/graph/badge.svg)](https://codecov.io/github/predict-r/rtika?branch=master)

> Apache Tika is a content detection and analysis framework, written in Java, stewarded at the Apache Software Foundation. It detects and extracts metadata and text from over a thousand different file types, and as well as providing a Java library, has server and command-line editions suitable for use from other programming languages ...

> For most of the more common and popular formats, Tika then provides content extraction, metadata extraction and language identification capabilities. (From <https://en.wikipedia.org/wiki/Apache_Tika>, accessed Jan 18, 2018)

This is an R interface to the Tika software.

See the complete usage instructions and introductory article at <http://predict-r.github.io/rtika>.

Installation
------------

To start, you need R and either `OpenJDK 1.7` or `Java 7`. Higher versions work. To check your version, run the command `java -version` from a terminal. Get Java installation tips at <http://openjdk.java.net/install/> or <https://www.java.com/en/download/help/download_options.xml>.

Next, install the `rtika` package.

``` r
# We also need devtools to easily install from github, until this is all on CRAN 
if(!requireNamespace('devtools')){
  install.packages('devtools',
    repos='https://cloud.r-project.org')
}

if(!requireNamespace('rtika')){
  devtools::install_github('predict-r/rtika')
}

library('rtika')  
```

The `rJava` package is **not** required.

Again, see the complete usage instructions and introductory article at <http://predict-r.github.io/rtika>.

Key Features
------------

-   `tika_text()` to extract plain text.
-   `tika_xml()` and `tika_html()` to extract an XHMTL rendition.
-   `tika_json()` to get metadata and examine complex documents.
-   `tika()` to extract plain text or the other types. This is the main function the others above inherit from.
-   `tika_fetch()` to download files with a file extension matching the Content-Type.

Supported File Types
--------------------

Tika parses and extracts text or metadata from over one thousand digital formats, including:

-   Portable Document Format (`.pdf`)
-   Microsoft Office document formats (Word, PowerPoint, Excel, etc.)
-   Rich Text Format (`.rtf`)
-   Electronic Publication Format (`.epub`)
-   Image formats (`.jpeg`, `.png`, etc.)
-   Mail formats (`.mbox`, Outlook)
-   HyperText Markup Language (`.html`)
-   XML and derived formats (`.xml`, etc.)
-   Compression and packaging formats (`.gzip`, `.rar`, etc.)
-   OpenDocument Format
-   iWorks document formats
-   WordPerfect document formats
-   Text formats
-   Feed and Syndication formats
-   Help formats
-   Audio formats
-   Video formats
-   Java class files and archives
-   Source code
-   CAD formats
-   Font formats
-   Scientific formats
-   Executable programs and libraries
-   Crypto formats

For a list of MIME types, see: <https://tika.apache.org/1.17/formats.html>

Simple Example
--------------

**The `rtika` package processes batches of documents efficiently**, so I recommend batches. Currently, all the `tika()` functions take a tiny bit of time to spin up, and that will get annoying with hundreds of separate calls the functions.

``` r
library('magrittr')

# Local files or remote urls. Here, remote urls.
batch <- c('https://cran.r-project.org/doc/manuals/r-release/R-data.pdf'
           ,'https://cran.r-project.org/doc/manuals/r-release/R-lang.html')

# A short data pipleine, shown with magrittr.
# Normal syntax also works, e.g. text <- tika_text(batch)
text <-  
  batch %>%
  tika_text() 


# Look at the structure returned. 
# It's a character vector. 
# There is one string for each document.
utils::str(text)
#>  chr [1:2] "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nR Data Import/Export\"| __truncated__ ...

# Look at a snippet:
base::cat(base::substr(text[1],45,160)) 
#> 
#> R Data Import/Export
#> Version 3.4.3 (2017-11-30)
#> 
#> R Core Team
#> 
#> 
#> 
#> This manual is for R, version 3.4.3 (2017-11-30).
```

More examples can be found at <http://predict-r.github.io/rtika>.

Similar Packages
----------------

There is some overlap with many other text parsers, such as the R interface to antiword (See: <https://github.com/ropensci/antiword>). Listing all of them would take a huge amount of space, since Apache Tika processes over a thousand file types (See: <https://tika.apache.org/>). The main difference is that instead of specializing on a single format, Tika integrates dozens of specialist libraries from the Apache Foundation. Tika's unified approach offers a bit less control, and in return eases the parsing of digital archives filled with possibly unpredictable file types.

In September 2017, github.com user *kyusque* released `tikaR`, which uses the `rJava` package to interact with Tika (See: <https://github.com/kyusque/tikaR>). As of writing, it provided similar text and metadata extraction, but only `xml` output.

Back in March 2012, I started a similar project to interface with Apache Tika. My code also used low-level functions from the `rJava` package. I halted development after discovering that the Tika command line interface (CLI) was easier to use. My empty repository is at <https://r-forge.r-project.org/projects/r-tika/>.

I chose to finally develop this package after getting excited by Tika's new 'batch processor' module, written in Java. The batch processor has very good efficiency when processing tens of thousands of documents. Further, it is not too slow for a single document either, and handles errors gracefully. Connecting `R` to the Tika batch processor turned out to be relatively simple, because the `R` code is simple. It uses the CLI to point Tika to the files. Simplicity, along with continuous testing, should ease integration. I anticipate that some researchers will need plain text output, while others will want `json` output. Some will want multiple processing threads to speed things up. These features are now implemented in `rtika`, although apparently not in `tikaR` yet.

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
