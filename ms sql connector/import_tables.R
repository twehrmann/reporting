
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
  
  data$id = seq(nrow(data))
  new_struct = data
  new_struct = new_struct[c(ncol(data), seq(ncol(data)-1))]
  dbWriteTable(con,db_table_name,new_struct, row.names=FALSE)
  
  SQL =paste0("ALTER TABLE ",paste(db_table_name, collapse = '.')," ADD PRIMARY KEY (id)")
  rs  <- dbSendQuery( con, SQL)
  
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  
  return(TRUE)
}


setwd("/Volumes/SSD2go_tw/conafor/tablas_reports_luis")
DB_SCHEME  ="mssql"
data<-read.csv("Calculo_20150721_Reporte_Nivel_Observacion_Estimacion_(2004-2007)_version_20.txt", sep="\t", header=TRUE)
db_table_name = c(DB_SCHEME, "import_calculo_20150727_obs_t1")
print(storeResults(db_table_name, data))

data<-read.csv("Calculo_20150721_Reporte_Nivel_Observacion_Estimacion_(2009-2013)_version_20.txt", sep="\t", header=TRUE)
db_table_name = c(DB_SCHEME, "import_calculo_20150727_obs_t2")
print(storeResults(db_table_name, data))

data<-read.csv("Calculo_20150727_Reporte_Nivel_UnidadMuestreo_Estimacion_(2004-2007)_version_20.csv", header=TRUE)
db_table_name = c(DB_SCHEME, "import_calculo_20150727_udm_t1")
print(storeResults(db_table_name, data))

data<-read.csv("Calculo_20150727_Reporte_Nivel_UnidadMuestreo_Estimacion_(2009-2013)_version_20.csv", header=TRUE)
db_table_name = c(DB_SCHEME, "import_calculo_20150727_udm_t2")
print(storeResults(db_table_name, data))


