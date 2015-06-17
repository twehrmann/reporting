
setwd("/Volumes/SSD2go_tw/conafor/R Client/cliente_pot_carbon")
source("tools.R")
source("db_access.R")
source("calc_FE.R")
DEBUG=TRUE

runModule <- function(fe_variable_gui, lcc_type_gui) {
  inputData = getBaseData()
  
  print (fe_variable_gui)
  print (lcc_type_gui)
  
  DB_SCHEME="client_output"
  db_table_name = c(DB_SCHEME, paste0("FE_pot_",fe_variable_gui,"_",lcc_type_gui))
  data=calcFE(fe_variable_gui, lcc_type_gui, inputData)
  if (data@status) {
    success = storeResults(db_table_name, data)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

if (DEBUG) {
  print (runModule("biomasa_arboles","MADMEX"))
}