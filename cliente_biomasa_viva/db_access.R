library(RPostgreSQL)

setClass(Class="InputStructure",
         representation(
           AreasEstratos="data.frame",
           BaseT1="data.frame",
           EstratoCong="data.frame",
           EstratosIPCC="data.frame"
         )
)


getBaseData <- function() {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
  AreasEstratos = dbGetQuery(con, "select * from r_biomasa_viva.areas_estratos")

  Base = dbGetQuery(con, "select * from r_biomasa_viva.base_carbono")
  EstratoCong= dbGetQuery(con, "select * from r_biomasa_viva.estratos_cong_pmn_gus_s4")
  EstratosIPCC= dbGetQuery(con, "select * from r_biomasa_viva.estratos_pmn_ipcc")
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure",
             AreasEstratos=AreasEstratos,
             BaseT1=Base,
             EstratoCong=EstratoCong,
             EstratosIPCC=EstratosIPCC
  ))
}

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