context("Connecting to Tika")

urls = c('https://cran.r-project.org/doc/manuals/r-release/R-data.pdf','https://cran.r-project.org/doc/manuals/r-release/R-lang.pdf','https://cran.r-project.org/doc/manuals/r-release/R-exts.epub','https://cran.r-project.org/doc/manuals/r-release/R-FAQ.html' )
input = replicate(length(urls),tempfile('test_tika'))
for(i in seq_along(urls)){
  download.file(urls[i],input[i])
}

test_that("tika parses single pdf", {
  text = tika(input[1])
  expect_equal(length(text),1)
  expect_true(nchar(text[1]) > 0)
})

test_that("tika parses multiple files", {
  text = tika(input)
  expect_equal(length(text),length(input))
  for(i in seq_along(urls)){
    expect_true(nchar(text[i]) > 0)
  }
})