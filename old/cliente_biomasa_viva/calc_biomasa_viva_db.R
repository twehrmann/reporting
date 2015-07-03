library(logging)
basicConfig()

setwd("/Volumes/SSD2go_tw/conafor/reporting/cliente_biomasa_viva")
BASE_VERSION = 20
DB_SCHEME="client_output"


DEBUG=FALSE

source("tools.R")
source("db_access.R")
source("calc_biomasa_viva.R")

inputData = getBaseData(BASE_VERSION)
FULL = !DEBUG


runModule <- function(fe_variable_gui, lcc_type_gui) {
  data=calcBiomasaViva(fe_variable_gui, lcc_type_gui, inputData)
  success=FALSE
  
  db_table_name_sum = c(DB_SCHEME, paste0("FE_bm_sum_sitio_",fe_variable_gui,"_",lcc_type_gui))
  db_table_name_estrato = c(DB_SCHEME, paste0("FE_bm_estrato_sitio_",fe_variable_gui,"_",lcc_type_gui))
  if (data@status) {
    success = storeResults(db_table_name_sum, data@result_SummTotBv2)
    success = storeResults(db_table_name_estrato, data@result_BaseEstrato)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

if (DEBUG) {
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","BUR")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","MADMEX")))
  
  
  print(warnings())
  
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
