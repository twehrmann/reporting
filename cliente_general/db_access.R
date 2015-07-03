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
           EstratosMADMEX_IPCC="data.frame",
           PersistentEstratos_BUR ="data.frame",
           PersistentEstratos_MADMEX ="data.frame"
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
  
  BaseCruces_BUR = dbGetQuery(con, "select * from r_error_prop.cruces_series_inegi")
  BaseDinamica_BUR = dbGetQuery(con, "select * from r_error_prop.dinamica_bur")
  
  #OLD version
  #TablaFEdefor_BUR = dbGetQuery(con, "select * from r_error_prop.fe_deforestacion")
  #TablaFApermaP_BUR= dbGetQuery(con, "select * from r_error_prop.fe_permanencia")
 
  #NEW VERSION 
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
    BaseT1 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t1")
    BaseT2 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t2")
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, "select * from mssql.calculo_sitio_v20_t1")
    BaseT2 = dbGetQuery(con, "select * from mssql.calculo_sitio_v20_t2")
  }
  loginfo("Reading BUR data...")
  
  AreasEstratos_BUR = dbGetQuery(con, "select * from r_biomasa_viva.areas_estratos")
  EstratoCong_BUR = dbGetQuery(con, "select * from r_biomasa_viva.estratos_cong_pmn_gus_s4")
  EstratosIPCC_BUR = dbGetQuery(con, "select * from r_biomasa_viva.estratos_pmn_ipcc")
  
  loginfo("Reading MADMEX data...")
  AreasEstratos_MADMEX = dbGetQuery(con, "select cves, madmex_05, inegi_s4 from madmex.v_areas_estratos")
  EstratoCong_MADMEX= dbGetQuery(con, "select * from  madmex.estrato_cong_pmn_gus_serie4_2_madmex_05_10")
  EstratosIPCC_MADMEX= dbGetQuery(con, "select * from madmex.v_estratos_madmex_ipcc")
  
  
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
             EstratosIPCC_MADMEX=EstratosIPCC_MADMEX
  ))
}



getBaseData_dcarbono <- function(calculo_version) {
  loginfo(paste0("Reading base data... v",calculo_version))
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  if (calculo_version == 19) {
    BaseT1 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t1")
    BaseT2 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t2")
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, "select * from mssql.calculo_sitio_v20_t1")
    BaseT2 = dbGetQuery(con, "select * from mssql.calculo_sitio_v20_t2")
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
  
  return(new("InputStructureChanges_dcarbono",
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


getBaseData_carbono5 <- function(calculo_version) {
  loginfo(paste0("Reading base data (v",calculo_version,")..."))
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)

  if (calculo_version == 19) {
    BaseT1 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t1")
    BaseT2 = dbGetQuery(con, "select * from r_dcarbono.calculo_20140421_v19_t2")
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, "select * from mssql.calculo_sitio_v20_t1")
    BaseT2 = dbGetQuery(con, "select * from mssql.calculo_sitio_v20_t2")
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