
###############################################################################
######################Se cargan las linrer?as necesarias#######################
###############################################################################

library(doBy)
library(ggplot2)
library(grid)
library(gridExtra)


runModule_recuperation <- function(fe_variable_gui, lcc_type_gui) {
  data=calcRecup_refor(fe_variable_gui, lcc_type_gui, inputData)
  success=FALSE
  
  if (data@status) {
    db_table_name = tolower(c(DB_SCHEME, paste0("FE_rec_strata_",fe_variable_gui,"_",lcc_type_gui)))
    filename = tolower(paste0(OUTPUT_PATH,"/",db_table_name[2]))
    success = writeResults(filename, db_table_name, data@result)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}


fe_variable_gui = "carbono_arboles"
lcc_type_gui="BUR"

calcRecup_refor <- function(fe_variable_gui, lcc_type_gui, inputData) {
  loginfo("Calculando reforestacion / recuperacion por estrato...")
  loginfo(paste("GUI setting: ", fe_variable_gui, "/",lcc_type_gui))
  
  BaseT1<-inputData@BaseT1
  BaseT2<-inputData@BaseT2
  FE_VAR = fe_variable_gui
  
  if (lcc_type_gui == "BUR") {
    AreasEstratos<-inputData@AreasEstratos_BUR
    EstratoCongT1<-inputData@EstratoCongT1_BUR
    EstratoCongT2<-inputData@EstratoCongT2_BUR
    EstratosIPCC<-inputData@EstratosIPCC_BUR
    
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO_KEY = "cve4_pmn"
    
  } else if (lcc_type_gui == "MADMEX") {
    AreasEstratos<-inputData@AreasEstratos_MADMEX
    EstratoCongT1<-inputData@EstratoCongT1_MADMEX
    EstratoCongT1$NUMNAL = EstratoCongT1$numnal
    EstratoCongT2<-inputData@EstratoCongT2_MADMEX
    EstratoCongT2$NUMNAL = EstratoCongT2$numnal
    
    EstratosIPCC<-inputData@EstratosIPCC_MADMEX
    
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO_KEY = "madmex_05"
    
  }
  
  
  ###############################################################################
  ####Se identifica la clase a la que pertenece cada estrato del INEGEI e IPCC###
  #Se identifica el tipo de estrato PMN 4 por conglomerado en T1
  length(BaseT1$folio)
  BaseT1<- merge(BaseT1, EstratoCongT1, by.x = "folio", by.y = "NUMNAL",all=TRUE)
  #Se identifica el tipo de estrato IPCC por conglomerado en T1
  BaseT1<- merge(BaseT1, EstratosIPCC, by.x = ESTRATO_KEY, by.y = "pf_redd_clave_subcat_leno_pri_sec",all=TRUE)
  length(BaseT1$folio)
  
  #Se identifica el tipo de estrato PMN 5 por conglomerado en T2
  BaseT2<- merge(BaseT2, EstratoCongT2, by.x = "folio", by.y = "NUMNAL",all=TRUE)
  length(BaseT2$folio)
  
  ###############################################################################
  #Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera"
  BaseT1$CarbAerVivT1<-ifelse(BaseT1$tipificacion=="Monitoreo" & BaseT1$pf_redd_ipcc_2003=="Praderas",0,
                              as.numeric(as.character(BaseT1[,fe_variable_gui])))
  BaseT2$CarbAerVivT2<-as.numeric(as.character(BaseT2[,fe_variable_gui]))
  
  ###############################################################################
  ##############################Se unen las bases T1 y T2"#######################
  Bt2t1<- merge(BaseT1, BaseT2, by.x = "folio", by.y = "folio",all=TRUE)
  length(Bt2t1$folio)
  #Se filtran los casos en lo que anexaron clases del IPCC no representadas
  Bt2t1<-Bt2t1[!(is.na(Bt2t1$folio)),]
  length(Bt2t1$folio)
  
  ###############################################################################
  #Se imputan 0?s en el carbono T2 de aquellos conglomerdos en T1 tipificados "Monitoreo"
  # y que ten?an "Pradera" y que en T2 tienen una tipificaci?n "Omitido-Remuestreo"
  Bt2t1$CarbAerVivT2correg<-ifelse(Bt2t1$tipificacion.x=="Monitoreo" & Bt2t1$pf_redd_ipcc_2003=="Praderas"&
                                     Bt2t1$tipificacion.y=="Omitido-Remuestreo",0,Bt2t1$CarbAerVivT2)
  
  ###############################################################################
  ####Se filtran los estratos de T1 que no pertenencen a las categor?as de "Tierras####
  ######################## Forestales" o "Praderas" del IPCC#####################
  Bt2t1=Bt2t1[Bt2t1$pf_redd_ipcc_2003=="Tierras Forestales" | Bt2t1$pf_redd_ipcc_2003=="Praderas",]
  length(Bt2t1$folio)
  
  #se filtra todas las UMP cuya "tipificaci?n" es "Inicial", "Reemplazo" o "Monitoreo" en T1
  Bt2t1=Bt2t1[Bt2t1$tipificacion.x=="Inicial" |
                Bt2t1$tipificacion.x=="Reemplazo" |
                Bt2t1$tipificacion.x=="Monitoreo",]
  length(Bt2t1$folio)
  
  #se filtra todas las USM cuya "tipificaci?n" es "Inicial", "Reemplazo" o "Omitido-Remuestreo" en T2
  Bt2t1=Bt2t1[Bt2t1$tipificacion.y=="Inicial" |
                Bt2t1$tipificacion.y=="Reemplazo" |
                Bt2t1$tipificacion.y=="Omitido-Remuestreo" & Bt2t1$tipificacion.x=="Monitoreo" & Bt2t1$pf_redd_ipcc_2003=="Praderas",]
  length(Bt2t1$folio)
  
  #Se filtran todos los "NA" de la variable "CarbAerViv" en T1
  Bt2t1<-Bt2t1[!(is.na(Bt2t1$CarbAerVivT1)),]
  length(Bt2t1$folio)
  #Se filtran todos los "NA" de la variable "CarbAerVivT2correg" en T2
  Bt2t1<-Bt2t1[!(is.na(Bt2t1$CarbAerVivT2correg)),]
  length(Bt2t1$folio)
  
  write.csv(Bt2t1, file = "Bt2t1.csv")
  
  ###############################################################################
  #Se concatenan los nombres abreviados de los estratos en t1  y t2
  Bt2t1$EstTrnsT1T2<-paste(as.character(Bt2t1$cve4_pmn),"-",as.character(Bt2t1$cve5_pmn))
  
  #se filtra todas las USP que permanecieron en el mismo estrato entre T1 y T2
  Bt2t1=Bt2t1[
    Bt2t1$EstTrnsT1T2=="ACUI - ACUI"  |
      Bt2t1$EstTrnsT1T2=="AGR - AGR"  |
      Bt2t1$EstTrnsT1T2=="AH - AH"  |
      Bt2t1$EstTrnsT1T2=="BC - BC"  |
      Bt2t1$EstTrnsT1T2=="BCO/P - BCO/P"  |
      Bt2t1$EstTrnsT1T2=="BCO/S - BCO/S"  |
      Bt2t1$EstTrnsT1T2=="BE/P - BE/P"  |
      Bt2t1$EstTrnsT1T2=="BE/S - BE/S"  |
      Bt2t1$EstTrnsT1T2=="BM/P - BM/P"  |
      Bt2t1$EstTrnsT1T2=="BM/S - BM/S"  |
      Bt2t1$EstTrnsT1T2=="EOTL/P - EOTL/P"  |
      Bt2t1$EstTrnsT1T2=="EOTL/S - EOTL/S"  |
      Bt2t1$EstTrnsT1T2=="EOTnL/P - EOTnL/P"  |
      Bt2t1$EstTrnsT1T2=="H2O - H2O"  |
      Bt2t1$EstTrnsT1T2=="MXL/P - MXL/P"  |
      Bt2t1$EstTrnsT1T2=="MXL/S - MXL/S"  |
      Bt2t1$EstTrnsT1T2=="MXnL/P - MXnL/P"  |
      Bt2t1$EstTrnsT1T2=="MXnL/S - MXnL/S"  |
      Bt2t1$EstTrnsT1T2=="OT - OT"  |
      Bt2t1$EstTrnsT1T2=="P - P"  |
      Bt2t1$EstTrnsT1T2=="SC/P - SC/P"  |
      Bt2t1$EstTrnsT1T2=="SC/S - SC/S"  |
      Bt2t1$EstTrnsT1T2=="SP/P - SP/P"  |
      Bt2t1$EstTrnsT1T2=="SP/S - SP/S"  |
      Bt2t1$EstTrnsT1T2=="SSC/P - SSC/P"  |
      Bt2t1$EstTrnsT1T2=="SSC/S - SSC/S"  |
      Bt2t1$EstTrnsT1T2=="VHL/P - VHL/P"  |
      Bt2t1$EstTrnsT1T2=="VHL/S - VHL/S"  |
      Bt2t1$EstTrnsT1T2=="VHnL/P - VHnL/P",]
  length(Bt2t1$folio)
  
  #Se anualiza la variable cambio de carbono
  #Se crea la variable decimal de fecha en t1
  Bt2t1$FechaDecimalT1<-(as.numeric(substr(x = Bt2t1$levantamiento_fecha_ejecucion.x, start = 1, stop = 2))+
                           as.numeric(substr(x = Bt2t1$levantamiento_fecha_ejecucion.x, start = 4, stop = 5))*30)/365+
    as.numeric(substr(x = Bt2t1$levantamiento_fecha_ejecucion.x, start = 7, stop = 10))
  Bt2t1$FechaDecimalT2<-(as.numeric(substr(x = Bt2t1$levantamiento_fecha_ejecucion.y, start = 1, stop = 2))+
                           as.numeric(substr(x = Bt2t1$levantamiento_fecha_ejecucion.y, start = 4, stop = 5))*30)/365+
    as.numeric(substr(x = Bt2t1$levantamiento_fecha_ejecucion.y, start = 7, stop = 10))
  Bt2t1$DifTiempoT2T1p<-(Bt2t1$FechaDecimalT2-Bt2t1$FechaDecimalT1)
  #Se imputa una diferencia de medic?n de 5 a?os en las UMP de "Monitoreo"
  Bt2t1$NA_FechaDecimalT1<-ifelse(is.na(Bt2t1$DifTiempoT2T1), 1,0)
  Bt2t1$DifTiempoT2T1<-ifelse(Bt2t1$NA_FechaDecimalT1==1,5,Bt2t1$DifTiempoT2T1p)
  
  #Se crea la variable de cambio de carbono/HA/a?o######################################
  #Se estima el carbono en ton/ha en T1
  Bt2t1$NumSitiosPT1p<-as.numeric(as.character(Bt2t1$total_sitios.x))
  Bt2t1$NA_NumSitiosPT1<-ifelse(is.na(Bt2t1$NumSitiosPT1p), 1,0)
  Bt2t1$NumSitiosPT1<-ifelse(Bt2t1$NA_NumSitiosPT1==1,4,Bt2t1$NumSitiosPT1p)
  CarbAereoSitPT1<-as.numeric(as.character(Bt2t1$CarbAerVivT1))
  Bt2t1$CarbAereoHaT1<-CarbAereoSitPT1*(1/(Bt2t1$NumSitiosPT1*0.04))
  #Se estima el carbono en ton/ha en T2
  Bt2t1$NumSitiosPT2p<-as.numeric(as.character(Bt2t1$total_sitios.y))
  Bt2t1$NA_NumSitiosPT2<-ifelse(is.na(Bt2t1$NumSitiosPT2), 1,0)
  Bt2t1$NumSitiosPT2<-ifelse(Bt2t1$NA_NumSitiosPT2==1,4,Bt2t1$NumSitiosPT2p)
  CarbAereoSitPT2<-as.numeric(as.character(Bt2t1$CarbAerVivT2correg))
  Bt2t1$CarbAereoHaT2<-CarbAereoSitPT2*(1/(Bt2t1$NumSitiosPT2*0.04))
  #Se calcula el cambio de carbono bruto entre T2 t T1
  Bt2t1$CCHa<-Bt2t1$CarbAereoHaT2-Bt2t1$CarbAereoHaT1
  #Se anualiza el cambio de carbono entre T2-T1
  Bt2t1$CCanualizadoHa<-Bt2t1$CCHa/Bt2t1$DifTiempoT2T1
  length(Bt2t1$folio)
  
  #*****************************************************************************#
  #A)FACTORES DE ABSORCI?N-ZONAS DE GANANCIA#################################
  
  #Se crea una base en la que se filtran los cambios positivos 
  Bt2t1Pos=Bt2t1[Bt2t1$CCanualizadoHa>0,]
  length(Bt2t1Pos$folio)
  write.csv(Bt2t1Pos, file = "Bt2t1Pos.csv")
  #Se filtran todos los incrementos positivos mayores al 20%
  #Se calculan los porcentajes de incremento de carabono con respecto a T1
  Bt2t1Pos$PropInc<-(Bt2t1Pos$CCanualizado/Bt2t1Pos$CarbAereoHaT1)*100
  Bt2t1Pos=Bt2t1Pos[Bt2t1Pos$PropInc!="Inf",]
  length(Bt2t1Pos$folio)
  Bt2t1Pos=Bt2t1Pos[Bt2t1Pos$PropInc<=20,]
  length(Bt2t1Pos$folio)
  
  #Bt2t1Pos=Bt2t1
  
  #Se crea una variable para identificar rangos tiempos de remedici?n
  Bt2t1Pos$TiempoRem<-
    ifelse(Bt2t1Pos$DifTiempoT2T1>0 & Bt2t1Pos$DifTiempoT2T1<=1,"Rem0",
           ifelse(Bt2t1Pos$DifTiempoT2T1>1 & Bt2t1Pos$DifTiempoT2T1<=2,"Rem1",
                  ifelse(Bt2t1Pos$DifTiempoT2T1>2 & Bt2t1Pos$DifTiempoT2T1<=3,"Rem2",
                         ifelse(Bt2t1Pos$DifTiempoT2T1>3 & Bt2t1Pos$DifTiempoT2T1<=4,"Rem3",
                                ifelse(Bt2t1Pos$DifTiempoT2T1>4 & Bt2t1Pos$DifTiempoT2T1<=5,"Rem4",
                                       ifelse(Bt2t1Pos$DifTiempoT2T1>5 & Bt2t1Pos$DifTiempoT2T1<=6,"Rem5",
                                              ifelse(Bt2t1Pos$DifTiempoT2T1>6 & Bt2t1Pos$DifTiempoT2T1<=7,"Rem6",
                                                     ifelse(Bt2t1Pos$DifTiempoT2T1>7 & Bt2t1Pos$DifTiempoT2T1<=8,"Rem7",
                                                            ifelse(Bt2t1Pos$DifTiempoT2T1>8 & Bt2t1Pos$DifTiempoT2T1<=9,"Rem8",
                                                                   ifelse(Bt2t1Pos$DifTiempoT2T1>9 & Bt2t1Pos$DifTiempoT2T1<=10,"Rem9","NoSe"
                                                                   ))))))))))
  length(Bt2t1Pos$folio)
  
  write.csv(Bt2t1Pos, file = "Bt2t1Pos.csv")
  
  #Se crea un estrato "EstratoInegei"-"Tiempo de remedici?n"
  Bt2t1Pos$EstTrnsT1T2tiemRem<-paste(Bt2t1Pos$EstTrnsT1T2,"--",Bt2t1Pos$TiempoRem)
  
  #Estad?sticas descriptivas de TODOS los cambios en los almacenes###############
  #myfun1 <- function(x){c(Num=length(x[!is.na(x)]),Min=min(x[!is.na(x)]),Max=max(x[!is.na(x)]),Prom=mean(x[!is.na(x)]), Sd=sd(x), q=quantile(x[!is.na(x)],0.025), mediana=quantile(x[!is.na(x)],0.5), qqq=quantile(x[!is.na(x)],0.975))}
  #SummaryT2T1timeRem<-0
  #SummaryT2T1timeRem<-summaryBy(Bt2t1Pos$CCHa ~ Bt2t1Pos$EstTrnsT1T2tiemRem,data=Bt2t1Pos,FUN=myfun1 )
  #write.csv(SummaryT2T1timeRem, file = "PromCCaTimeRem.csv")
  
  ################################################################################
  #Se las gr?ficas de los incrementos brutos de carbono por periodo de remedici?n#
  ################################################################################
  
  ###Se crea las bases (de las parcelas con los incrementos burtos) de cada uno###
  ################################ de los estratos################################
  if (lcc_type_gui == "BUR") {
    Bt2t1PosBC=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BC - BC",]
    Bt2t1PosBCO_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BCO/P - BCO/P",]
    Bt2t1PosBCO_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BCO/S - BCO/S",]
    Bt2t1PosBE_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BE/P - BE/P",]
    Bt2t1PosBE_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BE/S - BE/S",]
    Bt2t1PosBM_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BM/P - BM/P",]
    Bt2t1PosBM_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BM/S - BM/S",]
    Bt2t1PosEOTL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="EOTL/P - EOTL/P",]
    Bt2t1PosEOTL_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="EOTL/S - EOTL/S",]
    Bt2t1PosEOTnL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="EOTnL/P - EOTnL/P",]
    Bt2t1PosMXL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MXL/P - MXL/P",]
    Bt2t1PosMXL_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MXL/S - MXL/S",]
    Bt2t1PosMXnL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MXnL/P - MXnL/P",]
    Bt2t1PosMXnL_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MXnL/S - MXnL/S",]
    Bt2t1PosP=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="P - P",]
    Bt2t1PosSC_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SC/P - SC/P",]
    Bt2t1PosSC_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SC/S - SC/S",]
    Bt2t1PosSP_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP/P - SP/P",]
    Bt2t1PosSP_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP/S - SP/S",]
    Bt2t1PosSSC_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SSC/P - SSC/P",]
    Bt2t1PosSSC_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SSC/S - SSC/S",]
    Bt2t1PosVHL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="VHL/P - VHL/P",]
    Bt2t1PosVHL_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="VHL/S - VHL/S",]
    Bt2t1PosVHnL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="VHnL/P - VHnL/P",]
    
    #Se corren las regresiones lienales simples para cada estrato###################
    lmBC<-lm(Bt2t1PosBC$CCHa ~ Bt2t1PosBC$DifTiempoT2T1 +0)
    lmBCOp<-lm(Bt2t1PosBCO_P$CCHa ~ Bt2t1PosBCO_P$DifTiempoT2T1 +0)
    lmBCOs<-lm(Bt2t1PosBCO_S$CCHa ~ Bt2t1PosBCO_S$DifTiempoT2T1 +0)
    lmBEp<-lm(Bt2t1PosBE_P$CCHa ~ Bt2t1PosBE_P$DifTiempoT2T1 +0)
    lmBEs<-lm(Bt2t1PosBE_S$CCHa ~ Bt2t1PosBE_S$DifTiempoT2T1 +0)
    lmBMp<-lm(Bt2t1PosBM_P$CCHa ~ Bt2t1PosBM_P$DifTiempoT2T1 +0)
    lmBMs<-lm(Bt2t1PosBM_S$CCHa ~ Bt2t1PosBM_S$DifTiempoT2T1 +0)
    lmEOTLp<-lm(Bt2t1PosEOTL_P$CCHa ~ Bt2t1PosEOTL_P$DifTiempoT2T1 +0)
    lmEOTLs<-lm(Bt2t1PosEOTL_S$CCHa ~ Bt2t1PosEOTL_S$DifTiempoT2T1 +0)
    #lmEOTnp<-lm(Bt2t1PosEOTnL_P$CCHa ~ Bt2t1PosEOTnL_P$DifTiempoT2T1 +0)
    lmMXLp<-lm(Bt2t1PosMXL_P$CCHa ~ Bt2t1PosMXL_P$DifTiempoT2T1 +0)
    lmMXLs<-lm(Bt2t1PosMXL_S$CCHa ~ Bt2t1PosMXL_S$DifTiempoT2T1 +0)
    lmMXnLp<-lm(Bt2t1PosMXnL_P$CCHa ~ Bt2t1PosMXnL_P$DifTiempoT2T1 +0)
    lmMXnLs<-lm(Bt2t1PosMXnL_S$CCHa ~ Bt2t1PosMXnL_S$DifTiempoT2T1 +0)
    lmP<-lm(Bt2t1PosP$CCHa ~ Bt2t1PosP$DifTiempoT2T1 +0)
    lmSCp<-lm(Bt2t1PosSC_P$CCHa ~ Bt2t1PosSC_P$DifTiempoT2T1 +0)
    lmSCs<-lm(Bt2t1PosSC_S$CCHa ~ Bt2t1PosSC_S$DifTiempoT2T1 +0)
    lmSPp<-lm(Bt2t1PosSP_P$CCHa ~ Bt2t1PosSP_P$DifTiempoT2T1 +0)
    lmSPs<-lm(Bt2t1PosSP_S$CCHa ~ Bt2t1PosSP_S$DifTiempoT2T1 +0)
    lmSSCp<-lm(Bt2t1PosSSC_P$CCHa ~ Bt2t1PosSSC_P$DifTiempoT2T1 +0)
    lmSSCs<-lm(Bt2t1PosSSC_S$CCHa ~ Bt2t1PosSSC_S$DifTiempoT2T1 +0)
    lmVHLp<-lm(Bt2t1PosVHL_P$CCHa ~ Bt2t1PosVHL_P$DifTiempoT2T1 +0)
    lmVHLs<-lm(Bt2t1PosVHL_S$CCHa ~ Bt2t1PosVHL_S$DifTiempoT2T1 +0)
    lmVHnLp<-lm(Bt2t1PosVHnL_P$CCHa ~ Bt2t1PosVHnL_P$DifTiempoT2T1 +0)
    
    ################################################################################
    #Se estiman los predictores y los IC 
    lmBCIC<-as.data.frame(predict.lm(lmBC,interval="prediction"))
    lmBCOpIC<-as.data.frame(predict.lm(lmBCOp,interval="prediction"))
    lmBCOsIC<-as.data.frame(predict.lm(lmBCOs,interval="prediction"))
    lmBEpIC<-as.data.frame(predict.lm(lmBEp,interval="prediction"))
    lmBEsIC<-as.data.frame(predict.lm(lmBEs,interval="prediction"))
    lmBMpIC<-as.data.frame(predict.lm(lmBMp,interval="prediction"))
    lmBMsIC<-as.data.frame(predict.lm(lmBMs,interval="prediction"))
    lmEOTLpIC<-as.data.frame(predict.lm(lmEOTLp,interval="prediction"))
    lmEOTLsIC<-as.data.frame(predict.lm(lmEOTLs,interval="prediction"))
    #lmEOTnpIC<-as.data.frame(predict.lm(lmEOTnp,interval="prediction"))
    lmMXLpIC<-as.data.frame(predict.lm(lmMXLp,interval="prediction"))
    lmMXLsIC<-as.data.frame(predict.lm(lmMXLs,interval="prediction"))
    lmMXnLpIC<-as.data.frame(predict.lm(lmMXnLp,interval="prediction"))
    lmMXnLsIC<-as.data.frame(predict.lm(lmMXnLs,interval="prediction"))
    lmPIC<-as.data.frame(predict.lm(lmP,interval="prediction"))
    lmSCpIC<-as.data.frame(predict.lm(lmSCp,interval="prediction"))
    lmSCsIC<-as.data.frame(predict.lm(lmSCs,interval="prediction"))
    lmSPpIC<-as.data.frame(predict.lm(lmSPp,interval="prediction"))
    lmSPsIC<-as.data.frame(predict.lm(lmSPs,interval="prediction"))
    lmSSCpIC<-as.data.frame(predict.lm(lmSSCp,interval="prediction"))
    lmSSCsIC<-as.data.frame(predict.lm(lmSSCs,interval="prediction"))
    lmVHLpIC<-as.data.frame(predict.lm(lmVHLp,interval="prediction"))
    lmVHLsIC<-as.data.frame(predict.lm(lmVHLs,interval="prediction"))
    lmVHnLpIC<-as.data.frame(predict.lm(lmVHnLp,interval="prediction"))
    
    ################################################################################
    #Se identifican los par?metros de los modelos estiman las incertidumbres de predicci?n 
    
    numero<-rep(0,23)
    ParamModel<-data.frame(numero)
    ###Estrato
    ParamModel$Estrato[1]<- "BC"
    ParamModel$Estrato[2]<- "BCOp"
    ParamModel$Estrato[3]<- "BCOs"
    ParamModel$Estrato[4]<- "BEp"
    ParamModel$Estrato[5]<- "BEs"
    ParamModel$Estrato[6]<- "BMp"
    ParamModel$Estrato[7]<- "BMs"
    ParamModel$Estrato[8]<- "EOTLp"
    ParamModel$Estrato[9]<- "EOTLs"
    #ParamModel$Estrato[]<- "EOTnp"
    ParamModel$Estrato[10]<- "MXLp"
    ParamModel$Estrato[11]<- "MXLs"
    ParamModel$Estrato[12]<- "MXnLp"
    ParamModel$Estrato[13]<- "MXnLs"
    ParamModel$Estrato[14]<- "P"
    ParamModel$Estrato[15]<- "SCp"
    ParamModel$Estrato[16]<- "SCs"
    ParamModel$Estrato[17]<- "SPp"
    ParamModel$Estrato[18]<- "SPs"
    ParamModel$Estrato[19]<- "SSCp"
    ParamModel$Estrato[20]<- "SSCs"
    ParamModel$Estrato[21]<- "VHLp"
    ParamModel$Estrato[22]<- "VHLs"
    ParamModel$Estrato[23]<- "VHnLp"
    ###par?metro del modelo
    ParamModel$parametro[1]<-as.numeric(lmBC[[1]])
    ParamModel$parametro[2]<-as.numeric(lmBCOp[[1]])
    ParamModel$parametro[3]<-as.numeric(lmBCOs[[1]])
    ParamModel$parametro[4]<-as.numeric(lmBEp[[1]])
    ParamModel$parametro[5]<-as.numeric(lmBEs[[1]])
    ParamModel$parametro[6]<-as.numeric(lmBMp[[1]])
    ParamModel$parametro[7]<-as.numeric(lmBMs[[1]])
    ParamModel$parametro[8]<-as.numeric(lmEOTLp[[1]])
    ParamModel$parametro[9]<-as.numeric(lmEOTLs[[1]])
    #ParamModel$parametro[10]<-as.numeric(lmEOTnp[[1]])
    ParamModel$parametro[10]<-as.numeric(lmMXLp[[1]])
    ParamModel$parametro[11]<-as.numeric(lmMXLs[[1]])
    ParamModel$parametro[12]<-as.numeric(lmMXnLp[[1]])
    ParamModel$parametro[13]<-as.numeric(lmMXnLs[[1]])
    ParamModel$parametro[14]<-as.numeric(lmP[[1]])
    ParamModel$parametro[15]<-as.numeric(lmSCp[[1]])
    ParamModel$parametro[16]<-as.numeric(lmSCs[[1]])
    ParamModel$parametro[17]<-as.numeric(lmSPp[[1]])
    ParamModel$parametro[18]<-as.numeric(lmSPs[[1]])
    ParamModel$parametro[19]<-as.numeric(lmSSCp[[1]])
    ParamModel$parametro[20]<-as.numeric(lmSSCs[[1]])
    ParamModel$parametro[21]<-as.numeric(lmVHLp[[1]])
    ParamModel$parametro[22]<-as.numeric(lmVHLs[[1]])
    ParamModel$parametro[23]<-as.numeric(lmVHnLp[[1]])
    ###Incertidumbre inferior
    ParamModel$Ulwr[1] <- mean((lmBCIC$lwr-lmBCIC$fit)/lmBCIC$fit)*100
    ParamModel$Ulwr[2] <- mean((lmBCOpIC$lwr-lmBCOpIC$fit)/lmBCOpIC$fit)*100
    ParamModel$Ulwr[3] <- mean((lmBCOsIC$lwr-lmBCOsIC$fit)/lmBCOsIC$fit)*100
    ParamModel$Ulwr[4] <- mean((lmBEpIC$lwr-lmBEpIC$fit)/lmBEpIC$fit)*100
    ParamModel$Ulwr[5] <- mean((lmBEsIC$lwr-lmBEsIC$fit)/lmBEsIC$fit)*100
    ParamModel$Ulwr[6] <- mean((lmBMpIC$lwr-lmBMpIC$fit)/lmBMpIC$fit)*100
    ParamModel$Ulwr[7] <- mean((lmBMsIC$lwr-lmBMsIC$fit)/lmBMsIC$fit)*100
    ParamModel$Ulwr[8] <- mean((lmEOTLpIC$lwr-lmEOTLpIC$fit)/lmEOTLpIC$fit)*100
    ParamModel$Ulwr[9] <- mean((lmEOTLsIC$lwr-lmEOTLsIC$fit)/lmEOTLsIC$fit)*100
    #ParamModel$Ulwr[] <- mean((lmEOTnpIC$lwr-lmEOTnpIC$fit)/lmEOTnpIC$fit)*100
    ParamModel$Ulwr[10] <- mean((lmMXLpIC$lwr-lmMXLpIC$fit)/lmMXLpIC$fit)*100
    ParamModel$Ulwr[11] <- mean((lmMXLsIC$lwr-lmMXLsIC$fit)/lmMXLsIC$fit)*100
    ParamModel$Ulwr[12] <- mean((lmMXnLpIC$lwr-lmMXnLpIC$fit)/lmMXnLpIC$fit)*100
    ParamModel$Ulwr[13] <- mean((lmMXnLsIC$lwr-lmMXnLsIC$fit)/lmMXnLsIC$fit)*100
    ParamModel$Ulwr[14] <- mean((lmPIC$lwr-lmPIC$fit)/lmPIC$fit)*100
    ParamModel$Ulwr[15] <- mean((lmSCpIC$lwr-lmSCpIC$fit)/lmSCpIC$fit)*100
    ParamModel$Ulwr[16] <- mean((lmSCsIC$lwr-lmSCsIC$fit)/lmSCsIC$fit)*100
    ParamModel$Ulwr[17] <- mean((lmSPpIC$lwr-lmSPpIC$fit)/lmSPpIC$fit)*100
    ParamModel$Ulwr[18] <- mean((lmSPsIC$lwr-lmSPsIC$fit)/lmSPsIC$fit)*100
    ParamModel$Ulwr[19] <- mean((lmSSCpIC$lwr-lmSSCpIC$fit)/lmSSCpIC$fit)*100
    ParamModel$Ulwr[20] <- mean((lmSSCsIC$lwr-lmSSCsIC$fit)/lmSSCsIC$fit)*100
    ParamModel$Ulwr[21] <- mean((lmVHLpIC$lwr-lmVHLpIC$fit)/lmVHLpIC$fit)*100
    ParamModel$Ulwr[22] <- mean((lmVHLsIC$lwr-lmVHLsIC$fit)/lmVHLsIC$fit)*100
    ParamModel$Ulwr[23] <- mean((lmVHnLpIC$lwr-lmVHnLpIC$fit)/lmVHnLpIC$fit)*100
    ###Incertidumbre Superior
    ParamModel$Uupr[1] <- mean((lmBCIC$upr-lmBCIC$fit)/lmBCIC$fit)*100
    ParamModel$Uupr[2] <- mean((lmBCOpIC$upr-lmBCOpIC$fit)/lmBCOpIC$fit)*100
    ParamModel$Uupr[3] <- mean((lmBCOsIC$upr-lmBCOsIC$fit)/lmBCOsIC$fit)*100
    ParamModel$Uupr[4] <- mean((lmBEpIC$upr-lmBEpIC$fit)/lmBEpIC$fit)*100
    ParamModel$Uupr[5] <- mean((lmBEsIC$upr-lmBEsIC$fit)/lmBEsIC$fit)*100
    ParamModel$Uupr[6] <- mean((lmBMpIC$upr-lmBMpIC$fit)/lmBMpIC$fit)*100
    ParamModel$Uupr[7] <- mean((lmBMsIC$upr-lmBMsIC$fit)/lmBMsIC$fit)*100
    ParamModel$Uupr[8] <- mean((lmEOTLpIC$upr-lmEOTLpIC$fit)/lmEOTLpIC$fit)*100
    ParamModel$Uupr[9] <- mean((lmEOTLsIC$upr-lmEOTLsIC$fit)/lmEOTLsIC$fit)*100
    #ParamModel$Uupr[] <- mean((lmEOTnpIC$upr-lmEOTnpIC$fit)/lmEOTnpIC$fit)*100
    ParamModel$Uupr[10] <- mean((lmMXLpIC$upr-lmMXLpIC$fit)/lmMXLpIC$fit)*100
    ParamModel$Uupr[11] <- mean((lmMXLsIC$upr-lmMXLsIC$fit)/lmMXLsIC$fit)*100
    ParamModel$Uupr[12] <- mean((lmMXnLpIC$upr-lmMXnLpIC$fit)/lmMXnLpIC$fit)*100
    ParamModel$Uupr[13] <- mean((lmMXnLsIC$upr-lmMXnLsIC$fit)/lmMXnLsIC$fit)*100
    ParamModel$Uupr[14] <- mean((lmPIC$upr-lmPIC$fit)/lmPIC$fit)*100
    ParamModel$Uupr[15] <- mean((lmSCpIC$upr-lmSCpIC$fit)/lmSCpIC$fit)*100
    ParamModel$Uupr[16] <- mean((lmSCsIC$upr-lmSCsIC$fit)/lmSCsIC$fit)*100
    ParamModel$Uupr[17] <- mean((lmSPpIC$upr-lmSPpIC$fit)/lmSPpIC$fit)*100
    ParamModel$Uupr[18] <- mean((lmSPsIC$upr-lmSPsIC$fit)/lmSPsIC$fit)*100
    ParamModel$Uupr[19] <- mean((lmSSCpIC$upr-lmSSCpIC$fit)/lmSSCpIC$fit)*100
    ParamModel$Uupr[20] <- mean((lmSSCsIC$upr-lmSSCsIC$fit)/lmSSCsIC$fit)*100
    ParamModel$Uupr[21] <- mean((lmVHLpIC$upr-lmVHLpIC$fit)/lmVHLpIC$fit)*100
    ParamModel$Uupr[22] <- mean((lmVHLsIC$upr-lmVHLsIC$fit)/lmVHLsIC$fit)*100
    ParamModel$Uupr[23] <- mean((lmVHnLpIC$upr-lmVHnLpIC$fit)/lmVHnLpIC$fit)*100
    
  } else if (lcc_type_gui == "MADMEX" | lcc_type_gui == "INEGI") {
    Bt2t1PosAGRI=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="AGRI - AGRI",]
    Bt2t1PosAH=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="AH - AH",]
    Bt2t1PosBC_AyaCedOya=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BC_AyaCedOya - BC_AyaCedOya",]
    Bt2t1PosBC_MatSubMez=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BC_MatSubMez - BC_MatSubMez",]
    Bt2t1PosBC_PinTasMat=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BC_PinTasMat - BC_PinTasMat",]
    Bt2t1PosBL_Chap=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BL_Chap - BL_Chap",]
    Bt2t1PosBL_EncGal=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BL_EncGal - BL_EncGal",]
    Bt2t1PosBL_InduPla=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BL_InduPla - BL_InduPla",]
    Bt2t1PosB_Secun=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="B_Secun - B_Secun",]
    Bt2t1PosH2O=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="H2O - H2O",]
    Bt2t1PosHUM_Pop=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="HUM_Pop - HUM_Pop",]
    Bt2t1PosHUM_Tul=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="HUM_Tul - HUM_Tul",]
    Bt2t1PosMAT_Cra=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MAT_Cra - MAT_Cra",]
    Bt2t1PosMAT_DesMicMez=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MAT_DesMicMez - MAT_DesMicMez",]
    Bt2t1PosMAT_DesRos=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MAT_DesRos - MAT_DesRos",]
    Bt2t1PosMAT_EspTam=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MAT_EspTam - MAT_EspTam",]
    Bt2t1PosMAT_RosCost=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MAT_RosCost - MAT_RosCost",]
    Bt2t1PosMAT_Sar=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MAT_Sar - MAT_Sar",]
    Bt2t1PosMAT_SarCra=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MAT_SarCra - MAT_SarCra",]
    Bt2t1PosMAT_SarCraNeb=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MAT_SarCraNeb - MAT_SarCraNeb",]
    Bt2t1PosNN=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="NN - NN",]
    Bt2t1PosPAST=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="PAST - PAST",]
    Bt2t1PosSC_BajaMat_Sub=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SC_BajaMat_Sub - SC_BajaMat_Sub",]
    Bt2t1PosSC_Med_Sub=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SC_Med_Sub - SC_Med_Sub",]
    Bt2t1PosSC_Secun=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SC_Secun - SC_Secun",]
    Bt2t1PosSP_AltaMed=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP_AltaMed - SP_AltaMed",]
    Bt2t1PosSP_Alta_Sub=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP_Alta_Sub - SP_Alta_Sub",]
    Bt2t1PosSP_BajaMed_Sub=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP_BajaMed_Sub - SP_BajaMed_Sub",]
    Bt2t1PosSP_MangPet=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP_MangPet - SP_MangPet",]
    Bt2t1PosSP_MesoBaja=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP_MesoBaja - SP_MesoBaja",]
    Bt2t1PosSP_Secun=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP_Secun - SP_Secun",]
    Bt2t1PosSVA=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SVA - SVA",]
    Bt2t1PosV_Cost=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="V_Cost - V_Cost",]
    Bt2t1PosV_Desert=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="V_Desert - V_Desert",]
    Bt2t1PosV_GipHalXer=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="V_GipHalXer - V_GipHalXer",]
    Bt2t1PosV_HalHid=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="V_HalHid - V_HalHid",]
    
    #Se corren las regresiones lienales simples para cada estrato###################
    lmAGRI<-lm(Bt2t1PosAGRI ~ Bt2t1PosAGRI$DifTiempoT2T1 + 0)
    lmAH<-lm(Bt2t1PosAH ~ Bt2t1PosAH$DifTiempoT2T1 + 0)
    lmBC_AyaCedOya<-lm(Bt2t1PosBC_AyaCedOya ~ Bt2t1PosBC_AyaCedOya$DifTiempoT2T1 + 0)
    lmBC_MatSubMez<-lm(Bt2t1PosBC_MatSubMez ~ Bt2t1PosBC_MatSubMez$DifTiempoT2T1 + 0)
    lmBC_PinTasMat<-lm(Bt2t1PosBC_PinTasMat ~ Bt2t1PosBC_PinTasMat$DifTiempoT2T1 + 0)
    lmBL_Chap<-lm(Bt2t1PosBL_Chap ~ Bt2t1PosBL_Chap$DifTiempoT2T1 + 0)
    lmBL_EncGal<-lm(Bt2t1PosBL_EncGal ~ Bt2t1PosBL_EncGal$DifTiempoT2T1 + 0)
    lmBL_InduPla<-lm(Bt2t1PosBL_InduPla ~ Bt2t1PosBL_InduPla$DifTiempoT2T1 + 0)
    lmB_Secun<-lm(Bt2t1PosB_Secun ~ Bt2t1PosB_Secun$DifTiempoT2T1 + 0)
    lmH2O<-lm(Bt2t1PosH2O ~ Bt2t1PosH2O$DifTiempoT2T1 + 0)
    lmHUM_Pop<-lm(Bt2t1PosHUM_Pop ~ Bt2t1PosHUM_Pop$DifTiempoT2T1 + 0)
    lmHUM_Tul<-lm(Bt2t1PosHUM_Tul ~ Bt2t1PosHUM_Tul$DifTiempoT2T1 + 0)
    lmMAT_Cra<-lm(Bt2t1PosMAT_Cra ~ Bt2t1PosMAT_Cra$DifTiempoT2T1 + 0)
    lmMAT_DesMicMez<-lm(Bt2t1PosMAT_DesMicMez ~ Bt2t1PosMAT_DesMicMez$DifTiempoT2T1 + 0)
    lmMAT_DesRos<-lm(Bt2t1PosMAT_DesRos ~ Bt2t1PosMAT_DesRos$DifTiempoT2T1 + 0)
    lmMAT_EspTam<-lm(Bt2t1PosMAT_EspTam ~ Bt2t1PosMAT_EspTam$DifTiempoT2T1 + 0)
    lmMAT_RosCost<-lm(Bt2t1PosMAT_RosCost ~ Bt2t1PosMAT_RosCost$DifTiempoT2T1 + 0)
    lmMAT_Sar<-lm(Bt2t1PosMAT_Sar ~ Bt2t1PosMAT_Sar$DifTiempoT2T1 + 0)
    lmMAT_SarCra<-lm(Bt2t1PosMAT_SarCra ~ Bt2t1PosMAT_SarCra$DifTiempoT2T1 + 0)
    lmMAT_SarCraNeb<-lm(Bt2t1PosMAT_SarCraNeb ~ Bt2t1PosMAT_SarCraNeb$DifTiempoT2T1 + 0)
    lmNN<-lm(Bt2t1PosNN ~ Bt2t1PosNN$DifTiempoT2T1 + 0)
    lmPAST<-lm(Bt2t1PosPAST ~ Bt2t1PosPAST$DifTiempoT2T1 + 0)
    lmSC_BajaMat_Sub<-lm(Bt2t1PosSC_BajaMat_Sub ~ Bt2t1PosSC_BajaMat_Sub$DifTiempoT2T1 + 0)
    lmSC_Med_Sub<-lm(Bt2t1PosSC_Med_Sub ~ Bt2t1PosSC_Med_Sub$DifTiempoT2T1 + 0)
    lmSC_Secun<-lm(Bt2t1PosSC_Secun ~ Bt2t1PosSC_Secun$DifTiempoT2T1 + 0)
    lmSP_AltaMed<-lm(Bt2t1PosSP_AltaMed ~ Bt2t1PosSP_AltaMed$DifTiempoT2T1 + 0)
    lmSP_Alta_Sub<-lm(Bt2t1PosSP_Alta_Sub ~ Bt2t1PosSP_Alta_Sub$DifTiempoT2T1 + 0)
    lmSP_BajaMed_Sub<-lm(Bt2t1PosSP_BajaMed_Sub ~ Bt2t1PosSP_BajaMed_Sub$DifTiempoT2T1 + 0)
    lmSP_MangPet<-lm(Bt2t1PosSP_MangPet ~ Bt2t1PosSP_MangPet$DifTiempoT2T1 + 0)
    lmSP_MesoBaja<-lm(Bt2t1PosSP_MesoBaja ~ Bt2t1PosSP_MesoBaja$DifTiempoT2T1 + 0)
    lmSP_Secun<-lm(Bt2t1PosSP_Secun ~ Bt2t1PosSP_Secun$DifTiempoT2T1 + 0)
    lmSVA<-lm(Bt2t1PosSVA ~ Bt2t1PosSVA$DifTiempoT2T1 + 0)
    lmV_Cost<-lm(Bt2t1PosV_Cost ~ Bt2t1PosV_Cost$DifTiempoT2T1 + 0)
    lmV_Desert<-lm(Bt2t1PosV_Desert ~ Bt2t1PosV_Desert$DifTiempoT2T1 + 0)
    lmV_GipHalXer<-lm(Bt2t1PosV_GipHalXer ~ Bt2t1PosV_GipHalXer$DifTiempoT2T1 + 0)
    lmV_HalHid<-lm(Bt2t1PosV_HalHid ~ Bt2t1PosV_HalHid$DifTiempoT2T1 + 0)
    
    ################################################################################
    #Se estiman los predictores y los IC 
    lmAGRIIC <- as.data.frame(predict.lm(lmAGRI, interval="prediction"))
    lmAHIC <- as.data.frame(predict.lm(lmAH, interval="prediction"))
    lmBC_AyaCedOyaIC <- as.data.frame(predict.lm(lmBC_AyaCedOya, interval="prediction"))
    lmBC_MatSubMezIC <- as.data.frame(predict.lm(lmBC_MatSubMez, interval="prediction"))
    lmBC_PinTasMatIC <- as.data.frame(predict.lm(lmBC_PinTasMat, interval="prediction"))
    lmBL_ChapIC <- as.data.frame(predict.lm(lmBL_Chap, interval="prediction"))
    lmBL_EncGalIC <- as.data.frame(predict.lm(lmBL_EncGal, interval="prediction"))
    lmBL_InduPlaIC <- as.data.frame(predict.lm(lmBL_InduPla, interval="prediction"))
    lmB_SecunIC <- as.data.frame(predict.lm(lmB_Secun, interval="prediction"))
    lmH2OIC <- as.data.frame(predict.lm(lmH2O, interval="prediction"))
    lmHUM_PopIC <- as.data.frame(predict.lm(lmHUM_Pop, interval="prediction"))
    lmHUM_TulIC <- as.data.frame(predict.lm(lmHUM_Tul, interval="prediction"))
    lmMAT_CraIC <- as.data.frame(predict.lm(lmMAT_Cra, interval="prediction"))
    lmMAT_DesMicMezIC <- as.data.frame(predict.lm(lmMAT_DesMicMez, interval="prediction"))
    lmMAT_DesRosIC <- as.data.frame(predict.lm(lmMAT_DesRos, interval="prediction"))
    lmMAT_EspTamIC <- as.data.frame(predict.lm(lmMAT_EspTam, interval="prediction"))
    lmMAT_RosCostIC <- as.data.frame(predict.lm(lmMAT_RosCost, interval="prediction"))
    lmMAT_SarIC <- as.data.frame(predict.lm(lmMAT_Sar, interval="prediction"))
    lmMAT_SarCraIC <- as.data.frame(predict.lm(lmMAT_SarCra, interval="prediction"))
    lmMAT_SarCraNebIC <- as.data.frame(predict.lm(lmMAT_SarCraNeb, interval="prediction"))
    lmNNIC <- as.data.frame(predict.lm(lmNN, interval="prediction"))
    lmPASTIC <- as.data.frame(predict.lm(lmPAST, interval="prediction"))
    lmSC_BajaMat_SubIC <- as.data.frame(predict.lm(lmSC_BajaMat_Sub, interval="prediction"))
    lmSC_Med_SubIC <- as.data.frame(predict.lm(lmSC_Med_Sub, interval="prediction"))
    lmSC_SecunIC <- as.data.frame(predict.lm(lmSC_Secun, interval="prediction"))
    lmSP_AltaMedIC <- as.data.frame(predict.lm(lmSP_AltaMed, interval="prediction"))
    lmSP_Alta_SubIC <- as.data.frame(predict.lm(lmSP_Alta_Sub, interval="prediction"))
    lmSP_BajaMed_SubIC <- as.data.frame(predict.lm(lmSP_BajaMed_Sub, interval="prediction"))
    lmSP_MangPetIC <- as.data.frame(predict.lm(lmSP_MangPet, interval="prediction"))
    lmSP_MesoBajaIC <- as.data.frame(predict.lm(lmSP_MesoBaja, interval="prediction"))
    lmSP_SecunIC <- as.data.frame(predict.lm(lmSP_Secun, interval="prediction"))
    lmSVAIC <- as.data.frame(predict.lm(lmSVA, interval="prediction"))
    lmV_CostIC <- as.data.frame(predict.lm(lmV_Cost, interval="prediction"))
    lmV_DesertIC <- as.data.frame(predict.lm(lmV_Desert, interval="prediction"))
    lmV_GipHalXerIC <- as.data.frame(predict.lm(lmV_GipHalXer, interval="prediction"))
    lmV_HalHidIC <- as.data.frame(predict.lm(lmV_HalHid, interval="prediction"))
    
    ################################################################################
    #Se identifican los par?metros de los modelos estiman las incertidumbres de predicci?n 
    
    numero<-rep(0,36)
    ParamModel<-data.frame(numero)
    ###Estrato
    ParamModel$Estrato[1] = "AGRI"
    ParamModel$Estrato[2] = "AH"
    ParamModel$Estrato[3] = "BC_AyaCedOya"
    ParamModel$Estrato[4] = "BC_MatSubMez"
    ParamModel$Estrato[5] = "BC_PinTasMat"
    ParamModel$Estrato[6] = "BL_Chap"
    ParamModel$Estrato[7] = "BL_EncGal"
    ParamModel$Estrato[8] = "BL_InduPla"
    ParamModel$Estrato[9] = "B_Secun"
    ParamModel$Estrato[10] = "H2O"
    ParamModel$Estrato[11] = "HUM_Pop"
    ParamModel$Estrato[12] = "HUM_Tul"
    ParamModel$Estrato[13] = "MAT_Cra"
    ParamModel$Estrato[14] = "MAT_DesMicMez"
    ParamModel$Estrato[15] = "MAT_DesRos"
    ParamModel$Estrato[16] = "MAT_EspTam"
    ParamModel$Estrato[17] = "MAT_RosCost"
    ParamModel$Estrato[18] = "MAT_Sar"
    ParamModel$Estrato[19] = "MAT_SarCra"
    ParamModel$Estrato[20] = "MAT_SarCraNeb"
    ParamModel$Estrato[21] = "NN"
    ParamModel$Estrato[22] = "PAST"
    ParamModel$Estrato[23] = "SC_BajaMat_Sub"
    ParamModel$Estrato[24] = "SC_Med_Sub"
    ParamModel$Estrato[25] = "SC_Secun"
    ParamModel$Estrato[26] = "SP_AltaMed"
    ParamModel$Estrato[27] = "SP_Alta_Sub"
    ParamModel$Estrato[28] = "SP_BajaMed_Sub"
    ParamModel$Estrato[29] = "SP_MangPet"
    ParamModel$Estrato[30] = "SP_MesoBaja"
    ParamModel$Estrato[31] = "SP_Secun"
    ParamModel$Estrato[32] = "SVA"
    ParamModel$Estrato[33] = "V_Cost"
    ParamModel$Estrato[34] = "V_Desert"
    ParamModel$Estrato[35] = "V_GipHalXer"
    ParamModel$Estrato[36] = "V_HalHid"
    
    ###par?metro del modelo
    ParamModel$parametro[1] = as.numeric(lmAGRI[[1]])
    ParamModel$parametro[2] = as.numeric(lmAH[[1]])
    ParamModel$parametro[3] = as.numeric(lmBC_AyaCedOya[[1]])
    ParamModel$parametro[4] = as.numeric(lmBC_MatSubMez[[1]])
    ParamModel$parametro[5] = as.numeric(lmBC_PinTasMat[[1]])
    ParamModel$parametro[6] = as.numeric(lmBL_Chap[[1]])
    ParamModel$parametro[7] = as.numeric(lmBL_EncGal[[1]])
    ParamModel$parametro[8] = as.numeric(lmBL_InduPla[[1]])
    ParamModel$parametro[9] = as.numeric(lmB_Secun[[1]])
    ParamModel$parametro[10] = as.numeric(lmH2O[[1]])
    ParamModel$parametro[11] = as.numeric(lmHUM_Pop[[1]])
    ParamModel$parametro[12] = as.numeric(lmHUM_Tul[[1]])
    ParamModel$parametro[13] = as.numeric(lmMAT_Cra[[1]])
    ParamModel$parametro[14] = as.numeric(lmMAT_DesMicMez[[1]])
    ParamModel$parametro[15] = as.numeric(lmMAT_DesRos[[1]])
    ParamModel$parametro[16] = as.numeric(lmMAT_EspTam[[1]])
    ParamModel$parametro[17] = as.numeric(lmMAT_RosCost[[1]])
    ParamModel$parametro[18] = as.numeric(lmMAT_Sar[[1]])
    ParamModel$parametro[19] = as.numeric(lmMAT_SarCra[[1]])
    ParamModel$parametro[20] = as.numeric(lmMAT_SarCraNeb[[1]])
    ParamModel$parametro[21] = as.numeric(lmNN[[1]])
    ParamModel$parametro[22] = as.numeric(lmPAST[[1]])
    ParamModel$parametro[23] = as.numeric(lmSC_BajaMat_Sub[[1]])
    ParamModel$parametro[24] = as.numeric(lmSC_Med_Sub[[1]])
    ParamModel$parametro[25] = as.numeric(lmSC_Secun[[1]])
    ParamModel$parametro[26] = as.numeric(lmSP_AltaMed[[1]])
    ParamModel$parametro[27] = as.numeric(lmSP_Alta_Sub[[1]])
    ParamModel$parametro[28] = as.numeric(lmSP_BajaMed_Sub[[1]])
    ParamModel$parametro[29] = as.numeric(lmSP_MangPet[[1]])
    ParamModel$parametro[30] = as.numeric(lmSP_MesoBaja[[1]])
    ParamModel$parametro[31] = as.numeric(lmSP_Secun[[1]])
    ParamModel$parametro[32] = as.numeric(lmSVA[[1]])
    ParamModel$parametro[33] = as.numeric(lmV_Cost[[1]])
    ParamModel$parametro[34] = as.numeric(lmV_Desert[[1]])
    ParamModel$parametro[35] = as.numeric(lmV_GipHalXer[[1]])
    ParamModel$parametro[36] = as.numeric(lmV_HalHid[[1]])
    
    ###Incertidumbre inferior
    ParamModel$Ulwr[1] = mean((lmAGRIIC$lwr - lmAGRIIC$fit) / lmAGRIIC$fit) * 100
    ParamModel$Ulwr[2] = mean((lmAHIC$lwr - lmAHIC$fit) / lmAHIC$fit) * 100
    ParamModel$Ulwr[3] = mean((lmBC_AyaCedOyaIC$lwr - lmBC_AyaCedOyaIC$fit) / lmBC_AyaCedOyaIC$fit) * 100
    ParamModel$Ulwr[4] = mean((lmBC_MatSubMezIC$lwr - lmBC_MatSubMezIC$fit) / lmBC_MatSubMezIC$fit) * 100
    ParamModel$Ulwr[5] = mean((lmBC_PinTasMatIC$lwr - lmBC_PinTasMatIC$fit) / lmBC_PinTasMatIC$fit) * 100
    ParamModel$Ulwr[6] = mean((lmBL_ChapIC$lwr - lmBL_ChapIC$fit) / lmBL_ChapIC$fit) * 100
    ParamModel$Ulwr[7] = mean((lmBL_EncGalIC$lwr - lmBL_EncGalIC$fit) / lmBL_EncGalIC$fit) * 100
    ParamModel$Ulwr[8] = mean((lmBL_InduPlaIC$lwr - lmBL_InduPlaIC$fit) / lmBL_InduPlaIC$fit) * 100
    ParamModel$Ulwr[9] = mean((lmB_SecunIC$lwr - lmB_SecunIC$fit) / lmB_SecunIC$fit) * 100
    ParamModel$Ulwr[10] = mean((lmH2OIC$lwr - lmH2OIC$fit) / lmH2OIC$fit) * 100
    ParamModel$Ulwr[11] = mean((lmHUM_PopIC$lwr - lmHUM_PopIC$fit) / lmHUM_PopIC$fit) * 100
    ParamModel$Ulwr[12] = mean((lmHUM_TulIC$lwr - lmHUM_TulIC$fit) / lmHUM_TulIC$fit) * 100
    ParamModel$Ulwr[13] = mean((lmMAT_CraIC$lwr - lmMAT_CraIC$fit) / lmMAT_CraIC$fit) * 100
    ParamModel$Ulwr[14] = mean((lmMAT_DesMicMezIC$lwr - lmMAT_DesMicMezIC$fit) / lmMAT_DesMicMezIC$fit) * 100
    ParamModel$Ulwr[15] = mean((lmMAT_DesRosIC$lwr - lmMAT_DesRosIC$fit) / lmMAT_DesRosIC$fit) * 100
    ParamModel$Ulwr[16] = mean((lmMAT_EspTamIC$lwr - lmMAT_EspTamIC$fit) / lmMAT_EspTamIC$fit) * 100
    ParamModel$Ulwr[17] = mean((lmMAT_RosCostIC$lwr - lmMAT_RosCostIC$fit) / lmMAT_RosCostIC$fit) * 100
    ParamModel$Ulwr[18] = mean((lmMAT_SarIC$lwr - lmMAT_SarIC$fit) / lmMAT_SarIC$fit) * 100
    ParamModel$Ulwr[19] = mean((lmMAT_SarCraIC$lwr - lmMAT_SarCraIC$fit) / lmMAT_SarCraIC$fit) * 100
    ParamModel$Ulwr[20] = mean((lmMAT_SarCraNebIC$lwr - lmMAT_SarCraNebIC$fit) / lmMAT_SarCraNebIC$fit) * 100
    ParamModel$Ulwr[21] = mean((lmNNIC$lwr - lmNNIC$fit) / lmNNIC$fit) * 100
    ParamModel$Ulwr[22] = mean((lmPASTIC$lwr - lmPASTIC$fit) / lmPASTIC$fit) * 100
    ParamModel$Ulwr[23] = mean((lmSC_BajaMat_SubIC$lwr - lmSC_BajaMat_SubIC$fit) / lmSC_BajaMat_SubIC$fit) * 100
    ParamModel$Ulwr[24] = mean((lmSC_Med_SubIC$lwr - lmSC_Med_SubIC$fit) / lmSC_Med_SubIC$fit) * 100
    ParamModel$Ulwr[25] = mean((lmSC_SecunIC$lwr - lmSC_SecunIC$fit) / lmSC_SecunIC$fit) * 100
    ParamModel$Ulwr[26] = mean((lmSP_AltaMedIC$lwr - lmSP_AltaMedIC$fit) / lmSP_AltaMedIC$fit) * 100
    ParamModel$Ulwr[27] = mean((lmSP_Alta_SubIC$lwr - lmSP_Alta_SubIC$fit) / lmSP_Alta_SubIC$fit) * 100
    ParamModel$Ulwr[28] = mean((lmSP_BajaMed_SubIC$lwr - lmSP_BajaMed_SubIC$fit) / lmSP_BajaMed_SubIC$fit) * 100
    ParamModel$Ulwr[29] = mean((lmSP_MangPetIC$lwr - lmSP_MangPetIC$fit) / lmSP_MangPetIC$fit) * 100
    ParamModel$Ulwr[30] = mean((lmSP_MesoBajaIC$lwr - lmSP_MesoBajaIC$fit) / lmSP_MesoBajaIC$fit) * 100
    ParamModel$Ulwr[31] = mean((lmSP_SecunIC$lwr - lmSP_SecunIC$fit) / lmSP_SecunIC$fit) * 100
    ParamModel$Ulwr[32] = mean((lmSVAIC$lwr - lmSVAIC$fit) / lmSVAIC$fit) * 100
    ParamModel$Ulwr[33] = mean((lmV_CostIC$lwr - lmV_CostIC$fit) / lmV_CostIC$fit) * 100
    ParamModel$Ulwr[34] = mean((lmV_DesertIC$lwr - lmV_DesertIC$fit) / lmV_DesertIC$fit) * 100
    ParamModel$Ulwr[35] = mean((lmV_GipHalXerIC$lwr - lmV_GipHalXerIC$fit) / lmV_GipHalXerIC$fit) * 100
    ParamModel$Ulwr[36] = mean((lmV_HalHidIC$lwr - lmV_HalHidIC$fit) / lmV_HalHidIC$fit) * 100
    
    ###Incertidumbre Superior
    ParamModel$Uupr[1] = mean((lmAGRIIC$upr - lmAGRIIC$fit) / lmAGRIIC$fit) * 100
    ParamModel$Uupr[2] = mean((lmAHIC$upr - lmAHIC$fit) / lmAHIC$fit) * 100
    ParamModel$Uupr[3] = mean((lmBC_AyaCedOyaIC$upr - lmBC_AyaCedOyaIC$fit) / lmBC_AyaCedOyaIC$fit) * 100
    ParamModel$Uupr[4] = mean((lmBC_MatSubMezIC$upr - lmBC_MatSubMezIC$fit) / lmBC_MatSubMezIC$fit) * 100
    ParamModel$Uupr[5] = mean((lmBC_PinTasMatIC$upr - lmBC_PinTasMatIC$fit) / lmBC_PinTasMatIC$fit) * 100
    ParamModel$Uupr[6] = mean((lmBL_ChapIC$upr - lmBL_ChapIC$fit) / lmBL_ChapIC$fit) * 100
    ParamModel$Uupr[7] = mean((lmBL_EncGalIC$upr - lmBL_EncGalIC$fit) / lmBL_EncGalIC$fit) * 100
    ParamModel$Uupr[8] = mean((lmBL_InduPlaIC$upr - lmBL_InduPlaIC$fit) / lmBL_InduPlaIC$fit) * 100
    ParamModel$Uupr[9] = mean((lmB_SecunIC$upr - lmB_SecunIC$fit) / lmB_SecunIC$fit) * 100
    ParamModel$Uupr[10] = mean((lmH2OIC$upr - lmH2OIC$fit) / lmH2OIC$fit) * 100
    ParamModel$Uupr[11] = mean((lmHUM_PopIC$upr - lmHUM_PopIC$fit) / lmHUM_PopIC$fit) * 100
    ParamModel$Uupr[12] = mean((lmHUM_TulIC$upr - lmHUM_TulIC$fit) / lmHUM_TulIC$fit) * 100
    ParamModel$Uupr[13] = mean((lmMAT_CraIC$upr - lmMAT_CraIC$fit) / lmMAT_CraIC$fit) * 100
    ParamModel$Uupr[14] = mean((lmMAT_DesMicMezIC$upr - lmMAT_DesMicMezIC$fit) / lmMAT_DesMicMezIC$fit) * 100
    ParamModel$Uupr[15] = mean((lmMAT_DesRosIC$upr - lmMAT_DesRosIC$fit) / lmMAT_DesRosIC$fit) * 100
    ParamModel$Uupr[16] = mean((lmMAT_EspTamIC$upr - lmMAT_EspTamIC$fit) / lmMAT_EspTamIC$fit) * 100
    ParamModel$Uupr[17] = mean((lmMAT_RosCostIC$upr - lmMAT_RosCostIC$fit) / lmMAT_RosCostIC$fit) * 100
    ParamModel$Uupr[18] = mean((lmMAT_SarIC$upr - lmMAT_SarIC$fit) / lmMAT_SarIC$fit) * 100
    ParamModel$Uupr[19] = mean((lmMAT_SarCraIC$upr - lmMAT_SarCraIC$fit) / lmMAT_SarCraIC$fit) * 100
    ParamModel$Uupr[20] = mean((lmMAT_SarCraNebIC$upr - lmMAT_SarCraNebIC$fit) / lmMAT_SarCraNebIC$fit) * 100
    ParamModel$Uupr[21] = mean((lmNNIC$upr - lmNNIC$fit) / lmNNIC$fit) * 100
    ParamModel$Uupr[22] = mean((lmPASTIC$upr - lmPASTIC$fit) / lmPASTIC$fit) * 100
    ParamModel$Uupr[23] = mean((lmSC_BajaMat_SubIC$upr - lmSC_BajaMat_SubIC$fit) / lmSC_BajaMat_SubIC$fit) * 100
    ParamModel$Uupr[24] = mean((lmSC_Med_SubIC$upr - lmSC_Med_SubIC$fit) / lmSC_Med_SubIC$fit) * 100
    ParamModel$Uupr[25] = mean((lmSC_SecunIC$upr - lmSC_SecunIC$fit) / lmSC_SecunIC$fit) * 100
    ParamModel$Uupr[26] = mean((lmSP_AltaMedIC$upr - lmSP_AltaMedIC$fit) / lmSP_AltaMedIC$fit) * 100
    ParamModel$Uupr[27] = mean((lmSP_Alta_SubIC$upr - lmSP_Alta_SubIC$fit) / lmSP_Alta_SubIC$fit) * 100
    ParamModel$Uupr[28] = mean((lmSP_BajaMed_SubIC$upr - lmSP_BajaMed_SubIC$fit) / lmSP_BajaMed_SubIC$fit) * 100
    ParamModel$Uupr[29] = mean((lmSP_MangPetIC$upr - lmSP_MangPetIC$fit) / lmSP_MangPetIC$fit) * 100
    ParamModel$Uupr[30] = mean((lmSP_MesoBajaIC$upr - lmSP_MesoBajaIC$fit) / lmSP_MesoBajaIC$fit) * 100
    ParamModel$Uupr[31] = mean((lmSP_SecunIC$upr - lmSP_SecunIC$fit) / lmSP_SecunIC$fit) * 100
    ParamModel$Uupr[32] = mean((lmSVAIC$upr - lmSVAIC$fit) / lmSVAIC$fit) * 100
    ParamModel$Uupr[33] = mean((lmV_CostIC$upr - lmV_CostIC$fit) / lmV_CostIC$fit) * 100
    ParamModel$Uupr[34] = mean((lmV_DesertIC$upr - lmV_DesertIC$fit) / lmV_DesertIC$fit) * 100
    ParamModel$Uupr[35] = mean((lmV_GipHalXerIC$upr - lmV_GipHalXerIC$fit) / lmV_GipHalXerIC$fit) * 100
    ParamModel$Uupr[36] = mean((lmV_HalHidIC$upr - lmV_HalHidIC$fit) / lmV_HalHidIC$fit) * 100
  }
  
  
  
  write.csv(ParamModel, file = "TablaEstFErecuperaRefo.csv")
  
  return(new("ResultSet_recuperation",
             result=ParamModel,
             module="FE por estrato",
             variable=FE_VAR,
             status=TRUE))
  
}


