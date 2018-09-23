#' @title pro.lst
#'
#' @description Interface to download and process tile-wise Land Surface Temperature (LST) data.
#' @param tile \emph{character} vector specifying the target MODIS tile (e.g. "h01v01")
#' @param date a vector of class \emph{Date} containing the target download dates.
#' @param data.path Output data path for downloaded data.
#' @importFrom raster calc stack
#' @importFrom lubridate is.Date
#' @importFrom stats complete.cases
#' @return One or multiple raster objects.
#' @details {Downloads and pre-processes 
#' \link[https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod11a2_v006]{MOD11A2} and 
#' \link[https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/myd11a2_v006]{MYD11A2} data 
#' download for a given \emph{tile}. The function downloads the hdf file closest in time to \emph{date} 
#' data is downloaded from the \link[https://ladsweb.modaps.eosdis.nasa.gov/]{LAADS DAAC server}. Then, it 
#' extract day and night LST masked with Quanlity Control (QC) data and, when, TERRA and AQUA images are 
#' available, merges both in a single file for each variable (i.e. "day" and "night"). The output files are 
#' named as "Date" + "tile" + "product"/"combined" + "variable" + ".tif".}
#' @export

#-------------------------------------------------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------------------------------#

# land surface temperature
pro.lst <- function(tile, date, data.path) {
  
#-------------------------------------------------------------------------------------------------------------------------------#
# 1. Check input variables
#-------------------------------------------------------------------------------------------------------------------------------#
    
  if (!is.character(tile)) {stop('"tile" is not of a valid format')}
  if (!is.Date(date)) {stop('"dates" should be a date object')}
  if (!dir.exists(data.path)) {stop('"data.path" is not a valid path')}
  
#-------------------------------------------------------------------------------------------------------------------------------#
# 3. download and combine MODIS TERRA/AQUA
#-------------------------------------------------------------------------------------------------------------------------------#
  
  downloaded.files <- rbind(download.lst(tile, date, product="MOD11A2"), download.lst(tile, date, product="MYD11A2"))
  i <- which(!is.na(downloaded.files$file)) # which files are available?
  if (length(i) > 0) {
    
    downloaded.files <- downloaded.files[i,]
    
    ofiles <- paste0(data.path, downloaded.files$date, "_", tile, "_", downloaded.files$product)
    
    ofiles <- extract.lst(downloaded.files$file, ofiles, delete.original=TRUE)
    
    cc <- sum(complete.cases(ofiles)) # check if data was processed
    
    # combine files (if available for TERRA and AQUA)
    if (cc == 2) {
      
      ofile1 <- paste0(data.path, as.character(date), "_", tile, "_combined_lst-day.tif")
      calc(stack(ofiles$day), mean, na.rm=TRUE, filename=ofile1, datatype="INT2U", overwrite=TRUE)
      
      ofile2 <- paste0(data.path, as.character(date), "_", tile, "_combined_lst-night.tif")
      calc(stack(ofiles$night), mean, na.rm=TRUE, filename=ofile2, datatype="INT2U", overwrite=TRUE)
    
      file.remove(c(ofiles$day, ofiles$night))
      ofiles <- c(ofile1, ofile2)
      
    }
    
    if (cc == 0) {ofiles <- c(NA,NA)}
    
    
  } else {ofiles <- c(NA, NA)}
  
  return(data.frame(date=date, file.day=ofiles[1], file.night=ofiles[2], stringsAsFactors=FALSE))
  
}
