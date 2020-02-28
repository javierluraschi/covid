covid19_parse <- function(input = NULL) {
  if (is.null(input)) input <- covid19_index()[1,]

  pdf <- tempfile(fileext = ".pdf")
  download.file(input, pdf)

  pdf
}
