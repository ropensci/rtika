context("Connecting to Tika")

# we are not allowed to install the Tika jar automatically on CRAN

# the plan is to use skip_on_cran()

# so tests run on travis but are skipped on CRAN.

# install the jar after the skip_on_cran(), so 
install_if_needed <- function(){
  if(is.na(rtika::tika_jar())){
      rtika::install_tika()
  }
}


input <- c(
  system.file("extdata", "jsonlite.pdf", package = "rtika"),
  system.file("extdata", "curl.pdf", package = "rtika"),
  system.file("extdata", "table.docx", package = "rtika"),
  system.file("extdata", "xml2.pdf", package = "rtika"),
  system.file("extdata", "R-FAQ.html", package = "rtika"),
  system.file("extdata", "calculator.jpg", package = "rtika"),
  system.file("extdata", "tika.apache.org.zip", package = "rtika")
)

test_that("gets valid path", {
  skip_on_cran()
  install_if_needed()
  
  path <- tika_jar()
  expect_true(length(path) == 1)
  expect_true(class(path) == "character")
  expect_true(file.exists(path))
})

test_that("check_md5_sum only works with character strings ", {
  skip_on_cran()
  install_if_needed()
  
  expect_error(tika_check(777))
})

test_that("check_md5_sum fails with wrong checksum", {
  skip_on_cran()
  install_if_needed()
  
  install_if_needed()
  expect_false(tika_check("not a checksum"))
})


# test_that("md5_sum is correct for this version", {
#   skip_on_cran()
#   install_if_needed()
#   
#   expect_true(tika_check("e2720c2392c1bd6634cc4a8801f7363a"))
# })


# causes problem with travis, but not locally. May need to skip
test_that("tika warns with url to nowhere without curl package", {
  skip_on_cran()
  install_if_needed()
  
  nowhere <- "http://www.predict-r.com/rtika_testing_coverage_file_not_here.txt"
  expect_warning(tika(nowhere, lib.loc = ""))
})
# causes problem with travis, but not locally. May need to skip
test_that("tika stops when output_dir is root", {
  skip_on_cran()
  install_if_needed()
  
  expect_error(tika(input[1], output_dir = file.path("/")))
})

test_that("tika parses a local pdf without curl packages", {
  skip_on_cran()
  install_if_needed()
  
  text <- tika(input[1], lib.loc = "")
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})

test_that("tika handles fake file without curl packages", {
  skip_on_cran()
  install_if_needed()
  
  nowhere <- file.path("/rtika_fake_file_not_here.txt")
  expect_warning(text <- tika(nowhere, lib.loc = ""))
  expect_equal(length(text), 1)
  expect_equal(text[1], as.character(NA))
})

test_that("tika parses a single remote pdf without curl package", {
  skip_on_cran()
  install_if_needed()
  
  urls <- c(
    "https://cran.r-project.org/doc/manuals/r-release/R-data.pdf"
    , "https://cran.r-project.org/doc/manuals/r-release/R-exts.epub"
    , "https://cran.r-project.org/doc/manuals/r-release/R-FAQ.html"
  )
  text <- tika(urls[1], lib.loc = "")
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})


# causes problem with travis, but not locally. Skipping on github for now.
test_that("tika warns with url to nowhere with curl package", {
  skip_on_cran()
  install_if_needed()
  
  nowhere <- "http://www.predict-r.com/rtika_testing_coverage_file_not_here.txt"
  expect_warning(tika(nowhere))
})

test_that("tika parses single local pdf", {
  skip_on_cran()
  install_if_needed()
  
  text <- tika(input[1])
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})

test_that("tika parses multiple local files", {
  skip_on_cran()
  install_if_needed()
  
  text <- tika(input)
  expect_equal(length(text), length(input))
  expect_true(!any(is.na(text)))
  expect_true(all(nchar(text) > 0))
})


test_that("tika parses a single remote pdf", {
  skip_on_cran()
  install_if_needed()
  
  urls <- c(
    "https://cran.r-project.org/doc/manuals/r-release/R-data.pdf"
    , "https://cran.r-project.org/doc/manuals/r-release/R-exts.epub"
    , "https://cran.r-project.org/doc/manuals/r-release/R-FAQ.html"
  )
  text <- tika(urls[1])
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})


