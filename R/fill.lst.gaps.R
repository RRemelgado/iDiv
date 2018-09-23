#' @title fill.lst.gaps
#'
#' @description Fill temporal gaps in LST \emph{RasterLayer} objects.
#' @param x \emph{character} vector with the paths of \emph{RasterLayers}.
#' @param y an Object of class \emph{Date} with the same length as \emph{x}.
#' @param target.year Numeric element specifying the target year (additional dates are only used for interpalation)
#' @param ofile Path to output file.
#' @importFrom RCurl getURL url.exists
#' @importFrom lubridate is.Date year
#' @importFrom stats lm
#' @importFrom raster stack calc getValues setValues dataType
#' @details The function uses an algorithm similar to the one offered 
#' by \code{\link[rsMove]{imgInt}}. In essense, the function evaluates 
#' the time series of each pixel and, for each date with a NA value, it 
#' searches for the closest, non-NA values in time - contrained by a 
#' temporal buffer - and uses them to fill data gaps linearly.
#' @return A \emph{character} vector and hdf files.
#' @export

#------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------#

fill.lst.gaps <- function(x, y, target.year, ofile) {
  
   # check is list of files can be read
   stk <- tryCatch(stack(x), error=function(e) return(NULL))
   
   if (!is.null(stk)) {
     
     intime <- function(x) {
       
       tmp <- sapply(y, function(d) {
         
         di <- which(y==d & !is.na(x))
         
         if (length(di) > 0) {return(mean(x[di]))} else {
           
           bi <- rev(which(!is.na(x) & y < d & y >= (d-60)))
           ai <- which(!is.na(x) & y > d & y <= (d+60))
           
           if (length(bi)>=1 & length(ai)>=1) {
             lc <- lm(c(x[bi[1]],x[ai[1]])~as.numeric(c(y[bi[1]],y[ai[1]])))
             return(as.numeric(d)*lc$coefficients[2]+lc$coefficients[1])
           } else {return(NA)}
           
           
           return(tmp)
           
         }})}
     
     rv <- getValues(stk)
     i <- which(year(y) == year)
     rv <- t(apply(rv, 1, intime))
     stk <- setValues(stk, rv)
     writeRaster(stk, ofile, datatype=dataType(stk), options="COMPRESS=LZW", overwrite=TRUE)
     rm(stk)
     
   } else {warning('"x" could not be read as a RasterStack')}

}
