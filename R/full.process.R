#' @title fullProcess
#'
#' @description Full processing of LST including data download, masking, monthly averaging and compositing
#' @param tiles \emph{character} vector specifying the target MODIS tile (e.g. "h01v01")
#' @param dates a vector of class \emph{Date} containing the target download dates.
#' @param data.path Output data path for downloaded data.
#' @importFrom RCurl getURL url.exists
#' @importFrom lubridate is.Date
#' @importFrom raster stack calc getValues setValues
#' @return A \emph{character} vector and hdf files.
#' @export

#------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------#

full.process <- function(tile, dates, data.path1, data.path2) {
  
  tile.dir <- paste0(data.path1, "/", tile, "/")
  if (!dir.exists(tile.dir)) {dir.create(tile.dir)}
  odf <- do.call(rbind, lapply(dates$date, function(d) {return(pro.lst(t, d, tile.dir))}))
    
  # fill data gaps and generate monthly composites (day)
  stk <- stack(odf$file.day)
  rv <- getValues(stk)
  i <- which(dates$year == year)
  rv <- intTime(rv, as.numeric(dates$date[i]), month(dates$date[i]))
  stk <- stk[[1:12]]
  stk <- setValues(stk, rv)
  ofile <-paste0(data.path2, year, "_", t, "_day-lst.tif")
  writeRaster(stk, ofile, datatype=dataType(stk), options="COMPRESS=LZW", overwrite=TRUE)
  rm(stk)
  
  # fill data gaps and generate monthly composites night)
  stk <- stack(odf$file.night)
  rv <- getValues(stk)
  i <- which(dates$year == year)
  rv <- intTime(rv, as.numeric(dates$date[i]), month(dates$date[i]))
  stk <- stk[[1:12]]
  stk <- setValues(stk, rv)
  ofile <-paste0(data.path2, year, "_", t, "_night-lst.tif")
  writeRaster(stk, ofile, datatype=dataType(stk), options="COMPRESS=LZW", overwrite=TRUE)
  rm(stk)
 
}