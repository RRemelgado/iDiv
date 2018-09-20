











extractLST <- function(ifile, ofile, delete.original=TRUE) {
  
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
  
  ofiles <- vector("character", length(ifile)) # files to be written
  
  for (f in 1:length(ifile)) {
    
    # process day LST
    tmp1 <- tempfile(pattern="tmp1", tmpdir=tempdir(), fileext=".tif")
    gdal_translate(ifile[f], tmp1, sd_index=1, ot="UInt32")
    r1 <- raster(tmp1)
    tmp2 <- tempfile(pattern="tmp2", tmpdir=tempdir(), fileext=".tif")
    gdal_translate(ifile[f], tmp2, sd_index=2, ot="UInt32")
    qc <- raster(tmp2)
    qc <- ((qc %% b[1])>=a[1])^2 + ((qc %% b[2])>=a[2])^2
    r1[qc>0] <- NA
    of <- paste0(ofile[f], '_day-lst.tif')
    writeRaster(r1, of, dataType="UInt32", overwrite=TRUE) # day lst (1)
    
    ofiles[length(ofiles)+1] <- of
    
    rm(qc)
    file.remove(tmp1)
    file.remove(tmp2)
    
    # process night LST
    tmp1 <- tempfile(pattern="tmp1", tmpdir=tempdir(), fileext=".tif", ot="UInt32")
    gdal_translate(ifile[f], tmp1, sd_index=5)
    r1 <- raster(tmp1)
    tmp2 <- tempfile(pattern="tmp2", tmpdir=tempdir(), fileext=".tif", ot"UInt32")
    gdal_translate(ifile[f], tmp2, sd_index=6)
    qc <- raster(tmp2)
    qc <- ((qc %% b[1])>=a[1])^2 + ((qc %% b[2])>=a[2])^2
    r1[qc>0] <- NA
    of <- paste0(ofile[f], '_night-lst.tif')
    writeRaster(r1, of, dataType="UInt32", overwrite=TRUE) # day lst (1)
    
    ofiles[length(ofiles)+1] <- of
    
    rm(qc)
    file.remove(tmp1)
    file.remove(tmp2)
    
    if (delete.original(file.remove(ofile))
    
  }
  
  return(ofiles) # report on written files
  
}