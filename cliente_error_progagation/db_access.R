library(RPostgreSQL)

setClass(Class="InputStructure",
         representation(
           BaseCruces="data.frame",
           BaseDinamica="data.frame",
           TablaFEdefor="data.frame",
           TablaFEdegra="data.frame",
           TablaFArecup="data.frame",
           TablaFApermaP="data.frame"
         )
)


getBaseData <- function() {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
  BaseCruces = dbGetQuery(con, "select * from r_error_prop.cruces_series_inegi")
  BaseDinamica = dbGetQuery(con, "select * from r_error_prop.dinamica_bur")
  TablaFEdefor = dbGetQuery(con, "select * from r_error_prop.fe_deforestacion")
  TablaFEdegra= dbGetQuery(con, "select * from r_error_prop.fe_degradacion")
  TablaFArecup= dbGetQuery(con, "select * from  r_error_prop.fe_recuperacion")
  TablaFApermaP= dbGetQuery(con, "select * from r_error_prop.fe_permanencia")
  
  ## Closes the connection
  dbDisconnect(con)
  ## Frees all the resources on the driver
  dbUnloadDriver(drv)
  
  return(new("InputStructure",
             BaseCruces=BaseCruces,
             BaseDinamica=BaseDinamica,
             TablaFEdefor=TablaFEdefor,
             TablaFEdegra=TablaFEdegra,
             TablaFArecup=TablaFArecup,
             TablaFApermaP=TablaFApermaP
  ))
}

getBaseChangesData <- function() {
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  ## Open a connection
  con <- dbConnect(drv, dbname="reporting", host="reddbase.conabio.gob.mx", user="postgres", password="postgres.")
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