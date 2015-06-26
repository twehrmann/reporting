library(RPostgreSQL)

setClass(Class="InputStructureChanges",
         representation(
           AreasEstratosBUR="data.frame",
           AreasEstratosMADMEX="data.frame",
           BaseT1="data.frame",
           BaseT2="data.frame",
           EstratosBUR="data.frame",
           Estratos_BUR_IPCC="data.frame",
           EstratosMADMEX="data.frame",
           EstratosMADMEX_IPCC="data.frame",
           PersistentEstratos_BUR ="data.frame",
           PersistentEstratos_MADMEX ="data.frame"
         )
)


getBaseData <- function(calculo_version) {
  loginfo(paste0("Reading base data... v",calculo_version))
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
  # v20 with warning: 3: In Cambios(y_t1 = y_t1, y_t2 = y_t2, t1 = t1, t2 = t2, conglomerado = conglomerado,  :NAs introduced by coercion
  if (calculo_version == 19) {
    BaseT1 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t1")
    BaseT2 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t2")
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, "select * from mssql.calculo_sitio_20141208_v20_t1")
    BaseT2 = dbGetQuery(con, "select * from mssql.calculo_sitio_20141208_v20_t2")
  }
  loginfo("Reading BUR data...")
  
  AreasEstratos_BUR = dbGetQuery(con, "select * from r_dcarbono.areas_estratos_pmn")
  Estratos_BUR_IPCC= dbGetQuery(con, "select * from r_dcarbono.estratos_pmn_ipcc")
  EstratoCong_BUR= dbGetQuery(con, "select * from r_dcarbono.t_1234_pmn45")
  PersistentEstratos_BUR = dbGetQuery(con, "select distinct cves4_cves5_pmn from r_dcarbono.areas_estratos_pmn where  cves4_cves5_pmn not like 'PE%' order by cves4_cves5_pmn")
  
  loginfo("Reading MADMEX data...")
  
  AreasEstratos_MADMEX = dbGetQuery(con, "select * from madmex.v_areas_estratos_persistent_lcc")
  EstratoCong_MADMEX= dbGetQuery(con, "select * from madmex.estrato_cong_pmn_gus_serie4_2_madmex_05_10")
  Estratos_MADMEX_IPCC= dbGetQuery(con, "select * from madmex.v_estratos_madmex_ipcc")
  
  PersistentEstratos_MADMEX = dbGetQuery(con, "select distinct cves4_cves5_pmn from r_dcarbono.areas_estratos_pmn where  cves4_cves5_pmn not like 'PE%' order by cves4_cves5_pmn")
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructureChanges",
             AreasEstratosBUR=AreasEstratos_BUR,
             AreasEstratosMADMEX=AreasEstratos_MADMEX,
             BaseT1=BaseT1,
             BaseT2=BaseT2,
             EstratosBUR=EstratoCong_BUR,
             EstratosMADMEX=EstratoCong_MADMEX,
             Estratos_BUR_IPCC=Estratos_BUR_IPCC,
             EstratosMADMEX_IPCC=Estratos_MADMEX_IPCC,
             PersistentEstratos_BUR=PersistentEstratos_BUR,
             PersistentEstratos_MADMEX=PersistentEstratos_MADMEX
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