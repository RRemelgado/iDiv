#' @title updateDates
#'
#' @description Finds closest, possible dates to download LST data for.
#' @param dates a vector of class \emph{Date} containing the target download dates.
#' @importFrom lubridate is.Date
#' @return a \emph{data.frame}.
#' @details {Finds closest, possible dates to download 8-day LST data based on a set of reference dates. Additionally, 
#' the function reports on the year Day of Acquisition (DoA).
#' @export

#-------------------------------------------------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------------------------------#

updateDates <- function(dates) {
  
#-------------------------------------------------------------------------------------------------------------------------------#
# 1. check input variables
#-------------------------------------------------------------------------------------------------------------------------------#
  
  if (!is.Date(dates)) {stop('"dates" is not of class Date')}
  
#-------------------------------------------------------------------------------------------------------------------------------#
# 2. update target dates
#-------------------------------------------------------------------------------------------------------------------------------#
  
  ud <- unique(dates) # unique dates
  yrs <- year(ud)
  doa <- (ud-as.Date(paste0(as.character(yrs), '-01-01')))+1

  # find nearest dates to downloaded
  potential.doa <- seq(1, 365, 8)
  tmp <- lapply(1:length(doa), function(i) {
    diff <- abs(doa[i] - potential.doa)
    pd <- potential.doa[which(diff==min(diff))]
    py <- replicate(length(pd), yrs[i])
    dt <- as.Date(paste0(yrs[i], '-01-01')) + (as.numeric(pd)-1)
    return(list(doa=pd, year=py, date=dt))})
  
  # update temporal information
  ud <- do.call('c', lapply(tmp, function(x) {x$date}))
  ind <- !duplicated(ud)
  ud <- ud[ind]
  doa <- unlist(sapply(tmp, function(x) {x$doa}))[ind]
  yrs <- unlist(sapply(tmp, function(x) {x$year}))[ind]
  
  return(data.frame(date=ud, doa=doa, year=yrs, stringsAsFactors=FALSE))

}
