library(logging)
basicConfig()

setwd("/Volumes/SSD2go_tw/conafor/reporting/old/cliente_aforestacion")
BASE_VERSION = 20
DB_SCHEME="client_output"


DEBUG=FALSE

source("tools.R")
source("db_access.R")
source("calc_recup_refor.R")

BASE_VERSION=19
inputData = getBaseData(BASE_VERSION)
FULL = !DEBUG


runModule <- function(fe_variable_gui, lcc_type_gui) {
  data=calcRecup_refor(fe_variable_gui, lcc_type_gui, inputData)
  success=FALSE
  
  
  db_table_name = c(DB_SCHEME, paste0("FE_rec_strata_",fe_variable_gui,"_",lcc_type_gui))
  if (data@status) {
    success = storeResults(db_table_name, data@result)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

if (DEBUG) {
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","BUR")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","MADMEX")))
} else if (FULL) {
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","BUR")))
  #loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_raices_por_sitio","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_raices_por_sitio","BUR")))
  #loginfo (paste("Status of FE calculation:",runModule("carbono_raices_por_sitio","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_muertospie","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_muertospie","BUR")))
  #loginfo (paste("Status of FE calculation:",runModule("carbono_muertospie","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_tocones","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_tocones","BUR")))
  #loginfo (paste("Status of FE calculation:",runModule("carbono_tocones","INEGI")))
  
}
print(warnings())