test_that("tika warns with path to nowhere", {
  skip_on_cran()
  install_if_needed()
  
  expect_warning(tika(file.path("/rtika_fake_file_not_here.txt")))
})

test_that("tika outputs NA with a path to nowhere", {
  skip_on_cran()
  install_if_needed()
  
  nowhere <- file.path("/rtika_fake_file_not_here.txt")
  text <- ""
  text <- expect_warning(tika(nowhere))
  expect_equal(length(text), 1)
  expect_equal(text[1], as.character(NA))
})

test_that("tika outputs NA with a path to nowhere in right order", {
  skip_on_cran()
  install_if_needed()
  
  nowhere <- file.path("/rtika_fake_file_not_here.txt")
  text <- tika(c(input[1], nowhere, input[2]))
  expect_equal(text[2], as.character(NA))
  expect_equal(length(text), 3)
  expect_true(all(nchar(text[c(1, 3)]) > 0))
})

test_that("tika warns with NA input", {
  skip_on_cran()
  install_if_needed()
  
  nowhere <- as.character(NA)
  expect_warning(text <- tika(nowhere))
  expect_equal(length(text), 1)
  expect_equal(text[1], as.character(NA))
})





test_that("tika outputs parsable xml", {
  skip_on_cran()
  install_if_needed()
  
  # library('xml2')
  text <- tika_xml(input)
  processed_xml <- NA
  processed_xml <- xml2::read_xml(text[1])
  expect_true(!is.na(processed_xml))

  processed_xml <- NA
  processed_xml <- xml2::read_xml(text[2])
  expect_true(!is.na(processed_xml))

  processed_xml <- NA
  processed_xml <- xml2::read_xml(text[3])
  expect_true(!is.na(processed_xml))
})

test_that("tika outputs parsable html", {
  skip_on_cran()
  install_if_needed()
  
  # library('xml2')
  text <- tika_html(input)
  processed_html <- NA
  processed_html <- xml2::read_html(text[1])
  expect_true(!is.na(processed_html))

  processed_html <- NA
  processed_html <- xml2::read_html(text[2])
  expect_true(!is.na(processed_html))

  processed_html <- NA
  processed_html <- xml2::read_html(text[3])
  expect_true(!is.na(processed_html))
})


test_that("tika outputs parsable json", {
  skip_on_cran()
  install_if_needed()
  
  # library('jsonlite')
  text <- tika_json(input)
  for (i in seq_along(text)) {
    processed_json <- data.frame()
    processed_json <- jsonlite::fromJSON(text[i])
    expect_true(nrow(processed_json) >= 1)
  }
})

test_that("tika_text works", {
  skip_on_cran()
  install_if_needed()
  
  text <- tika_text(input[1])
  expect_equal(length(text), 1)
  expect_true(!is.na(text[1]))
  expect_true(nchar(text[1]) > 0)
})

test_that("tika puts files into the specified output_dir", {
  skip_on_cran()
  install_if_needed()
  
  test_dir <- tempfile("testthat_rtika_test")
  dir.create(test_dir)
  test_dir <- normalizePath(test_dir, winslash = "/")
  text <- tika(input[1], output_dir = test_dir, cleanup = TRUE)
  files <- list.files(
    test_dir
    , include.dirs = FALSE
    , recursive = TRUE
  )
  expect_true(length(files) > 0)
  full_path <- file.path(test_dir, files)

  expect_true(all(file.exists(full_path)))
  file_info <- file.info(full_path)
  expect_true(!all(file_info$isdir))
})


test_that("tika cleans up", {
  skip_on_cran()
  install_if_needed()

  text <- tika(input[1], cleanup = TRUE)
  expect_equal(length(file.path(
    tempdir()
    , list.files(
      tempdir()
      , pattern = "^rtika_file"
    )
  )), 0)
  expect_equal(length(file.path(
    tempdir()
    , list.files(
      tempdir()
      , pattern = "^rtika_dir"
    )
  )), 0)
})
