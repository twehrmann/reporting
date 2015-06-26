library(RPostgreSQL)
library(raster)
setwd("/Users/thilo/conabio/data/madmex/")

##########
# VARS
OFFSET = 0
FROM=0
STEPS=1000
SRID = 48402
L=22025
L=104880
L=STEPS
TABLE_VALUE="madmex_93"
TABLE = "madmex.sitio_lc"
TABLE = "madmex.conglomerado_lc"


IMAGE="madmex_lcc_landsat_1993_v4.3.tif"
#############

for (OFFSET in seq(from=FROM, to=L, by=STEPS)) {
  print(OFFSET)
  start <- Sys.time ()
  
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
  #coords_sitio = dbGetQuery(con, paste0("select numnal, sitio, st_x(st_transform(the_geom,", SRID," )), st_y(st_transform(the_geom,",SRID,")) from ",TABLE," order by numnal, sitio limit ",STEPS," offset ",OFFSET))
  coords_sitio = dbGetQuery(con, paste0("select folio, sitio, st_x(st_transform(the_geom,", SRID," )), st_y(st_transform(the_geom,",SRID,")) from ",TABLE," order by folio, sitio limit ",STEPS," offset ",OFFSET))
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
    #SQL = paste0("UPDATE ",TABLE, " SET ", TABLE_VALUE, " = ",lc, " WHERE numnal=",s$numnal," and sitio=",s$sitio)
    
    SQL = paste0("UPDATE ",TABLE, " SET ", TABLE_VALUE, " = ",lc, " WHERE folio=",s$folio," and sitio=",s$sitio)
    if (!is.na(s$sitio)) {
      rs <- dbSendQuery(con, SQL)
    }
  }
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  print(Sys.time () - start)
}
