#' @title full.process
#'
#' @description Full processing of LST including data download, masking, monthly averaging and compositing
#' @param tile \emph{character} vector specifying the target MODIS tile (e.g. "h01v01")
#' @param dates a vector of class \emph{Date} containing the target download dates.
#' @param data.path1 Output data path for downloaded data.where tile-wise data will be stored.
#' @param data.path2 Output data path for downloaded data.where Mosaics will be stored.
#' @importFrom RCurl getURL url.exists
#' @importFrom lubridate is.Date year
#' @importFrom raster stack calc getValues setValues
#' @return A \emph{character} vector and hdf files.
#' @export

#------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------#

full.process <- function(tile, dates, data.path1, data.path2) {
  
  tile.dir <- paste0(data.path1, "/", tile, "/")
  if (!dir.exists(tile.dir)) {dir.create(tile.dir)}
  odf <- do.call(rbind, lapply(dates, function(d) {return(pro.lst(tile, d, tile.dir))}))
  
  yr <- year(dates)
  uyr <- unique(yr)
  
  for (y in 1:length(uyr)) {
    
    i <- which(yr == uyr[y]) # identify files for year y
    
    # generate monthly composites day)
    stk <- stack(odf$file.day)
    mmc <- monthly.mean.lst(stk, dates[i])
    ofile <-paste0(data.path2, uyr[y], "_", tile, "_lst-day.tif")
    writeRaster(stk, ofile, datatype="INT2U", options=c("COMPRESS=DEFLATE", "PREDICTOR=2", "ZLEVEL=6"), overwrite=TRUE)
    
    rm(stk, mmc)
    
    # generate monthly composites (night)
    stk <- stack(odf$file.night)
    mmc <- monthly.mean.lst(stk, dates[i])
    ofile <-paste0(data.path2, year, "_", tile, "_lst-night.tif")
    writeRaster(stk, ofile, datatype="INT2U", options=c("COMPRESS=DEFLATE", "PREDICTOR=2", "ZLEVEL=6"), overwrite=TRUE)
    
    rm(stk, mmc, i)
    
  }
 
}
