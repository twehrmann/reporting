library(RPostgreSQL)

setClass(Class="InputStructure_carbono5",
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

setClass(Class="InputStructureChanges_dcarbono",
         representation(
           AreasEstratosBUR="data.frame",
           AreasEstratosMADMEX="data.frame",
           BaseT1="data.frame",
           BaseT2="data.frame",
           EstratosBUR="data.frame",
           Estratos_BUR_IPCC="data.frame",
           EstratosMADMEX="data.frame",
           EstratosMADMEX_IPCC="data.frame"
         )
)

setClass(Class="InputStructure_biomasa",
         representation(         
           BaseT1="data.frame",
           BaseT2="data.frame",
           
           AreasEstratos_BUR="data.frame",
           EstratoCong_BUR="data.frame",
           EstratosIPCC_BUR="data.frame",
           
           AreasEstratos_MADMEX="data.frame",
           EstratoCong_MADMEX="data.frame",
           EstratosIPCC_MADMEX="data.frame"
         )
)

setClass(Class="InputStructure_error_prop",
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


getBaseData_error_prop <- function() {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  BaseCruces_BUR = dbGetQuery(con, config$input_data$BaseCruces_BUR)
  BaseDinamica_BUR = dbGetQuery(con, config$input_data$BaseDinamica_BUR)
  
  #OLD version
  #TablaFEdefor_BUR = dbGetQuery(con, "select * from r_error_prop.fe_deforestacion")
  #TablaFApermaP_BUR= dbGetQuery(con, "select * from r_error_prop.fe_permanencia")
  
  #NEW VERSION 
  TablaFEdefor_BUR = dbGetQuery(con, config$input_data$TablaFEdefor_BUR)
  TablaFApermaP_BUR= dbGetQuery(con, config$input_data$TablaFApermaP_BUR)
  
  TablaFEdegra_BUR= dbGetQuery(con, config$input_data$TablaFEdegra_BUR)
  TablaFArecup_BUR= dbGetQuery(con, config$input_data$TablaFArecup_BUR)
  
  
  BaseCruces_MADMEX = dbGetQuery(con, config$input_data$BaseCruces_MADMEX)
  BaseDinamica_MADMEX = dbGetQuery(con, config$input_data$BaseDinamica_MADMEX)
  TablaFEdefor_MADMEX = dbGetQuery(con, config$input_data$TablaFEdefor_MADMEX)
  TablaFEdegra_MADMEX= dbGetQuery(con, config$input_data$TablaFEdegra_MADMEX)
  TablaFArecup_MADMEX= dbGetQuery(con, config$input_data$TablaFArecup_MADMEX)
  TablaFApermaP_MADMEX= dbGetQuery(con, config$input_data$TablaFApermaP_MADMEX)
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure_error_prop",
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



getBaseData_biomasa <- function(calculo_version) {
  loginfo(paste0("Reading base data... v",calculo_version))
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  
  if (calculo_version == 19) {
    BaseT1 = dbGetQuery(con, config$input_data$BaseT1_v19)
    BaseT2 = dbGetQuery(con, config$input_data$BaseT2_v19)
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, config$input_data$BaseT1_v20)
    BaseT2 = dbGetQuery(con, config$input_data$BaseT2_v20)
  }
  loginfo("Reading BUR data...")
  
  AreasEstratos_BUR = dbGetQuery(con, config$input_data$AreasEstratos_BUR)
  EstratoCong_BUR = dbGetQuery(con, config$input_data$EstratoCong_biomasa_BUR)
  EstratosIPCC_BUR = dbGetQuery(con,  config$input_data$EstratosIPCC_BUR)
  
  loginfo("Reading MADMEX data...")
  AreasEstratos_MADMEX = dbGetQuery(con, config$input_data$AreasEstratos_MADMEX)
  EstratoCong_MADMEX= dbGetQuery(con, config$input_data$EstratoCong_MADMEX)
  Estratos_MADMEX_IPCC= dbGetQuery(con, config$input_data$EstratosIPCC_MADMEX)
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure_biomasa",
             BaseT1=BaseT1,
             BaseT2=BaseT2,
             
             AreasEstratos_BUR=AreasEstratos_BUR,
             EstratoCong_BUR=EstratoCong_BUR,
             EstratosIPCC_BUR=EstratosIPCC_BUR,
             
             AreasEstratos_MADMEX=AreasEstratos_MADMEX,
             EstratoCong_MADMEX=EstratoCong_MADMEX,
             EstratosIPCC_MADMEX=Estratos_MADMEX_IPCC
  ))
}



