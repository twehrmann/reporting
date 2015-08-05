'''
Created on Aug 5, 2015

@author: thilo
'''

ALL = "process all reports"
BASE="base settings"
CARBONO5="carbono5 process"
DCARBONO="dCarbono process"
BIOMASA="carbono por udm process"
RECUPERATION = "recuperation process"
FEFA = "IPCC process"

code = dict()

code[BASE]="""
            setwd("%s")
            source("tools.R")
            source("db_access.R")
            
            source("calc_FE.R")
            source("calc_changes.R")
            source("calc_biomasa_viva.R")
            source("calc_error_prop.R")
            source("calc_recup_refor.R")
            
            DEBUG=%s
        """
code[CARBONO5]="""
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
        """
        
code[BIOMASA]="""
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
        """
        
code[DCARBONO]="""
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
        """

code[RECUPERATION]="""
            inputData=0
            inputData = getBaseData_recuperation(BASE_VERSION)
            
            
            if (DEBUG) {
              for (lcc in lcc.list[2]) {
                loginfo (paste("Status of FE calculation:",runModule_recuperation("carbono_arboles",lcc)))
              } 
              } else {
                for (stock in stock.list[1:2]) {
                  for (lcc in lcc.list[2]) {
                    loginfo (paste("Status of FE calculation:",runModule_recuperation(stock, lcc)))
                  }
                }
              }  
              """
              
code[FEFA]="""
            inputData=0
            inputData = getBaseData_error_prop()
            
            for (lcc in lcc.list[1:2]) {
              success = runModule_fefa(lcc)
            }   
              """

code[ALL] = """
        setwd("%s")
        source("tools.R")
        source("db_access.R")
        
        source("calc_FE.R")
        source("calc_changes.R")
        source("calc_biomasa_viva.R")
        source("calc_error_prop.R")
        source("calc_recup_refor.R")
        
        DEBUG=%s
        
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
        inputData = getBaseData_recuperation(BASE_VERSION)
        
        
        if (DEBUG) {
          for (lcc in lcc.list[2]) {
            loginfo (paste("Status of FE calculation:",runModule_recuperation("carbono_arboles",lcc)))
          } 
          } else {
            for (stock in stock.list[1:2]) {
              for (lcc in lcc.list[2]) {
                loginfo (paste("Status of FE calculation:",runModule_recuperation(stock, lcc)))
              }
            }
          }
        
        
        inputData=0
        inputData = getBaseData_error_prop()
        
        for (lcc in lcc.list[1:2]) {
          success = runModule_fefa(lcc)
        } 


    """
    
testing = """
        setwd("%s")
        source("tools.R")
        source("db_access.R")
        
        source("calc_FE.R")
        source("calc_changes.R")
        source("calc_biomasa_viva.R")
        source("calc_error_prop.R")
        source("calc_recup_refor.R")
        
        DEBUG=%s
        """