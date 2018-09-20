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
#' @importFrom lubridate is.Date
#' @return A \emph{character} vector and hdf files.
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
  tbl <- as.character(readHTMLTable(xmlRoot(htmlParse(GET(url=server))), skip.rows=1)$V1) # list hdf's
  tbl <- tbl[grep(tile, tbl)]
  
  if (length(tbl) > 0) {
    ifile <- paste0(server, tbl) # target file
    ofile <- tempfile(pattern=basename(ifile), tmpdir=tempdir(), fileext=".hdf") # output
    dft <- tryCatch(GET(ifile, write_disk(ofile, overwrite=TRUE)), error=function(e) return(FALSE)) # download file
    if (isFALSE(dft)) {ofile <- NA}
  } else {ofile <- NA}
  
#------------------------------------------------------------------------------------------------------------------------------------------------#
# 3. return information on product date and path to downloaded file
#------------------------------------------------------------------------------------------------------------------------------------------------#
  
  return(data.frame(date=aqd, file=ofile, product=product, stringsAsFactors=FALSE))
  
}
  