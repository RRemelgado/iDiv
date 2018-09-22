#' @title fullProcess
#'
#' @description Full processing of LST including data download, masking, monthly averaging and compositing
#' @param tiles \emph{character} vector specifying the target MODIS tile (e.g. "h01v01")
#' @param dates a vector of class \emph{Date} containing the target download dates.
#' @param data.path1 Output data path for downloaded data.where tile-wise data will be stored.
#' @param data.path2 Output data path for downloaded data.where Mosaics will be stored.
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
  i <- which(dates$year == year)
  mmc <- monthly.mean.lst(r.stk, dates[i])
  ofile <-paste0(data.path2, year, "_", t, "lst-day.tif")
  writeRaster(stk, ofile, datatype="INT2U", options=c("COMPRESS=DEFLATE"), overwrite=TRUE)
  
  rm(stk, mmc, i)
  
  # fill data gaps and generate monthly composites night)
  stk <- stack(odf$file.night)
  i <- which(dates$year == year)
  mmc <- monthly.mean.lst(r.stk, dates[i])
  ofile <-paste0(data.path2, year, "_", t, "_lst-night.tif")
  writeRaster(stk, ofile, datatype="INT2U", options=c("COMPRESS=DEFLATE"), overwrite=TRUE)
  
  rm(stk, mmc, i)
 
}