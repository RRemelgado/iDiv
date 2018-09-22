#' @title fill.lst.gaps
#'
#' @description Fill temporal gaps in LST \emph{RasterLayer} objects.
#' @param x \emph{character} vector with the paths of \emph{RasterLayers}.
#' @param y an Object of class \emph{date} with the same length as \emph{x}.
#' @importFrom RCurl getURL url.exists
#' @importFrom lubridate is.Date
#' @importFrom raster stack calc getValues setValues
#' @details The function uses an algorithm similar to the one offered 
#' by \code{\link[rsMove]{imgInt}}. In essense, the function evaluates 
#' the time series of each pixel and, for each date with a NA value, it 
#' searches for the closest, non-NA values in time - contrained by a 
#' temporal buffer - and uses them to fill data gaps linearly.
#' @return A \emph{character} vector and hdf files.
#' @export

#------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------#

fill.lst.gaps <- function(x) {
  
   # check is list of files can be read
   stk <- tryCatch(stack(odf$file.day), error=function(e) return(NULL))
   
   if (!is.null(stk)) {
     
     rv <- getValues(stk)
     i <- which(dates$year == year)
     rv <- intTime(rv, as.numeric(dates$date[i]), month(dates$date[i]))
     stk <- stk[[1:12]]
     stk <- setValues(stk, rv)
     ofile <-paste0(data.path2, year, "_", t, "_day-lst.tif")
     writeRaster(stk, ofile, datatype=dataType(stk), options="COMPRESS=LZW", overwrite=TRUE)
     rm(stk)
     
   } else {warning('"x" could not be read as a RasterStack')}

}
