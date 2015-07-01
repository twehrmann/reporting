library(RPostgreSQL)

setClass(Class="InputStructure",
         representation(
           BaseT1="data.frame",
           BaseT2="data.frame",
           
           AreasEstratos_BUR="data.frame",
           Estratos_BUR_IPCC="data.frame",
           EstratoCong_BUR="data.frame",
           
           AreasEstratos_MADMEX="data.frame",
           Estratos_MADMEX_IPCC="data.frame",
           EstratoCong_MADMEX="data.frame"
         )
)


getBaseData <- function(calculo_version) {
  loginfo(paste0("Reading base data (",calculo_version,")..."))
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  
  
  if (calculo_version == 19) {
    BaseT1 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t1")
    BaseT2 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t2")
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, "select * from mssql.calculo_sitio_20141208_v20_t1")
    BaseT2 = dbGetQuery(con, "select * from mssql.calculo_sitio_20141208_v20_t2")
  }
  
  loginfo("Reading BUR data...")
  AreasEstratos_BUR = dbGetQuery(con, "select cves,cves2_pmn,cves3_pmn,cves4_pmn from r_carbono5.areas_estratos_pmn")
  EstratoCong_BUR= dbGetQuery(con, "select * from r_carbono5.estrato_cong_pmn_gus_serie4_2")
  Estratos_BUR_IPCC= dbGetQuery(con, "select * from r_carbono5.estratos_pmn_ipcc")
  
  loginfo("Reading MADMEX data...")
  AreasEstratos_MADMEX = dbGetQuery(con, "select cves, madmex_05, inegi_s4 from madmex.v_areas_estratos")
  EstratoCong_MADMEX= dbGetQuery(con, "select * from  madmex.estrato_cong_pmn_gus_serie4_2_madmex_05_10")
  Estratos_MADMEX_IPCC= dbGetQuery(con, "select * from madmex.v_estratos_madmex_ipcc")
  
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure",
             BaseT1=BaseT1,
             BaseT2=BaseT2,
             
             AreasEstratos_BUR=AreasEstratos_BUR,
             EstratoCong_BUR=EstratoCong_BUR,
             Estratos_BUR_IPCC=Estratos_BUR_IPCC,
             
             AreasEstratos_MADMEX=AreasEstratos_MADMEX,
             EstratoCong_MADMEX=EstratoCong_MADMEX,
             Estratos_MADMEX_IPCC=Estratos_MADMEX_IPCC
  )
  )
}


storeResults <- function(db_table_name, data) {
  loginfo(paste("Writing result to ",db_table_name))
  
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  
  if (dbExistsTable(con,db_table_name)) {
    dbRemoveTable(con,db_table_name)
    loginfo(paste("Removing existing table:",paste(db_table_name, collapse = '.')))
  }
  dbWriteTable(con,db_table_name,data@result)
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  
  return(TRUE)
}