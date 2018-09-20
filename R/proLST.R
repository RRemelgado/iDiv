#' @title proLST
#'
#' @description Interface to download and process Land Surface Temperature (LST) data.
#' @param tiles \emph{character} vector specifying the target MODIS tile (e.g. "h01v01")
#' @param dates a vector of class \emph{Date} containing the target download dates.
#' @param data.path Output data path for downloaded data.
#' @import grDevices sp rgdal ncdf4
#' @importFrom XML htmlParse readHTMLTable xmlRoot
#' @importFrom httr GET write_disk authenticate
#' @importFrom RCurl getURL
#' @importFrom gdalUtils gdal_translate
#' @importFrom lubridate is.Date
#' @return One or multiple raster objects.
#' @details {Downloads and pre-processes 
#' \link[https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod11a2_v006]{MOD11A2} and 
#' \link[https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/myd11a2_v006]{MYD11A2} data 
#' for user specified \emph{tiles}. The data is downloaded from the 
#' \link[https://ladsweb.modaps.eosdis.nasa.gov/]{LAADS DAAC server}. for each tile, the function downloads 
#' the hdf files for closest in time to the elements in \emph{dates} and, for each hdf file, extract day and night 
#' LST, applies quality information to each band and stores them as separate files names as "Date" + "tile" + 
#' "collection" + "variable" + ".tif".}
#' @export

#-------------------------------------------------------------------------------------------------------------------------------#

# land surface temperature
proLST <- function(tile, dates, data.path) {
  
#-------------------------------------------------------------------------------------------------------------------------------#
# 1. Check input variables
#-------------------------------------------------------------------------------------------------------------------------------#
    
  if (!is.character(tile)) {stop('"tile" is not of a valid format')}
  if (!is.Date(dates)) {stop('"dates" should be a date object')}
  if (!dir.exists(data.path)) {stop('"data.path" is not a valid path')}
  
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
  
#-------------------------------------------------------------------------------------------------------------------------------#
# 3. download and combine MODIS TERRA/AQUA
#-------------------------------------------------------------------------------------------------------------------------------#
  
  for (d in 1:length(ud)) {
    
    downloaded.files <- rbind(downloadLST(tile, ud[d], product="MOD11A2"), downloadLST(tile, ud[d], product="MYD11A2"))
    i <- which(!is.null(downloaded.files$file)) # which files are available?
    if (length(i) > 0) {
      
      downloaded.files <- downloaded.files[i,]
      
      ofiles <- paste0(data.path, as.character(ud[d]), "_", tile, "_", product)
      
      ofiles <- extractLST(downloaded.files$file, ofile, delete.original=TRUE)
      
      # combine files (if available for TERRA and AQUA)
      if (length(i) > 1) {
        
        ofile <- paste0(data.path, as.character(ud[d]), "_", tile, "_combined_lst-day.tif")
        agg <- calc(stack(ofiles[1:3]), mean, na.rm=TRUE, filename=of, datatype="INT2U", overwrite=TRUE)
        
        rm(agg)
        file.remove(ifile)
        
        ofile <- paste0(data.path, as.character(ud[d]), "_", tile, "_combined_lst-night.tif")
        agg <- calc(stack(ofiles[2:4]), mean, na.rm=TRUE, filename=of, datatype="INT2U", overwrite=TRUE)
        
        rm(agg)
        file.remove(ifile)
        
      }
      
      
    }
    
  }
  
}