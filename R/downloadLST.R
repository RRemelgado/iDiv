#' @title downloadLST
#'
#' @description Interface to download and process Land Surface Temperature (LST) data.
#' @param tiles \emph{character} vector specifying the target MODIS tile (e.g. "h01v01")
#' @param dates a vector of class \emph{Date} containing the target download dates.
#' @param data.path Output data path for downloaded data.
#' @import grDevices sp rgdal ncdf4
#' @importFrom XML htmlParse readHTMLTable xmlRoot
#' @importFrom httr GET write_disk authenticate
#' @importFrom RCurl getURL url.exists
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

#------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------#

downloadLST <- function(tile, date, product="") {
  
#------------------------------------------------------------------------------------------------------------------------------------------------#
# 1. check input variables
#------------------------------------------------------------------------------------------------------------------------------------------------#
  
  # check tile
  if (length(tile) > 1) {stop('"tile" has more than 1 element')}
  if (substr(tile, 1, 1)!="h" & substr(tile, 4, 4)!="v") {stop('"tile" is misspeled')}
  data(tile.names) # load tile names
  if (!tile %in% tile.names) {stop('"tile" does not exist (maybe a misspeling?)')}
  
  # check and formt temporal information
  if (!is.Date(date)) {stop('"date" is not a valid object')}
  ayr <- as.character(year(date))
  doa <- sprintf("%03d", as.numeric(date-as.Date("2012-01-01")+1))
  aqd <- as.character(date)
  
  # check product
  if (length(product) > 1) {stop('"product" only allows 1 element')}
  if (!product %in% c("MYD11A2", "MOD11A2")) {stop('"product" is not recognized')}
  
#------------------------------------------------------------------------------------------------------------------------------------------------#
# 2. download/process data (TERRA)
#------------------------------------------------------------------------------------------------------------------------------------------------#
  
  server <- paste0("https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/", product, '/', ayr, '/', doa, '/') #  where is the file?
  
  # does the server exist? if so, check for file and, if that exists, initiate download
  if (url.exists(server)) {
      
    tbl <- as.character(readHTMLTable(xmlRoot(htmlParse(GET(url=server))), skip.rows=1)$V1) # list hdf's
    ifile <- paste0(server, tbl[grep(tile, tbl)]) # target file
    
    if (url.exists(ifile)) {
      
      ofile <- tempfile(pattern=basename(ifile), tmpdir=tempdir(), fileext=".hdf") # output
      GET(ifile, write_disk(ofile, overwrite=TRUE)) # download file
      
    } else{ofile <- NA}
  } else{ofile <- NA}
  
#------------------------------------------------------------------------------------------------------------------------------------------------#
# 3. return information on product date and path to downloaded file
#------------------------------------------------------------------------------------------------------------------------------------------------#
  
  return(data.frame(date=aqd, file=ofile, product=product))
  
}
  