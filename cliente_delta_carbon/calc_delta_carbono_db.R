setwd("/Volumes/SSD2go_tw/conafor/R Client/cliente_delta_carbon")
DEBUG=TRUE


source("tools.R")
source("db_access.R")
source("calc_changes.R")

runModule <- function(fe_variable_gui, lcc_type_gui) {
  
  print("Read data files...")
  inputData = getBaseData()
  
  data=calcChanges(fe_variable_gui, lcc_type_gui, inputData)
  
  
  DB_SCHEME="client_output"
  db_table_name = c(DB_SCHEME, paste0("FE_delta_",fe_variable_gui,"_",lcc_type_gui))
  if (data@status) {
    print (data)
    success = storeResults(db_table_name, data@result)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

if (DEBUG) {
  print (runModule("carbono_arboles","BUR"))
}