library(RPostgreSQL)
library(raster)
setwd("/Users/thilo/conabio/data/madmex/")

##########
# VARS
OFFSET = 0
STEPS=1000
SRID = 48402
L=104880
TABLE_VALUE="madmex_05"
TABLE = "madmex.madmex_lc_sitios"
IMAGE="madmex_lcc_landsat_2005_v4.3.tif"
#############

for (OFFSET in seq(from=1, to=L, by=STEPS)) {
  print(OFFSET)
  start <- Sys.time ()
  
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
  coords_sitio = dbGetQuery(con, paste0("select numnal, anio_m, sitios_m,sitio, st_x(st_transform(the_geom,",SRID,")), st_y(st_transform(the_geom,",SRID,")) from madmex.madmex_lc_sitios order by numnal, sitio limit ",STEPS," offset ",OFFSET))
  old_coords = coords_sitio
  ## Closes the connection
  dbDisconnect(con)  
  
  rst <- raster(IMAGE)
  coordinates(coords_sitio)= ~ st_x+ st_y
  rasValue=extract(rst, coords_sitio)
  combinePointValue=cbind(coords_sitio,rasValue)
  

  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
  for (row in 1:nrow(combinePointValue)) {
    position = combinePointValue[row,1]$coords_sitio
    lc = combinePointValue[row,2]$rasValue
    s = old_coords[row,]
    if (is.na(lc)) {
      lc = 0
    }
    SQL = paste0("UPDATE ",TABLE, " SET ", TABLE_VALUE, " = ",lc, " WHERE numnal=",s$numnal," and sitio=",s$sitio," AND anio_m=",s$anio_m," AND sitios_m=",s$sitios_m)
    rs <- dbSendQuery(con, SQL)
    
  }
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  print(Sys.time () - start)
}
