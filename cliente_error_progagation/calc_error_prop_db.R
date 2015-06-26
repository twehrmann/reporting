library(logging)
basicConfig()

setwd("/Volumes/SSD2go_tw/conafor/reporting/cliente_error_progagation")
source("tools.R")
source("db_access.R")
source("calc_error_prop.R")

inputData = getBaseData()
DB_SCHEME="client_output"
FULL = !DEBUG

runModule <- function(lcc_type_gui) {
  data=calcErrorProp(inputData)
  
  if (data@status) {
    db_table_name = c(DB_SCHEME,"FE_IPCC_abs_s2s3_BUR")
    success = storeResults(db_table_name, data@TablaEmiAbsS2S3)
    print(success)
    db_table_name = c(DB_SCHEME,"FEFA_IPCC_BUR")
    success = storeResults(db_table_name, data@TablaFEFA)
    print(success)
    
    db_table_name = c(DB_SCHEME,"FE_dinamica_BUR")
    success = storeResults(db_table_name, data@BaseTransiS2S3)
    print(success)
    
    return(TRUE)
  } else {
    return(FALSE)
  }
  print(success)
  
  return(success)
}

success = runModule("BUR")

print(success)