setwd("/Volumes/SSD2go_tw/conafor/reporting/cliente_general")
source("tools.R")
source("db_access.R")

source("calc_FE.R")
source("calc_changes.R")
source("calc_biomasa_viva.R")
source("calc_error_prop.R")


DEBUG=TRUE

if (DEBUG) {
  inputData = getBaseData_carbono5(BASE_VERSION)
  inputData = getBaseData_dcarbono(calculo_version=BASE_VERSION)
  inputData = getBaseData_biomasa(BASE_VERSION)
  inputData = getBaseData_error_prop()
  
}

writeResults <- function (filename, db_table_name, data) {
  success=FALSE
  success = storeResults(db_table_name, data)
  success = storeResultCSV(paste0(filename,".csv"), data)
  success = storeResultExcel(paste0(filename,".xls"), data)
  return(success)
}


runModule_carbono5 <- function(fe_variable_gui, lcc_type_gui) {
  db_table_name = c(DB_SCHEME, paste0("FE_pot_strata_",fe_variable_gui,"_",lcc_type_gui))
  filename = paste0(OUTPUT_PATH,"/",db_table_name[2])
  
  data=calcFE(fe_variable_gui, lcc_type_gui, inputData)
  if (data@status) {
    success = writeResults(filename, db_table_name, data@result)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}


runModule_dcarbono <- function(fe_variable_gui, lcc_type_gui) {
  data=calcChanges(fe_variable_gui, lcc_type_gui, inputData)
  db_table_name = c(DB_SCHEME, paste0("FE_delta_strata_",fe_variable_gui,"_",lcc_type_gui))
  filename = paste0(OUTPUT_PATH,"/",db_table_name[2])
  
  if (data@status) {
    success = writeResults(filename, db_table_name, data@result)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

runModule_biomasa_viva <- function(fe_variable_gui, lcc_type_gui) {
  data=calcBiomasaViva(fe_variable_gui, lcc_type_gui, inputData)
  success=FALSE
  
  db_table_name_sum = c(DB_SCHEME, paste0("FE_bm_sum_sitio_",fe_variable_gui,"_",lcc_type_gui))
  filename_sum = paste0(OUTPUT_PATH,"/",db_table_name_sum[2])
  
  db_table_name_estrato = c(DB_SCHEME, paste0("FE_bm_estrato_sitio_",fe_variable_gui,"_",lcc_type_gui))
  filename_estrato = paste0(OUTPUT_PATH,"/",db_table_name_estrato[2])
  
  if (data@status) {
    success = writeResults(filename_sum, db_table_name_sum, data@result_SummTotBv2)
    success = writeResults(filename_estrato, db_table_name_estrato, data@result_BaseEstrato)
    
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

runModule_fefa<- function(lcc_type_gui) {
  data=calcErrorProp(lcc_type_gui, inputData)
  
  if (data@status) {
    db_table_name = c(DB_SCHEME,paste0("FEFA_IPCC_abs_s2s3_",lcc_type_gui))
    filename = paste0(OUTPUT_PATH,"/",db_table_name[2])
    success = writeResults(filename, db_table_name, data@TablaEmiAbsS2S3)
    
    success = storeResults(db_table_name, data@TablaEmiAbsS2S3)
    loginfo(success)
    db_table_name = c(DB_SCHEME,paste0("FEFA_IPCC_",lcc_type_gui))
    filename = paste0(OUTPUT_PATH,"/",db_table_name[2])
    success = writeResults(filename, db_table_name, data@TablaFEFA)
    loginfo(success)
    
    db_table_name = c(DB_SCHEME, paste0("FEFA_dinamica_",lcc_type_gui))
    filename = paste0(OUTPUT_PATH,"/",db_table_name[2])
    success = writeResults(filename, db_table_name, data@BaseTransiS2S3)
    loginfo(success)
    
    return(TRUE)
  } else {
    return(FALSE)
  }
  print(success)
  
  return(success)
}

inputData = 0
inputData = getBaseData_carbono5(BASE_VERSION)

if (DEBUG) {
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_arboles","BUR")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_arboles","INEGI")))
  
  
} else  {
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_arboles","BUR")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_arboles","INEGI")))
  
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_raices_por_sitio","MADMEX")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_raices_por_sitio","BUR")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_raices_por_sitio","INEGI")))
  
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_muertospie","MADMEX")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_muertospie","BUR")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_muertospie","INEGI")))
  
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_tocones","MADMEX")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_tocones","BUR")))
  loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_tocones","INEGI")))
}

inputData=0
inputData = getBaseData_dcarbono(calculo_version=BASE_VERSION)
if (DEBUG) {
  #loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_arboles","BUR")))
  
  print(warnings())
  
} else  {
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_arboles","BUR")))
  
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_raices_por_sitio","MADMEX")))
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_raices_por_sitio","BUR")))
  
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_muertospie","MADMEX")))
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_muertospie","BUR")))
  
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_tocones","MADMEX")))
  loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_tocones","BUR")))
  print(warnings())
}

inputData=0
inputData = getBaseData_biomasa(BASE_VERSION)
if (DEBUG) {
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_arboles","BUR")))
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_arboles","MADMEX")))
  
  
  print(warnings())
  
} else {
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_arboles","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_arboles","BUR")))
  #loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_arboles","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_raices_por_sitio","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_raices_por_sitio","BUR")))
  #loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_raices_por_sitio","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_muertospie","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_muertospie","BUR")))
  #loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_muertospie","INEGI")))
  
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_tocones","MADMEX")))
  loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_tocones","BUR")))
  #loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_tocones","INEGI")))
  
}

inputData=0
inputData = getBaseData_error_prop()

if (DEBUG) {
  success = runModule_fefa("BUR")
  success = runModule_fefa("MADMEX")
} else {
  success = runModule_fefa("BUR")
  success = runModule_fefa("MADMEX")
}
print(success)
print(warnings())