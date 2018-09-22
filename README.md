### Global, monthly Land Surface Temperature (LST)
<p align="justify">
This exercise aims to derive global, day/night, monthly LST based on 8-day TERRA (<a href="https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod11a2_v006">MOD11A2</a>) and AQUA (<a href="https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/myd11a2_v006">MYD11A2</a>) data. My algorithm (Fig. 1) focuses on tile-wise processing. For each target tile, the algorithm performs the following, general steps:
<item>Downloads TERRA and AQUA data from the <a href="https://ladsweb.modaps.eosdis.nasa.gov/">LAADS DAAC</a> server</item>
<item>Combines TERRA and AQUA data on a daily basis</item>
<item>Interpolates data gaps and derives mean LST</item>
Finnally, a global mosaic is build for each month using all tiles. As an example, I derived monthly mean composites for the year of 2017 for continental Europe. This data can be accessed <a href="">here</a>.
</p>

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/diagram_1.jpg" width="600"></p>
  <p align="center"><small>Figure 1 - Algorithm work flow</small></p>
</figure>

</br>

### Programming language
<p aligh="justify">
While my algorithm uses R, this language serves mainly as a wrapper. When perfoming RAM demanding tasks such as e.g. mosaicking, the algorithm calls GDAL. The algorithm can be installed using devtools as shown below.
</p>

```r
devtools::install_github("RRemelgado/iDivR")
```

</br>

### Parallel processing and time requiremnts
<p align="justify">
The algorithm takes advantage of multi-core processing dividing the total number of tiles equaly among the different cores. I estimated that the processing time for each tile (per year) is as following:
<item><b>download and masking:</b> ~45 min.</item>
<item><b>gap filling:</b> ~1h</item>
<item><b>monthly mean composition:</b> 40 sec to 1 min.</item>
<item><b>global compositing:</b> ~1h</item>.
<p aligh="justify">

</br>

### Data storage: how is the data handled?
</p align="align">
My programming solution avoids the storage of large amounts of data unless necessary. To achieve this, the algorithm keeps the most basic tasks (i.e. data download, masking, interpolation, compositing) on a tile-by-tile basis. For each tile, once the pre-procesisng is completed, all temporaly files (e.g. hdf's) are deleted. Moreover, only one image is kept for each 8-day composite resulting from the mean of the TERRA and AQUA products thus halving the required data storage.
</p

</br>

### Error handling
</p align="align">
Often, NASA's servers contain corrupted files that, while downloadable, can't be read. When left unchecked, this will stop the processing chain. To avoid this, the algorithm considers the download warnings. If the the file to download if labeled as corrupt, the algorithm will remove it and will report the lack of an output file. For example, if for a given data we are able ot download data for TERRA but not for AQUA, the algorithm will skip the step involving the combination of TERRA and AQUA.
</p

</br>

### Gap filling
</p align="align">
The algorithm addresses data gaps using linear inteporlation. For each x,y pixel coordinate, the algorithm extracts the corresponding time series and, for each observation, searchs for the closest, non-NA values in time. The search is constrained ot 60 days in the past and future avoiding the over-generalization of the time series.
</p

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
Using this data, I filtered out all polygons where the minimum percent overlap was lesser than 100% (Fig. 2). Then, I downloaded a shapefile with the MODIS tiles (acquired <a href="http://book.ecosens.org/wp-content/uploads/2016/06/modis_grid.zip">here</a>) and queried the final set of tiles. Considering the build-up of a LST global, monthly composites for 1 year, <b><u>this step avoided the download of 1.4 Tb</u></b> of redundant data. These tiles overlap with small islands, mostly within the Pacific and Indian Oceans, where the use of satellite data with a higher resolution (e.g. Landsat) would be more appropriate.
</p>

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/admFilter.jpeg" width="800"></p>
  <p align="center"><small>Figure 2 - Red circles highlight land masses that were excluded from further processing</small></p>
</figure>

<figure>
  <p align="center"><img src="https://github.com/RRemelgado/iDivR/blob/master/inst/extdata/modisTiles.jpg" width="800"></p>
  <p align="center"><small>Figure 3 - Comparison of taken MODIS tiles (in yellow) against the ones excluded (in red)</small></p>
</figure>

</br>


</br>

### Potential improvements
<p alion="justify">
While I didn't have the chance to do, I considered improving the proposed algorithm using the `reticulate` package. This R package allows the inclusion of Python in basic pre-procesing steps and could be used whenever dealing with more RAM demanding tasks and datasets. As of the time being, I have successfully integrated `reticulate` in `iDivR` and can easily call e.g. GDAL through it.
</p
<p align="justify">
Another way I would improve my codes is to generalize the use of c++ for data processing. This would particularly useful when a High Performance Computer (HPC) is available allowing the data processing to be R independent. Tasks such as gap filling (see c++ code <a href="">here</a>) can be done in such a way by first stacking the time-series of LST (as already done), exporting the values as a csv and transfering them to the HPC (Fig. 4). When dealing with high resolution data (e.g. Landsat, Sentinel) this process can be preceeded by the splitting of the data into small, equal sized parts that can be processed in parallel in the HPC and them recombined into a single Raster object once the processing is completed.

<p>
