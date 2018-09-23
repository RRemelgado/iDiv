#' @title multiCore.lst
#'
#' @description Multi-core implementation of the \code{\link{pro.lst}} function.
#' @param tiles \emph{character} vector specifying the target MODIS tiles (e.g. "h01v01")
#' @param dates a vector of class \emph{Date} containing the target download dates.
#' @param year Numeric element specifying the target year (additional dates are only used for interpalation)
#' @param data.path1 Output data path for downloaded data.where tile-wise data will be stored.
#' @param data.path2 Output data path for downloaded data.where Mosaics will be stored.
#' @importFrom lubridate is.Date
#' @importFrom parallel detectCores
#' @importFrom doParallel registerDoParallel
#' @importFrom foreach foreach
#' @return One \emph{RasterStack} object for each element in \emph{tiles}.
#' @export

#------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------#

multiCore.lst <- function(tiles, dates, year, data.path1, data.path2) {

#-------------------------------------------------------------------------------------------------------------------------------#
# 1. Check input variables
#-------------------------------------------------------------------------------------------------------------------------------#
  
  if (!is.character(tiles)) {stop('"tile" is not of a valid format')}
  if (!is.Date(dates)) {stop('"dates" should be a date object')}
  if (!dir.exists(data.path1)) {stop('"data.path1" is not a valid path')}
  if (!dir.exists(data.path2)) {stop('"data.path2" is not a valid path')}
  
#-------------------------------------------------------------------------------------------------------------------------------#
# 2. perform parallel processing
#-------------------------------------------------------------------------------------------------------------------------------#
  
  # register cores for parallel processing
  registerDoParallel(cores=detectCores(all.tests=FALSE, logical=TRUE))
  
  foreach(t=1:length(tiles)) %dopar% try(
    full.process(tiles[t], dates, data.path1, data.path2)
  )

}