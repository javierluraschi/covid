#' @export
covid19_index <- function() {
  base_path <- "https://www.who.int/emergencies/diseases/novel-coronavirus-2019/situation-reports"

  index <- xml2::read_html(base_path)
  body <- rvest::html_nodes(index, 'body')

  pdfs <- xml2::xml_find_all(body, "//a[contains(@href,'.pdf')]")

  links <- paste0("https://www.who.int", rvest::html_attr(pdfs, "href"))

  data.frame(link = links, stringsAsFactors = FALSE)
}
