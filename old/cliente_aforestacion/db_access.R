library(RPostgreSQL)

setClass(Class="InputStructure",
         representation(         
           BaseT1="data.frame",
           BaseT2="data.frame",
           
           EstratoCongT1_BUR="data.frame",
           EstratoCongT2_BUR="data.frame",
           EstratosIPCC_BUR="data.frame",
           AreasEstratos_BUR="data.frame",
           
           
           EstratoCongT1_MADMEX="data.frame",
           EstratoCongT2_MADMEX="data.frame",
           EstratosIPCC_MADMEX="data.frame",
           AreasEstratos_MADMEX="data.frame"
         )
)


getBaseData <- function(calculo_version) {
  loginfo(paste0("Reading base data... v",calculo_version))
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  
  if (calculo_version == 19) {
    BaseT1 = dbGetQuery(con, "select * from r_fe_recup_refor.calculo_20131030_v19_t1")
    BaseT2 = dbGetQuery(con, "select * from r_fe_recup_refor.calculo_20131030_v19_t2")
  } else if (calculo_version == 20) {
    BaseT1 = dbGetQuery(con, "select * from mssql.calculo_sitio_v20_t1")
    BaseT2 = dbGetQuery(con, "select * from mssql.calculo_sitio_v20_t2")
  }
  loginfo("Reading BUR data...")
  
  AreasEstratos_BUR = dbGetQuery(con, "select * from r_dcarbono.areas_estratos_pmn")
  EstratoCongT1_BUR = dbGetQuery(con, 'select * from r_fe_recup_refor."EstratosCongPMNgusSerieIV"')
  EstratoCongT2_BUR = dbGetQuery(con,  'select * from r_fe_recup_refor."EstratosCongPMNgusSerieV"')
  EstratosIPCC_BUR = dbGetQuery(con, "select * from r_biomasa_viva.estratos_pmn_ipcc")
  
  loginfo("Reading MADMEX data...")
  AreasEstratos_MADMEX = dbGetQuery(con, "select madmex_05_10, areas_cves4_cves5_pmn from madmex.v_areas_estratos_persistent_lcc")
  EstratoCongT1_MADMEX= dbGetQuery(con, "select * from  madmex.estrato_cong_pmn_gus_serie4_2_madmex_05_10")
  EstratoCongT2_MADMEX= dbGetQuery(con, "select * from  madmex.estrato_cong_pmn_gus_serie4_2_madmex_05_10")
  EstratosIPCC_MADMEX= dbGetQuery(con, "select * from madmex.v_estratos_madmex_ipcc")
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure",
             BaseT1=BaseT1,
             BaseT2=BaseT2,
             
             AreasEstratos_BUR=AreasEstratos_BUR,
             EstratoCongT1_BUR=EstratoCongT1_BUR,
             EstratoCongT2_BUR=EstratoCongT2_BUR,
             EstratosIPCC_BUR=EstratosIPCC_BUR,
             
             AreasEstratos_MADMEX=AreasEstratos_MADMEX,
             EstratoCongT1_MADMEX=EstratoCongT1_MADMEX,
             EstratoCongT2_MADMEX=EstratoCongT2_MADMEX,
             EstratosIPCC_MADMEX=EstratosIPCC_MADMEX
  ))
}

storeResults <- function(db_table_name, data) {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname=config$db$name, host=config$db$host, user=config$db$user, password=config$db$pass)
  
  
  pg_table <- tolower(paste(db_table_name, collapse = '.'))
  if (dbExistsTable(con,db_table_name)) {
    dbRemoveTable(con,db_table_name)
    print(paste("Removing existing table:",pg_table))
  }
  index <- rep(seq_len(nrow(data)))
  data$id <- index
  new_struct = data[,c(ncol(data),seq(1,ncol(data)-1))]
  dbWriteTable(con,tolower(db_table_name),new_struct, row.names=FALSE,add.id=TRUE)
  rs  <- dbSendQuery( con, paste0('ALTER TABLE ',pg_table," ADD PRIMARY KEY (id)"))
  
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  
  return(TRUE)
}

