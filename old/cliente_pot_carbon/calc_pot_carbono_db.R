setwd("/Volumes/SSD2go_tw/conafor/reporting/cliente_general")
source("tools.R")
source("db_access.R")
source("calc_FE.R")

if(!exists("DEBUG")){
  DEBUG=TRUE
}
FULL = !DEBUG

inputData = getBaseData_carbono5(BASE_VERSION)


runModule <- function(fe_variable_gui, lcc_type_gui) {
  db_table_name = c(DB_SCHEME, paste0("FE_pot_strata_",fe_variable_gui,"_",lcc_type_gui))
  filename = paste0(OUTPUT_PATH,"/",db_table_name[2])
  
  data=calcFE(fe_variable_gui, lcc_type_gui, inputData)
  if (data@status) {
    success = storeResults(db_table_name, data@result)
    success = storeResultCSV(paste0(filename,".csv"), data@result)
    success = storeResultExcel(paste0(filename,".xls"), data@result)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

if (DEBUG) {
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","BUR")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","INEGI")))
  
  
} else if (FULL) {
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","BUR")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_arboles","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_raices_por_sitio","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_raices_por_sitio","BUR")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_raices_por_sitio","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_muertospie","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_muertospie","BUR")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_muertospie","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule("carbono_tocones","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_tocones","BUR")))
  loginfo (paste("Status of FE calculation:",runModule("carbono_tocones","INEGI")))
  
}