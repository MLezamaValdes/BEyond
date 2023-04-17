# Preparing basis data further 
# (if something's missing it can be found in notebook.Rmd )


library(here)
library(sf)
library(terra)
library(raster)

dp <- "../data/"
sap <- here(dp, "/studyarea")

utmproj <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs"


# reprojecting grassland tifs (was ETRS89 EPSG:3035) to UTM
gr_ALB <- rast(here(sap, "grassland_ALB.tif"))
gr_SEG <- rast(here(sap, "grassland_SEG.tif"))
gr_HAI <- rast(here(sap, "grassland_HAI.tif"))

gr_ALB <- project(gr_ALB, utmproj)
gr_HAI <- project(gr_HAI, utmproj)
gr_SEG <- project(gr_SEG, utmproj)

# make them categorical too
gr_ALB_r <- as(gr_ALB, "Raster")
gr_HAI_r <- as(gr_HAI, "Raster")
gr_SEG_r <- as(gr_SEG, "Raster")

# reclassification due to reprojection 
gr_ALB_r[gr_ALB_r < 0.5] <- 0
gr_ALB_r[gr_ALB_r > 0.5] <- 1

gr_HAI_r[gr_HAI_r < 0.5] <- 0
gr_HAI_r[gr_HAI_r > 0.5] <- 1

gr_SEG_r[gr_SEG_r < 0.5] <- 0
gr_SEG_r[gr_SEG_r > 0.5] <- 1

gr_ALB_r <- as.factor(gr_ALB_r)
gr_HAI_r <- as.factor(gr_HAI_r)
gr_SEG_r <- as.factor(gr_SEG_r)

# make names for levels
cls <- data.frame(ID=c(0,1), cover=c("other", "grassland"))
levels(gr_ALB_r) <- cls
levels(gr_HAI_r) <- cls
levels(gr_SEG_r) <- cls

writeRaster(gr_ALB_r, here(sap, "grassland_ALB_UTM_cat.tif"))
writeRaster(gr_HAI_r, here(sap, "grassland_HAI_UTM_cat.tif"))
writeRaster(gr_SEG_r, here(sap, "grassland_SEG_UTM_cat.tif"))


# landscapes
lsc_ALB <- st_read(here(sap, "landscape_ALB.gpkg"))
lsc_HAI <- st_read(here(sap, "landscape_HAI.gpkg"))
lsc_SEG <- st_read(here(sap, "landscape_SEG.gpkg"))


# crop landscape to grassland extent for Schorfheide-Chorin
lsc_SEG_UTM <- st_transform(lsc_SEG,utmproj)
lsc_SEG_cropped <- st_crop(lsc_SEG_UTM, gr_SEG)
plot(lsc_SEG_cropped)

# landscapes
lsc_ALB_UTM <- st_transform(lsc_ALB,utmproj)
lsc_HAI_UTM <- st_transform(lsc_HAI,utmproj)

st_write(lsc_ALB_UTM, here(sap, "landscape_ALB_UTM.gpkg"))
st_write(lsc_HAI_UTM, here(sap, "landscape_HAI_UTM.gpkg"), 
         append=F)
st_write(lsc_SEG_cropped, here(sap, "landscape_SEG_UTM.gpkg"), 
         append=F)



# Project climate rasters 

bioclim_vars <- c("Ann_Mean_Temp", "Mean_Drnl_Rng", "Isotherm", 
                  "Temp_Seas", "Max_T", "Min_T", "T_Ann_Rng", 
                  "Mean_T_Wet", "Mean_T_Dry", "Mean_T_Warm", 
                  "Mean_T_Cold", "Ann_Prec", "Prec_Wet", "Prec_Dry", 
                  "Prec_Seas", "Prec_Wet", "Prec_Dry", "Prec_Warm", "Prec_Cold")

bioclim_ALB <- rast(here(dp, "/Basisdaten/climate/ALB_bioclim-1981-2010.tif"))

names(bioclim_ALB) <- bioclim_vars

bioclim_ALB_UTM <- project(bioclim_ALB, utmproj)
bioclim_ALB_weather_UTM <- project(bioclim_ALB_weather, utmproj)

writeRaster(bioclim_ALB_UTM, here(dp, 
                                  "/Basisdaten/climate/bioclim_ALB_UTM.tif", 
                                  overwrite=T))
writeRaster(bioclim_ALB_weather_UTM, here(dp, 
             "/Basisdaten/weather/bioclim_ALB_weather_UTM.tif"), 
            overwrite=T)


tf <- list.files(here(dp, "/Basisdaten/topography/copernicus/"), 
                 pattern="ALB", full.names = T)
top_ALB <- rast(tf)
top_ALB_UTM <- project(top_ALB, crs(d_geo))
writeRaster(top_ALB_UTM, here(dp, 
                              "/Basisdaten/topography/copernicus/ALB_top_UTM.tif"))


# project weather rasters
bioclim_ALB_weather <- rast(here(dp, "/Basisdaten/weather/ALB_bioclim-2021.tif"))
names(bioclim_ALB_weather) <- bioclim_vars
bioclim_ALB_weather_UTM <- project(bioclim_ALB_weather, crs(d_geo))
writeRaster(bioclim_ALB_weather_UTM, here(dp, 
                                          "/Basisdaten/weather/ALB_bioclim-2021_UTM.tif"))