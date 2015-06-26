library(logging)
basicConfig()

setwd("/Volumes/SSD2go_tw/conafor/reporting/cliente_delta_carbon")
BASE_VERSION = 20

DEBUG=FALSE

source("tools.R")
source("db_access.R")
source("calc_changes.R")

inputData = getBaseData(calculo_version=BASE_VERSION)
FULL = !DEBUG

runModule <- function(fe_variable_gui, lcc_type_gui) {
  data=calcChanges(fe_variable_gui, lcc_type_gui, inputData)
  
  
  DB_SCHEME="client_output"
  db_table_name = c(DB_SCHEME, paste0("FE_delta_strata_",fe_variable_gui,"_",lcc_type_gui))
  if (data@status) {
    success = storeResults(db_table_name, data@result)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

if (DEBUG) {
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","BUR")))
  
  print(warnings())
  
} else if (FULL) {
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","BUR")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_raices_por_sitio","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_raices_por_sitio","BUR")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_muertospie","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_muertospie","BUR")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_tocones","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_tocones","BUR")))
  print(warnings())
}