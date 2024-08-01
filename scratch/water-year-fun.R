water_year <- function(date) {
  year <- year(date)
  month <- month(date)
  ifelse(month >= 10, year + 1, year)
}
