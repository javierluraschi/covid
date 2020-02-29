covid19_parse <- function(input = NULL) {
  if (is.null(input)) input <- covid19_index()[1,]
  report_date <- gsub(".*situation-reports/|\\-.*", "", input)

  pdf <- tempfile(fileext = ".pdf")
  download.file(input, pdf)

  tabulizer::extract_tables(pdf)
}
