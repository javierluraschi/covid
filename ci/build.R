source("R/index.R")
index <- covid19_index()

pins::board_register_github(repo = "javierluraschi/covid19", branch = "datasets")
pins::pin(index, "covid19", board = "github")
