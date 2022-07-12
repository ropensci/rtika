# rtika (development version)

rtika 2.0.0 (2021-08-05)
========================= 

    * Updated Tika to 2.0.0. Details are found at https://tika.apache.org/2.0.0/index.html .

rtika 1.23 (2020-04-24)
========================= 

### MINOR IMPROVEMENTS

    * Updated Tika to 1.24.1. Details are found at https://tika.apache.org/1.24.1/index.html .

rtika 1.23 (2019-12-12)
========================= 

### MINOR IMPROVEMENTS

    * Updated Tika to 1.23. Details are found at https://tika.apache.org/1.23/index.html .
    
rtika 1.22 (2019-08-01)
========================= 

### MINOR IMPROVEMENTS

    * Updated Tika to 1.22
    
rtika 1.20 (2019-02-26)
========================= 

### MINOR IMPROVEMENTS

    * Updated Tika to 1.20
    * Includes two config files to either turn on or off OCR. This is only relevant on Linux variants that have the Tesseract OCR engine installed.
    
### BUG FIX

    * Created a workaround because normalizePath() on Windows produced inconsistent results. 

rtika 1.19.1 (2018-07-08)
========================= 

### MINOR IMPROVEMENTS

    * Updated Tika to 1.19.1.
    * Updated the 'sys' package integration, and Jeroen informed the Tika team of an unexpected method of interprocess communication in the batch processor.


 rtika 1.1.19 (2018-07-08)
========================= 

### NEW FEATURES

  * The new java() function is used get the command to invoke Java for all tika() functions, and allows the option of changing its value across sessions. If you want to use a particular installation of Java, set the JAVA_HOME variable using the Sys.setenv(JAVA_HOME = 'my path'). The java() function will check for this variable, and if found return it instead of the default 'java' invocation. 
  * Updated to Tika version 1.19. 

### MINOR IMPROVEMENTS

  * The tika_check function now uses the more advance SHA512 checksum instead of the MD5. To implement this, the 'digest' package is now a dependency.

 rtika 0.1.8 (2018-04-25)
========================= 

### MINOR IMPROVEMENTS

  * The install_tika() function now gets the Tika 1.18 release that came out 2018-04-24, instead of the 1.18 development version.
rtika 0.1.7 (2018-03-08)
========================= 

### MINOR IMPROVEMENTS

  * The new install_tika() function allows this package to be distributed on CRAN. The Tika App jar was too large to go on CRAN directly. The .jar is installed in the directory determined by the rappdirs::user_data_dir() function. 
  * The .onLoad() function now gives various installation advice when starting up. 
  

### DEPRECATED AND DEFUNCT
  * Removed the .jar in favor of the install_tika() function.

 rtika 0.1.6 (2018-03-01)
========================= 

### NEW FEATURES

  *  tika(), tika_xml(), tika_json(), tika_text(), and tika_html() have a new downloader, which preserve the server's content-type encoding as a file extension when possible. This should help Tika identify and parse downloaded files more reliably. It depends on the 'curl' package.
  * Added tika_fetch(), which is a stand alone function to download files and append a file extension matching the content type declared by the server. Additional features for this function include specifying the number of download retries. The output of tika_fetch() can be piped directly into other tika functions.
  * New introductory vignette covers how to use the functions and surveys several applications.
  * tika(), tika_xml(), tika_json(), tika_text(), and tika_html() can now be set to return=FALSE, which does not return any R character vector but invisibly returns NULL. This would be most useful in massive file conversion jobs with hundreds of thousands of files.
  * Used pkgdown to create a website for github pages.
  * New tika_json_text() function gets metadata in .json with plain text content.

### DEPRECATED AND DEFUNCT

  * Previous vignette has been removed in favor of new one.
  * The tikajar package is not required in this version.  Moved the .jar file back into this package to ease installation until I hear from CRAN. 
  
rtika 0.1.5 (2018-02-15)
=========================

### MINOR IMPROVEMENTS

  * Added dependency on 'sys' package because the 'system2' function was causing intermittent errors by ending tika in mid process.
  * Added startup check of the java version, using .onLoad() call to 'java -version'
  * Removed redundant conversion to UTF-8, because the Tika batch routine is already outputting UTF-8. 
  * Increased the speed of building packages (fewer downloads needed for testing, and the examples do not run).
  * Added Code of Conduct to CONDUCT.md file
  * Set default 'cleanup' attribute to TRUE.
  
rtika 0.1.4 (2018-02-15)
=========================

### MINOR IMPROVEMENTS

  * Because it is too big for CRAN, removed the Tika .jar file.
  * Added the Tika .jar to a new tikajar package on github.
  * Put the ropensci review badge on the tikajar package also, since its an essential component of this package.
  * Updated DESCRIPTION, documentation and .travis.yml to reflect the new installation routine.

rtika 0.1.3 (2018-02-04)
=========================

### NEW FEATURES

  * added convenience functions that advertise output format: tika_xml(), tika_json(), tika_text(), tika_html().
  
### MINOR IMPROVEMENTS 

  * README examples use magrittr pipe.
  
rtika 0.1.2 (2018-01-30)
=========================

### NEW FEATURES

  * added many tests to increase code coverage dramatically.
  * integrated the covr package.
  
### MINOR IMPROVEMENTS 

  * for Windows users, the curl package is recommended to prevent base R download.file from corrupting files.

### DEPRECATED AND DEFUNCT

  * removed the n_chars parameter in favor of using  file.size() internally.
  * removed onLoad.R that checked java version in order to speed package loading and simplify code coverage testing.
  
rtika 0.1.1 (2018-01-23)
=========================

### NEW FEATURES

  * allows the user to input the URLs and file paths of documents. URLs will be downloaded first to a temporary directory. The previous interface has been changed.
  
### MINOR IMPROVEMENTS

  * the Tika License file is included in the source.
  * added a vignette on basic text processing using the library.

rtika 0.1.0 (2018-01-19)
=========================

### NEW FEATURES

  * Initial release.
  * R interface to Apache Tika batch processing CLI, found to be the most efficient CLI option.
  * tika function returns processing results as a character vector.
  * includes the Tika App .jar. Tika source is available at: https://github.com/apache/tika






