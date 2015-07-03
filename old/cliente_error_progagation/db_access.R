library(RPostgreSQL)

setClass(Class="InputStructure",
         representation(
           BaseCruces_BUR="data.frame",
           BaseDinamica_BUR="data.frame",
           TablaFEdefor_BUR="data.frame",
           TablaFEdegra_BUR="data.frame",
           TablaFArecup_BUR="data.frame",
           TablaFApermaP_BUR="data.frame",
           
           BaseCruces_MADMEX="data.frame",
           BaseDinamica_MADMEX="data.frame",
           TablaFEdefor_MADMEX="data.frame",
           TablaFEdegra_MADMEX="data.frame",
           TablaFArecup_MADMEX="data.frame",
           TablaFApermaP_MADMEX="data.frame"
         )
)


getBaseData <- function() {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  BaseCruces_BUR = dbGetQuery(con, "select * from r_error_prop.cruces_series_inegi")
  BaseDinamica_BUR = dbGetQuery(con, "select * from r_error_prop.dinamica_bur")
  #OLD version
  #TablaFEdefor_BUR = dbGetQuery(con, "select * from r_error_prop.fe_deforestacion")
  #TablaFApermaP_BUR= dbGetQuery(con, "select * from r_error_prop.fe_permanencia")
  
  TablaFEdefor_BUR = dbGetQuery(con, 'select "Estrato", "nCong" as n, "ER_Carboles" as "FE", "U_Carboles" as "U" from client_output."FE_bm_estrato_sitio_carbono_arboles_BUR"')
  TablaFApermaP_BUR= dbGetQuery(con, 'select "Estrato" || \' - \' || "Estrato"  as "Estrato", "NumCong" as n, "ER" as "FE", "U" as "U" from client_output."FE_delta_strata_carbono_arboles_BUR"')
  
  TablaFEdegra_BUR= dbGetQuery(con, "select * from r_error_prop.fe_degradacion")
  TablaFArecup_BUR= dbGetQuery(con, "select * from  r_error_prop.fe_recuperacion")
  
  
  BaseCruces_MADMEX = dbGetQuery(con, "select * from r_error_prop.cruces_series_inegi")
  BaseDinamica_MADMEX = dbGetQuery(con, "select * from r_error_prop.dinamica_bur")
  TablaFEdefor_MADMEX = dbGetQuery(con, "select * from r_error_prop.fe_deforestacion")
  TablaFEdegra_MADMEX= dbGetQuery(con, "select * from r_error_prop.fe_degradacion")
  TablaFArecup_MADMEX= dbGetQuery(con, "select * from  r_error_prop.fe_recuperacion")
  TablaFApermaP_MADMEX= dbGetQuery(con, "select * from r_error_prop.fe_permanencia")
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure",
             BaseCruces_BUR=BaseCruces_BUR,
             BaseDinamica_BUR=BaseDinamica_BUR,
             TablaFEdefor_BUR=TablaFEdefor_BUR,
             TablaFEdegra_BUR=TablaFEdegra_BUR,
             TablaFArecup_BUR=TablaFArecup_BUR,
             TablaFApermaP_BUR=TablaFApermaP_BUR,
             
             BaseCruces_MADMEX=BaseCruces_MADMEX,
             BaseDinamica_MADMEX=BaseDinamica_MADMEX,
             TablaFEdefor_MADMEX=TablaFEdefor_MADMEX,
             TablaFEdegra_MADMEX=TablaFEdegra_MADMEX,
             TablaFArecup_MADMEX=TablaFArecup_MADMEX,
             TablaFApermaP_MADMEX=TablaFApermaP_MADMEX
  ))
}

getBaseChangesData <- function() {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
    
  AreasEstratos_BUR = dbGetQuery(con, "select * from r_dcarbono.areas_estratos")

  BaseT1 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_madmex_t1")
  BaseT2 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_madmex_t2")
  EstratoCong_BUR= dbGetQuery(con, "select * from r_dcarbono.t_1234_pmn45")
  Estratos_BUR_IPCC= dbGetQuery(con, "select * from r_dcarbono.estratos_pmn_ipcc")
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructureChanges",
             AreasEstratos=AreasEstratos_BUR,
             BaseT1=BaseT1,
             BaseT2=BaseT2,
             EstratosBUR=Estratos_BUR_IPCC,
             EstratosIPCC=Estratos_BUR_IPCC
  ))
}

storeResults <- function(db_table_name, data) {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  
  
  if (dbExistsTable(con,db_table_name)) {
    dbRemoveTable(con,db_table_name)
    loginfo(paste("Removing existing table:",paste(db_table_name, collapse = '.')))
  }
  dbWriteTable(con,db_table_name,data)
 
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  
  return(TRUE)
}