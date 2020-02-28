source("R/index.R")
index <- covid19_index()

report <- NULL
for (entry in index) {
  report <- rbind(report, covid19_parse(entry))
}

pins::board_register_github(repo = "javierluraschi/covid19", branch = "datasets")
pins::pin(report, "covid19", board = "github")
