#' @title extract.lst
#'
#' @description Interface to download and process tile-wise Land Surface Temperature (LST) data.
#' @param ifile Path to hdf file.
#' @param ofile Base filename of the output. The name will be \emph{ofile} + '_day-lst.tif' and \emph{ofile} + '_night-lst.tif'
#' @param delete.original Logical argument specifying if the hdf should be deleted when processed.
#' @importFrom gdalUtils gdal_translate
#' @importFrom raster raster writeRaster
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
#-------------------------------------------------------------------------------------------------------------------------------#

extract.lst <- function(ifile, ofile, delete.original=TRUE) {
  
#------------------------------------------------------------------------------------------------------------------------------------------------#
# 1. check input variables
#------------------------------------------------------------------------------------------------------------------------------------------------#
  
  if (!is.character(ifile)) {stop('"ifile" is not a character vector')}
  if (!is.character(ofile)) {stop('"ifile" is not a character vector')}
  if (length(ifile) != length(ofile)) {stop('"ifile" and "ofile" have different lenghts')}
  if (sum(file.exists(ifile)) != length(ifile)) {stop('one or more elements in "ifile" do not exist')}
  if (sum(dir.exists(dirname(ofile))) != length(ofile)) {stop('one or more elements in "ofile" do not exist')}
  if (!is.logical(delete.original)) {stop('"delete.original" is not a logical argument')}
  
  # variables used for QC interpretation (extracts only the higuest quality pixels)
  a<-2^(0:15)
  b<-2*a
  
#------------------------------------------------------------------------------------------------------------------------------------------------#
# 2. extract lst data (day and night)
#------------------------------------------------------------------------------------------------------------------------------------------------#
  
  ofiles1 <- vector("character", length(ifile)) # files to be written (day)
  ofiles2 <- vector("character", length(ifile)) # files to be written (night)
  
  for (f in 1:length(ifile)) {
    
    # process day LST
    tmp1 <- tempfile(pattern=paste0(basename(ifile[f]), "_1"), tmpdir=tempdir(), fileext=".tif")
    
    gt <- tryCatch(gdal_translate(ifile[f], tmp1, sd_index=1), error = function(e) return(FALSE))
    
    if (!isFALSE(gt)) {
      
      r1 <- raster(tmp1)
      tmp2 <- tempfile(pattern=paste0(basename(ifile[f]), "_2"), tmpdir=tempdir(), fileext=".tif")
      gdal_translate(ifile[f], tmp2, sd_index=2, ot="UInt32")
      qc <- raster(tmp2)
      qc <- ((qc %% b[1])>=a[1])^2 + ((qc %% b[2])>=a[2])^2
      r1[qc>0] <- NA
      ofiles1[f] <- paste0(ofile[f], '_day-lst.tif')
      writeRaster(r1, ofiles1[f], dataType="UInt32", overwrite=TRUE) # day lst (1)
      
      rm(qc, r1)
      file.remove(tmp1)
      file.remove(tmp2)
      
      # process night LST
      tmp1 <- tempfile(pattern=paste0(basename(ifile[f]), "_1"), tmpdir=tempdir(), fileext=".tif")
      gdal_translate(ifile[f], tmp1, sd_index=5, ot="UInt32")
      r1 <- raster(tmp1)
      tmp2 <- tempfile(pattern=paste0(basename(ifile[f]), "_2"), tmpdir=tempdir(), fileext=".tif")
      gdal_translate(ifile[f], tmp2, sd_index=6, ot="UInt32")
      qc <- raster(tmp2)
      qc <- ((qc %% b[1])>=a[1])^2 + ((qc %% b[2])>=a[2])^2
      r1[qc>0] <- NA
      ofiles2[f] <- paste0(ofile[f], '_night-lst.tif')
      writeRaster(r1, ofiles2[f], dataType="UInt32", overwrite=TRUE) # day lst (1)
      
      rm(qc, r1)
      file.remove(tmp1)
      file.remove(tmp2)
      
    } else {
      
      ofiles1[f] <- NA
      ofiles2[f] <- NA
    
    }
    
    if (delete.original) {file.remove(ifile[f])}
    
  }
  
  return(data.frame(day=ofiles1, night=ofiles2, stringsAsFactors=FALSE)) # report on written files
  
}
