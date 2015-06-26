
library(RPostgreSQL)

storeResults <- function(db_table_name, data) {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
  
  
  if (dbExistsTable(con,db_table_name)) {
    dbRemoveTable(con,db_table_name)
    print(paste("Removing existing table:",paste(db_table_name, collapse = '.')))
  }
  dbWriteTable(con,db_table_name,data)
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  
  return(TRUE)
}


setwd("/Volumes/SSD2go_tw/conafor/R scripts Oswaldo/3 Recuperacion Reforestación")
DB_SCHEME  ="r_estfe_recuperacion_refor"
data<-read.csv("Calculo_20131030_CarbonoHectarea(2004-2012)_VERSION_19_t2.csv")

db_table_name = c(DB_SCHEME, "calculo_20131030_v19_t2")
print(storeResults(db_table_name, data))