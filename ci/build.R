sapply(dir("R", full.names = T), source)

pins::board_register_github(repo = "javierluraschi/covid", branch = "datasets")

index_processed <- c()
index <- covid19_index()

if (nrow(pins::pin_find("covid-index", board = "github")) > 0) {
  index_processed <- pins::pin_get("covid-index", board = "github")$processed
}

index <- index[!index %in% index_processed]

for (entry in index) {
  report_date <- gsub(".*situation-reports/|\\-.*", "", entry)
  tables <- covid19_parse(entry)

  # remove lists from tables
  tables <- Filter(function(e) !any(grepl("•", e[,1])), tables)

  for (table_num in seq_along(tables)) {
    name <- paste0("covid-", report_date, "-", table_num)
    data <- tibble::as_tibble(as.data.frame(tables[[table_num]], stringsAsFactors = FALSE))

    pins::pin(data, name = name, board = "github")
  }
}

pins::pin(data.frame(processed = index, stringsAsFactors = FALSE), name = "covid-index", board = "github")
