#' @title month.mean.lst
#'
#' @description Derives monthly-mean LST based on a \emph{RasterStack}.
#' @param x A \emph{RasterStack}.
#' @param y an Object of class \emph{date} with the same length as \emph{x}.
#' @importFrom lubridate is.Date month
#' @importFrom raster stack calc nlayers
#' @details Builds a \emph{RasterStack} of monthly-mean lST based on e.g. 8-day images.
#' @return A \emph{RasterStack}.
#' @export

#------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------#

monthly.mean.lst <- function(x, y) {
  
#------------------------------------------------------------------------------------------------------------------------------------------------#
# 1. check input variables
#------------------------------------------------------------------------------------------------------------------------------------------------#
  
  # check is list of files can be read
  if (!is.Date(y)) {stop('"y" is not a Date object')}
  if (length(y) != nlayers(x)) {stop('"x" and "y" have different lenghts')}
  y.months <- month(y)
  unique.months <- unique(y.months)
  
#------------------------------------------------------------------------------------------------------------------------------------------------#
# 2.derive monthly means
#------------------------------------------------------------------------------------------------------------------------------------------------#
  
  or <- stack(lapply(unique.months, function(m) {
    
    i <- which(y.months == m)
    return(calc(x[[i]], mean, na.rm=TRUE))
    
  }))
  
  return(or)
}