getBaseData_dcarbono <- function(calculo_version) {
  loginfo(paste0("Reading base data... v",calculo_version))
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  if (calculo_version == 19) {
    BaseT1 = dbGetQuery(con, config$input_data$BaseT1_v19)
    BaseT2 = dbGetQuery(con, config$input_data$BaseT2_v19)
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, config$input_data$BaseT1_v20)
    BaseT2 = dbGetQuery(con, config$input_data$BaseT2_v20)
  }
  loginfo("Reading BUR data...")
  
  AreasEstratos_BUR = dbGetQuery(con, config$input_data$AreasEstratosPersistentes_BUR)
  Estratos_BUR_IPCC= dbGetQuery(con,  config$input_data$EstratosIPCC_BUR)
  EstratoCong_BUR= dbGetQuery(con,  config$input_data$EstratoSitio_s4_s5_BUR)
  
  
  loginfo("Reading MADMEX data...")
  
  AreasEstratos_MADMEX = dbGetQuery(con, config$input_data$AreasEstratosPersistentes_MADMEX)
  EstratoCong_MADMEX= dbGetQuery(con, config$input_data$EstratoCong_MADMEX)
  Estratos_MADMEX_IPCC= dbGetQuery(con, config$input_data$EstratosIPCC_MADMEX)
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructureChanges_dcarbono",
             AreasEstratosBUR=AreasEstratos_BUR,
             AreasEstratosMADMEX=AreasEstratos_MADMEX,
             BaseT1=BaseT1,
             BaseT2=BaseT2,
             EstratosBUR=EstratoCong_BUR,
             EstratosMADMEX=EstratoCong_MADMEX,
             Estratos_BUR_IPCC=Estratos_BUR_IPCC,
             EstratosMADMEX_IPCC=Estratos_MADMEX_IPCC
  ))
}


getBaseData_carbono5 <- function(calculo_version) {
  loginfo(paste0("Reading base data (v",calculo_version,")..."))
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  if (calculo_version == 19) {
    BaseT1 = dbGetQuery(con, config$input_data$BaseT1_v19)
    BaseT2 = dbGetQuery(con, config$input_data$BaseT2_v19)
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, config$input_data$BaseT1_v20)
    BaseT2 = dbGetQuery(con, config$input_data$BaseT2_v20)
  }
  
  loginfo("Reading BUR data...")
  AreasEstratos_BUR = dbGetQuery(con, config$input_data$AreasEstratos_BUR)
  EstratoCong_BUR= dbGetQuery(con, config$input_data$EstratoCong_BUR)
  Estratos_BUR_IPCC= dbGetQuery(con, config$input_data$EstratosIPCC_BUR)
  
  loginfo("Reading MADMEX data...")
  AreasEstratos_MADMEX = dbGetQuery(con, config$input_data$AreasEstratos_MADMEX)
  EstratoCong_MADMEX= dbGetQuery(con, config$input_data$EstratoCong_MADMEX)
  Estratos_MADMEX_IPCC= dbGetQuery(con, config$input_data$EstratosIPCC_MADMEX)
  
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure_carbono5",
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
  dbWriteTable(con,db_table_name,data)
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  
  return(TRUE)
}