setwd("/Volumes/SSD2go_tw/conafor/reporting/cliente_general")
source("tools.R")
source("db_access.R")

source("calc_FE.R")
source("calc_changes.R")
source("calc_biomasa_viva.R")
source("calc_error_prop.R")
source("calc_recup_refor.R")

DEBUG=FALSE

if (DEBUG) {
  inputData = getBaseData_carbono5(BASE_VERSION)
  inputData = getBaseData_dcarbono(calculo_version=BASE_VERSION)
  inputData = getBaseData_biomasa(BASE_VERSION)
  inputData = getBaseData_error_prop()
  inputData = getBaseData_recuperation(BASE_VERSION)
}

inputData = 0
inputData = getBaseData_carbono5(BASE_VERSION)

if (DEBUG) {
  for (lcc in lcc.list) {
    loginfo (paste("Status of FE pot. calculation:",runModule_carbono5("carbono_arboles",lcc)))
  }
} else  {
  for (stock in stock.list) {
    for (lcc in lcc.list) {
      loginfo (paste("Status of FE pot. calculation:",runModule_carbono5(stock,lcc)))
    }
  }
}

inputData=0
inputData = getBaseData_dcarbono(calculo_version=BASE_VERSION)
if (DEBUG) {
  for (lcc in lcc.list) {
    loginfo (paste("Status of FE delta calculation:",runModule_dcarbono("carbono_arboles",lcc)))
  }
  logwarn(warnings())
} else  {
  for (stock in stock.list) {
    for (lcc in lcc.list) {
      loginfo (paste("Status of FE delta calculation:",runModule_dcarbono(stock,lcc)))
    }
  }
  logwarn(warnings())
}

inputData=0
inputData = getBaseData_biomasa(BASE_VERSION)
if (DEBUG) {
  for (lcc in lcc.list) {
    loginfo (paste("Status of FE calculation:",runModule_biomasa_viva("carbono_arboles",lcc)))
  }
  logwarn(warnings())
} else {
  for (stock in stock.list) {
    for (lcc in lcc.list) {
      loginfo (paste("Status of FE calculation:",runModule_biomasa_viva(stock, lcc)))
    }
  }
}

inputData=0
inputData = getBaseData_recuperation(20)


if (DEBUG) {
  for (lcc in lcc.list) {
    loginfo (paste("Status of FE calculation:",runModule_recuperation("carbono_arboles",lcc)))
  } 
  } else if (FULL) {
    for (stock in stock.list[4]) {
      for (lcc in lcc.list[2]) {
        loginfo (paste("Status of FE calculation:",runModule_recuperation(stock, lcc)))
      }
    }
  }


inputData=0
inputData = getBaseData_error_prop()

for (lcc in lcc.list) {
  success = runModule_fefa(lcc)
} 

loginfo(success)
logwarn(warnings())