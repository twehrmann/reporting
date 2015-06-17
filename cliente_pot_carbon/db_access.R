library(RPostgreSQL)

setClass(Class="InputStructure",
         representation(
           AreasEstratos_BUR="data.frame",
           AreasEstratos_MADMEX="data.frame",
           BaseT1_orig="data.frame",
           EstratoCong_BUR="data.frame",
           EstratoCong_MADMEX="data.frame",
           Estratos_BUR_IPCC="data.frame",
           Estratos_MADMEX_IPCC="data.frame"
         )
)

setClass(Class="InputStructureChanges",
         representation(
           AreasEstratos="data.frame",
           BaseT1="data.frame",
           BaseT2="data.frame",
           EstratosBUR="data.frame",
           EstratosIPCC="data.frame"
         )
)


getBaseData <- function() {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
  AreasEstratos_BUR = dbGetQuery(con, "select cves,cves2_pmn,cves3_pmn,cves4_pmn from r_carbono5.areas_estratos_pmn")
  AreasEstratos_MADMEX = dbGetQuery(con, "select cves,cves2_pmn,cves3_pmn,cves4_pmn from r_carbono5.areas_estratos_madmex")
  BaseT1_orig = dbGetQuery(con, "select * from r_carbono5.calculo_20140421_v19_t1")
  EstratoCong_BUR= dbGetQuery(con, "select * from r_carbono5.estrato_cong_pmn_gus_serie4_2")
  EstratoCong_MADMEX= dbGetQuery(con, "select * from  r_carbono5.estrato_cong_pmn_madmex_gus_serie4_2_a")
  Estratos_BUR_IPCC= dbGetQuery(con, "select * from r_carbono5.estratos_pmn_ipcc")
  Estratos_MADMEX_IPCC= dbGetQuery(con, "select * from r_carbono5.estratos_madmex_ipcc")
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure",
             AreasEstratos_BUR=AreasEstratos_BUR,
             AreasEstratos_MADMEX=AreasEstratos_MADMEX,
             BaseT1_orig=BaseT1_orig,
             EstratoCong_BUR=EstratoCong_BUR,
             EstratoCong_MADMEX=EstratoCong_MADMEX,
             Estratos_BUR_IPCC=Estratos_BUR_IPCC,
             Estratos_MADMEX_IPCC=Estratos_MADMEX_IPCC
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
  dbWriteTable(con,db_table_name,data@result)
 
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  
  return(TRUE)
}