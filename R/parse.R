covid19_splitcol <- function(data, index) {
  as.vector(sapply(data, function(e) strsplit(e, " ")[[1]][index]))
}

covid19_rules <- function() {
  list(
    list(
      test = function(entries)
        length(entries) > 2 &&
        nrow(entries[[2]]) > 6 &&
        identical(
          paste(as.character(entries[[2]][1:6,]), collapse = "|"),
          "Province/||Region/||City|||Population||(10,000s)||||||Confirmed||cas es|Daily|||Suspected||cas es|||||Deaths||Cumulative|||Confirmed|Deaths|cases") &&
        identical(
          paste0(entries[[3]][1:10,], collapse = "|"),
          "|||Country/Territory/Area||||||Western Pacific Region|||Confirmed  *||cases (new)||||||||||||||||Likely place of exposure†|Outside|In reporting|China reporting|country and|(new) country|outside China|(new)|(new)||||Total cases with site of|transmission under||investigation (new)|||||||Total|deaths||(new)||||"
        ),
      parse = function(entries) {
        # parse china table
        china <- entries[[2]][7:nrow(entries[[2]]),]
        china <- cbind("China", china)
        base_names <- c("country", "region", "population", "confirmed_daily", "suspected_daily", "deaths_daily", "confirmed_deaths")
        colnames(china) <- base_names

        china <- china[china[,c("region")] != "Total", ]
        china <- cbind(china,
                       covid19_splitcol(china[,c("confirmed_deaths")], 1),
                       covid19_splitcol(china[,c("confirmed_deaths")], 2))

        colnames(china) <- c(base_names, "confirmed", "deaths")
        china <- china[,c("country", "region", "confirmed", "deaths")]

        china

        countries <- c()
        confirmed <- c()
        deaths <- c()
        for (i in 3:length(entries)) {
          valid <- 1:nrow(entries[[i]])
          if (i == 3) valid <- -c(1:10)
          countries <- c(countries, entries[[i]][valid,1])
          confirmed <- c(confirmed, covid19_splitcol(entries[[i]][valid,2], 1))
          deaths <- c(deaths, covid19_splitcol(entries[[i]][valid,ncol(entries[[3]])], 1))
        }

        world <- data.frame(country = countries, region = "", confirmed = confirmed, deaths = deaths, stringsAsFactors = FALSE)

        empty <- c("African Region",
                   "Eastern Mediterranean Region",
                   "European Region",
                   "Region of the Americas",
                   "South-East Asia Region",
                   "Eastern Mediterranean Region",
                   "European Region",
                   "Region of the Americas",
                   "South-East Asia Region",
                   "Subtotal for all regions",
                   "Grand total§",
                   "conveyance‡ (Diamond",
                   "Princess)",
                   "Grand total§",
                   "")

        world <- world[!world[,c("country")] %in% empty, ]

        rbind(china, world)
      }
    )
  )
}

covid19_parse <- function(input = NULL) {
  if (is.null(input)) input <- covid19_index()[1,]

  pdf <- tempfile(fileext = ".pdf")
  download.file(input, pdf)

  entries <- tabulizer::extract_tables(pdf)
  rules <- covid19_rules()

  for (rule in rules) {
    if (rule$test(entries)) {
      complete <- cbind(gsub(".*situation-reports/|\\-.*", "", input), rule$parse(entries))
      colnames(complete)[1] <- "date"
      return(complete)
    }
  }

  return(
    data.frame(
      date = character(0),
      country = character(0),
      region = character(0),
      confirmed = character(0),
      deaths = character(0)
    )
  )
}