plotRegressions <- function (plotInputs) {
  ################################################################################
  ###Se grafican las regresiones por tipos de ecosistemas: Templados, Matorrales##
  ##Tripicatles y Otros
  
  par(mfrow=c(3,2))
  ###BCOp 
  plot(Bt2t1PosBCO_P$DifTiempoT2T1,Bt2t1PosBCO_P$CCHa, ylim=c(min(lmBCOpIC$lwr),max(lmBCOpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="BCOp ")
  lines(Bt2t1PosBCO_P$DifTiempoT2T1,lmBCOpIC$fit, col = "green")
  lines(Bt2t1PosBCO_P$DifTiempoT2T1,lmBCOpIC$lwr, col = "red")
  lines(Bt2t1PosBCO_P$DifTiempoT2T1,lmBCOpIC$upr, col = "red")
  ###BCOs 
  plot(Bt2t1PosBCO_S$DifTiempoT2T1,Bt2t1PosBCO_S$CCHa, ylim=c(min(lmBCOsIC$lwr),max(lmBCOsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="BCOs ")
  lines(Bt2t1PosBCO_S$DifTiempoT2T1,lmBCOsIC$fit, col = "green")
  lines(Bt2t1PosBCO_S$DifTiempoT2T1,lmBCOsIC$lwr, col = "red")
  lines(Bt2t1PosBCO_S$DifTiempoT2T1,lmBCOsIC$upr, col = "red")
  ###BEp 
  plot(Bt2t1PosBE_P$DifTiempoT2T1,Bt2t1PosBE_P$CCHa, ylim=c(min(lmBEpIC$lwr),max(lmBEpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="BEp ")
  lines(Bt2t1PosBE_P$DifTiempoT2T1,lmBEpIC$fit, col = "green")
  lines(Bt2t1PosBE_P$DifTiempoT2T1,lmBEpIC$lwr, col = "red")
  lines(Bt2t1PosBE_P$DifTiempoT2T1,lmBEpIC$upr, col = "red")
  ###BEs 
  plot(Bt2t1PosBE_S$DifTiempoT2T1,Bt2t1PosBE_S$CCHa, ylim=c(min(lmBEsIC$lwr),max(lmBEsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="BEs ")
  lines(Bt2t1PosBE_S$DifTiempoT2T1,lmBEsIC$fit, col = "green")
  lines(Bt2t1PosBE_S$DifTiempoT2T1,lmBEsIC$lwr, col = "red")
  lines(Bt2t1PosBE_S$DifTiempoT2T1,lmBEsIC$upr, col = "red")
  ###BMp 
  plot(Bt2t1PosBM_P$DifTiempoT2T1,Bt2t1PosBM_P$CCHa, ylim=c(min(lmBMpIC$lwr),max(lmBMpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="BMp ")
  lines(Bt2t1PosBM_P$DifTiempoT2T1,lmBMpIC$fit, col = "green")
  lines(Bt2t1PosBM_P$DifTiempoT2T1,lmBMpIC$lwr, col = "red")
  lines(Bt2t1PosBM_P$DifTiempoT2T1,lmBMpIC$upr, col = "red")
  ###BMs 
  plot(Bt2t1PosBM_S$DifTiempoT2T1,Bt2t1PosBM_S$CCHa, ylim=c(min(lmBMsIC$lwr),max(lmBMsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="BMs ")
  lines(Bt2t1PosBM_S$DifTiempoT2T1,lmBMsIC$fit, col = "green")
  lines(Bt2t1PosBM_S$DifTiempoT2T1,lmBMsIC$lwr, col = "red")
  lines(Bt2t1PosBM_S$DifTiempoT2T1,lmBMsIC$upr, col = "red")
  
  par(mfrow=c(3,2))
  ###EOTLp 
  plot(Bt2t1PosEOTL_P$DifTiempoT2T1,Bt2t1PosEOTL_P$CCHa, ylim=c(min(lmEOTLpIC$lwr),max(lmEOTLpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="EOTLp ")
  lines(Bt2t1PosEOTL_P$DifTiempoT2T1,lmEOTLpIC$fit, col = "green")
  lines(Bt2t1PosEOTL_P$DifTiempoT2T1,lmEOTLpIC$lwr, col = "red")
  lines(Bt2t1PosEOTL_P$DifTiempoT2T1,lmEOTLpIC$upr, col = "red")
  ###EOTLs 
  plot(Bt2t1PosEOTL_S$DifTiempoT2T1,Bt2t1PosEOTL_S$CCHa, ylim=c(min(lmEOTLsIC$lwr),max(lmEOTLsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="EOTLs ")
  lines(Bt2t1PosEOTL_S$DifTiempoT2T1,lmEOTLsIC$fit, col = "green")
  lines(Bt2t1PosEOTL_S$DifTiempoT2T1,lmEOTLsIC$lwr, col = "red")
  lines(Bt2t1PosEOTL_S$DifTiempoT2T1,lmEOTLsIC$upr, col = "red")
  ###EOTnp 
  #plot(Bt2t1PosEOTnL_P$DifTiempoT2T1,Bt2t1PosEOTnL_P$CCHa, ylim=c(min(lmEOTnpIC$lwr),max(lmEOTnpIC$upr)),
  #xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
  #main="EOTnp ")
  #lines(Bt2t1PosEOTnL_P$DifTiempoT2T1,lmEOTnpIC$fit, col = "green")
  #lines(Bt2t1PosEOTnL_P$DifTiempoT2T1,lmEOTnpIC$lwr, col = "red")
  #lines(Bt2t1PosEOTnL_P$DifTiempoT2T1,lmEOTnpIC$upr, col = "red")
  ###MXLp 
  plot(Bt2t1PosMXL_P$DifTiempoT2T1,Bt2t1PosMXL_P$CCHa, ylim=c(min(lmMXLpIC$lwr),max(lmMXLpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="MXLp ")
  lines(Bt2t1PosMXL_P$DifTiempoT2T1,lmMXLpIC$fit, col = "green")
  lines(Bt2t1PosMXL_P$DifTiempoT2T1,lmMXLpIC$lwr, col = "red")
  lines(Bt2t1PosMXL_P$DifTiempoT2T1,lmMXLpIC$upr, col = "red")
  ###MXLs 
  plot(Bt2t1PosMXL_S$DifTiempoT2T1,Bt2t1PosMXL_S$CCHa, ylim=c(min(lmMXLsIC$lwr),max(lmMXLsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="MXLs ")
  lines(Bt2t1PosMXL_S$DifTiempoT2T1,lmMXLsIC$fit, col = "green")
  lines(Bt2t1PosMXL_S$DifTiempoT2T1,lmMXLsIC$lwr, col = "red")
  lines(Bt2t1PosMXL_S$DifTiempoT2T1,lmMXLsIC$upr, col = "red")
  ###MXnLp 
  plot(Bt2t1PosMXnL_P$DifTiempoT2T1,Bt2t1PosMXnL_P$CCHa, ylim=c(min(lmMXnLpIC$lwr),max(lmMXnLpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="MXnLp ")
  lines(Bt2t1PosMXnL_P$DifTiempoT2T1,lmMXnLpIC$fit, col = "green")
  lines(Bt2t1PosMXnL_P$DifTiempoT2T1,lmMXnLpIC$lwr, col = "red")
  lines(Bt2t1PosMXnL_P$DifTiempoT2T1,lmMXnLpIC$upr, col = "red")
  ###MXnLs 
  plot(Bt2t1PosMXnL_S$DifTiempoT2T1,Bt2t1PosMXnL_S$CCHa, ylim=c(min(lmMXnLsIC$lwr),max(lmMXnLsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="MXnLs ")
  lines(Bt2t1PosMXnL_S$DifTiempoT2T1,lmMXnLsIC$fit, col = "green")
  lines(Bt2t1PosMXnL_S$DifTiempoT2T1,lmMXnLsIC$lwr, col = "red")
  lines(Bt2t1PosMXnL_S$DifTiempoT2T1,lmMXnLsIC$upr, col = "red")
  
  par(mfrow=c(3,2))
  ###SCp 
  plot(Bt2t1PosSC_P$DifTiempoT2T1,Bt2t1PosSC_P$CCHa, ylim=c(min(lmSCpIC$lwr),max(lmSCpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="SCp ")
  lines(Bt2t1PosSC_P$DifTiempoT2T1,lmSCpIC$fit, col = "green")
  lines(Bt2t1PosSC_P$DifTiempoT2T1,lmSCpIC$lwr, col = "red")
  lines(Bt2t1PosSC_P$DifTiempoT2T1,lmSCpIC$upr, col = "red")
  ###SCs 
  plot(Bt2t1PosSC_S$DifTiempoT2T1,Bt2t1PosSC_S$CCHa, ylim=c(min(lmSCsIC$lwr),max(lmSCsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="SCs ")
  lines(Bt2t1PosSC_S$DifTiempoT2T1,lmSCsIC$fit, col = "green")
  lines(Bt2t1PosSC_S$DifTiempoT2T1,lmSCsIC$lwr, col = "red")
  lines(Bt2t1PosSC_S$DifTiempoT2T1,lmSCsIC$upr, col = "red")
  ###SPp 
  plot(Bt2t1PosSP_P$DifTiempoT2T1,Bt2t1PosSP_P$CCHa, ylim=c(min(lmSPpIC$lwr),max(lmSPpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="SPp ")
  lines(Bt2t1PosSP_P$DifTiempoT2T1,lmSPpIC$fit, col = "green")
  lines(Bt2t1PosSP_P$DifTiempoT2T1,lmSPpIC$lwr, col = "red")
  lines(Bt2t1PosSP_P$DifTiempoT2T1,lmSPpIC$upr, col = "red")
  ###SPs 
  plot(Bt2t1PosSP_S$DifTiempoT2T1,Bt2t1PosSP_S$CCHa, ylim=c(min(lmSPsIC$lwr),max(lmSPsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="SPs ")
  lines(Bt2t1PosSP_S$DifTiempoT2T1,lmSPsIC$fit, col = "green")
  lines(Bt2t1PosSP_S$DifTiempoT2T1,lmSPsIC$lwr, col = "red")
  lines(Bt2t1PosSP_S$DifTiempoT2T1,lmSPsIC$upr, col = "red")
  ###SSCp 
  plot(Bt2t1PosSSC_P$DifTiempoT2T1,Bt2t1PosSSC_P$CCHa, ylim=c(min(lmSSCpIC$lwr),max(lmSSCpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="SSCp ")
  lines(Bt2t1PosSSC_P$DifTiempoT2T1,lmSSCpIC$fit, col = "green")
  lines(Bt2t1PosSSC_P$DifTiempoT2T1,lmSSCpIC$lwr, col = "red")
  lines(Bt2t1PosSSC_P$DifTiempoT2T1,lmSSCpIC$upr, col = "red")
  ###SSCs 
  plot(Bt2t1PosSSC_S$DifTiempoT2T1,Bt2t1PosSSC_S$CCHa, ylim=c(min(lmSSCsIC$lwr),max(lmSSCsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="SSCs ")
  lines(Bt2t1PosSSC_S$DifTiempoT2T1,lmSSCsIC$fit, col = "green")
  lines(Bt2t1PosSSC_S$DifTiempoT2T1,lmSSCsIC$lwr, col = "red")
  lines(Bt2t1PosSSC_S$DifTiempoT2T1,lmSSCsIC$upr, col = "red")
  
  par(mfrow=c(3,2))
  ###VHLp 
  plot(Bt2t1PosVHL_P$DifTiempoT2T1,Bt2t1PosVHL_P$CCHa, ylim=c(min(lmVHLpIC$lwr),max(lmVHLpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="VHLp ")
  lines(Bt2t1PosVHL_P$DifTiempoT2T1,lmVHLpIC$fit, col = "green")
  lines(Bt2t1PosVHL_P$DifTiempoT2T1,lmVHLpIC$lwr, col = "red")
  lines(Bt2t1PosVHL_P$DifTiempoT2T1,lmVHLpIC$upr, col = "red")
  ###VHLs 
  plot(Bt2t1PosVHL_S$DifTiempoT2T1,Bt2t1PosVHL_S$CCHa, ylim=c(min(lmVHLsIC$lwr),max(lmVHLsIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="VHLs ")
  lines(Bt2t1PosVHL_S$DifTiempoT2T1,lmVHLsIC$fit, col = "green")
  lines(Bt2t1PosVHL_S$DifTiempoT2T1,lmVHLsIC$lwr, col = "red")
  lines(Bt2t1PosVHL_S$DifTiempoT2T1,lmVHLsIC$upr, col = "red")
  ###VHnLp 
  plot(Bt2t1PosVHnL_P$DifTiempoT2T1,Bt2t1PosVHnL_P$CCHa, ylim=c(min(lmVHnLpIC$lwr),max(lmVHnLpIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="VHnLp ")
  lines(Bt2t1PosVHnL_P$DifTiempoT2T1,lmVHnLpIC$fit, col = "green")
  lines(Bt2t1PosVHnL_P$DifTiempoT2T1,lmVHnLpIC$lwr, col = "red")
  lines(Bt2t1PosVHnL_P$DifTiempoT2T1,lmVHnLpIC$upr, col = "red")
  ###P 
  plot(Bt2t1PosP$DifTiempoT2T1,Bt2t1PosP$CCHa, ylim=c(min(lmPIC$lwr),max(lmPIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="P ")
  lines(Bt2t1PosP$DifTiempoT2T1,lmPIC$fit, col = "green")
  lines(Bt2t1PosP$DifTiempoT2T1,lmPIC$lwr, col = "red")
  lines(Bt2t1PosP$DifTiempoT2T1,lmPIC$upr, col = "red")
  ###BC 
  plot(Bt2t1PosBC$DifTiempoT2T1,Bt2t1PosBC$CCHa, ylim=c(min(lmBCIC$lwr),max(lmBCIC$upr)),
       xlab = "Tiempo entre mediciones (a?os)", ylab = "Carbono de la Biomasa Viva (ton/ha)",
       main="BC ")
  lines(Bt2t1PosBC$DifTiempoT2T1,lmBCIC$fit, col = "green")
  lines(Bt2t1PosBC$DifTiempoT2T1,lmBCIC$lwr, col = "red")
  lines(Bt2t1PosBC$DifTiempoT2T1,lmBCIC$upr, col = "red")
  
}




















