### Global, monthly Land Surface Temperature (LST)
<p align="justify">
the iDivR package accomodates functions to derive global, day/night, monthly LST based on 8-day TERRA (<a href="https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod11a2_v006">MOD11A2</a>) and AQUA (<a href="https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/myd11a2_v006">MYD11A2</a>) data. The functions are supported by embarrassingly paralell processing and the data processing is tile oriented (Fig. 1). For each tile, the algorithm performs the following, general steps:
<ul>
  <li>Downloads TERRA and AQUA data from the <a href="https://ladsweb.modaps.eosdis.nasa.gov/">LAADS DAAC</a> server</li>
  <li>Combines TERRA and AQUA data on a daily basis</li>
  <li>Stacking and interpolaton of data gaps</li>
  <li>Stack reduction through the averaging of same-month layers</li>
</ul>
Finnally, a mosaic is build with the ouput the the tile-wise processing.

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/diagram_1.jpg" width="600"></p>
  <p align="center"><small>Figure 1 - Algorithm work flow</small></p>
</figure>

</br>

### Instalation
<p aligh="justify">
While the algorithm uses R, this language serves mainly as a wrapper. When perfoming RAM demanding tasks such as e.g. mosaicking, the algorithm calls GDAL. The algorithm is provided in the form of an R package and can be installed with devtools as shown below.
</p>

```r
devtools::install_github("RRemelgado/iDivR")
```

</br>

### Time requiremnts
<p align="justify">
I estimated that the processing time for each tile (per year) is as following:
<ul>
  <li><b>download and masking:</b> ~45 min.</li>
  <li><b>gap filling:</b> ~1h</li>
  <li><b>monthly mean composition:</b> 40 sec to 1 min.</li>
  <li><b>global compositing:</b> ~1h</li>.
</ul>
</p>

</br>

### Data storage: how is the data handled?
</p align="justify">
The functions avoid the storage of large amounts of data unless necessary. To achieve this, the most basic tasks (i.e. data download, masking, interpolation, compositing) are kept on a tile-by-tile basis and, once a step is completed, all temporaly files (e.g. hdf's) are deleted.
</p

</br>

### Error handling
</p align="align">
Often, NASA's servers contain corrupted files that will stop the processing chain when left unchecked. If the to downloaded file is labeled as corrupt, the algorithm will remove it and will skip the remaining tasks. However, if only one of the sensors (i.e. TERRA and AQUA) has corrupted files for a given date, the remaining one will still be processed. The file naming convenction will reflect this fact. When combining TERRA and AQUA, the output files will be named as "combined". Otherwise, they will be named according to the product of origin (i.e. "MOD11A2" or "MYD11A2").</p

</br>

### Gap filling
</p align="align">
iDivR provides functions that deals with data gaps using linear inteporlation (Fig. 2). For each x,y pixel coordinate, the algorithm extracts the corresponding time series and, for each observation, searchs for the closest, non-NA values in time. The search is constrained ot 60 days in the past and future avoiding the over-generalization of the time series.
</p

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/gapFill.jpg" width="600"></p>
  <p align="center"><small>Figure 2 - Example output of the gap-filled algorithm</small></p>
</figure>

</br>

### Selection of tiles to process
<p align="justify">
Looking at the <a href="https://ladsweb.modaps.eosdis.nasa.gov/">LAADS DAAC</a> server, we can already see that tiles with no overlapping land masses were already excluded. However, there are still tiles that overlap with very small land masses (i.e. area smaller than the product's pixel resolution). To avoid the time consuming download of these tiles, I first retrived a shapefile with the world's administrative boundaries (acquired <a href="https://biogeo.ucdavis.edu/data/gadm3.6/gadm36_shp.zip">here</a>) and, for each polygon, estimated the percent pixel coverage for a 1200 x 1200m grid (i.e. final product grid resolution) using the `poly2sample()` function of the <a href="">fieldRS</a> package. This function identifies all the pixels that are covered by a polygon and, for each pixel, quantifies the percent overlap. 
</p>

```r
require(fieldRS)

# read auxiliary data
cadm <- shapefile("country administrative boundaries")
tile <- shapefile("MODIS tile shapefile")

# filter polygons where no pixel is completely comtained
cadm.points <- poly2sample(s.tmp, 1200)
cadm <- intersect(cadm, cadm.points[cadm.points$cover == 100,])

# target tiles
tiles <- unique(cadm$tile)

```

<p align="justify">
Using this data, I filtered out all polygons where the minimum percent overlap was lesser than 100% (Fig. 3). Then, I downloaded a shapefile with the MODIS tiles (acquired <a href="http://book.ecosens.org/wp-content/uploads/2016/06/modis_grid.zip">here</a>) and queried the final set of tiles. Considering the build-up of a LST global, monthly composites for 1 year, <b><u>this step avoided the download of 1.4 Tb</u></b> of redundant data. These tiles (Fig. 4) overlap with small islands, mostly within the Pacific and Indian Oceans, where the use of satellite data with a higher resolution (e.g. Landsat) would be more appropriate.
</p>

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/admFilter.jpg" width="800"></p>
  <p align="center"><small>Figure 3 - Red circles highlight land masses that were excluded from further processing</small></p>
</figure>

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/modisTiles.jpg" width="800"></p>
  <p align="center"><small>Figure 4 - Comparison of taken MODIS tiles (in yellow) against the ones excluded (in red)</small></p>
</figure>

</br>

### Example Results
<p align="justify">
To demonstrate the applicability of the code, I derived the following data for the year of 2017 covering all continental Europe:
<ul>
  <li>8-day images (tile-wise)</li>
  <li>Monthly-mean composites (tile-wise)</li>
  <li>Monthly-mean composites (continental Europe)</li>
  <li>Monthly-mean of June extending the results for continental Europe to simulate a global dataset (Fig. 6)</li>
  <li>Gap-filled, monthly-mean composites for the Leipzing area</li>
</ul>
</p>

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/globalMosaic.jpg" width="800"></p>
  <p align="center"><small>Figure 6 - Global moaic with data available for Continental Europe.</small></p>
</figure>

</br>

### Potential improvements
<p align="justify">
I would improve my codes by generalizing the use of c++ for data processing. This would particularly useful when a High Performance Computer (HPC) is available allowing the data processing to be R independent (Fig. 5). Tasks such as gap filling (see c++ code <a href="">here</a>) can be done in such a way by first stacking the time-series of LST (as already done), exporting the values as a csv and transfering them to the HPC (Fig.7). When dealing with high resolution data (e.g. Landsat, Sentinel) this process can be preceeded by the splitting of the data into small, equal sized parts that can be processed in parallel in the HPC and them recombined into a single Raster object once the processing is completed.
<p>

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/diagram_2.jpg" width="600"></p>
  <p align="center"><small>Figure 7 - HPC compatible image processing</small></p>
</figure>

</br>
