source("tools.R")
source("db_access.R")
source("calc_error_prop.R")
DEBUG=TRUE

inputData = getBaseData_error_prop()
FULL = !DEBUG

runModule <- function(lcc_type_gui) {
  data=calcErrorProp(lcc_type_gui, inputData)
  
  if (data@status) {
    db_table_name = c(DB_SCHEME,paste0("FEFA_IPCC_abs_s2s3_",lcc_type_gui))
    success = storeResults(db_table_name, data@TablaEmiAbsS2S3)
    loginfo(success)
    db_table_name = c(DB_SCHEME,paste0("FEFA_IPCC_",lcc_type_gui))
    success = storeResults(db_table_name, data@TablaFEFA)
    loginfo(success)
    
    db_table_name = c(DB_SCHEME, paste0("FEFA_dinamica_",lcc_type_gui))
    success = storeResults(db_table_name, data@BaseTransiS2S3)
    loginfo(success)
    
    return(TRUE)
  } else {
    return(FALSE)
  }
  print(success)
  
  return(success)
}
if (DEBUG) {
  success = runModule("BUR")
  success = runModule("MADMEX")
} else {
  success = runModule("BUR")
  success = runModule("MADMEX")
}
print(success)
print(warnings())

