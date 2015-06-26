library(dCarbono)

fe_variable_gui="carbono_arboles"
lcc_type_gui="MADMEX"

calcChanges <- function(fe_variable_gui, lcc_type_gui, inputData) {
  loginfo("Calculando cambio de los factores de emision...")
  loginfo(paste("GUI setting: ", fe_variable_gui, "/",lcc_type_gui))
  
  FE_VAR = fe_variable_gui
  
  if (lcc_type_gui == "BUR") {
    AreasEstratos<-inputData@AreasEstratosBUR
    EstratosBUR<-inputData@EstratosBUR
    EstratosIPCC<-inputData@Estratos_BUR_IPCC
    
    AREAS_ESTRATOS_KEY = "cves4_cves5_pmn"
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO1_KEY = "clave_pmn4"
    ESTRATO2_KEY = "clave_pmn5"
    
  } else if (lcc_type_gui == "MADMEX") {
    AreasEstratos<-inputData@AreasEstratosMADMEX
    EstratosBUR<-inputData@EstratosMADMEX
    EstratosIPCC<-inputData@EstratosMADMEX_IPCC
    
    AREAS_ESTRATOS_KEY = "madmex_05_10"
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO1_KEY = "madmex_05"
    ESTRATO2_KEY = "madmex_10"
    
  } else if (lcc_type_gui == "INEGI") {
    AreasEstratos<-inputData@AreasEstratosMADMEX
    EstratosBUR<-inputData@EstratosMADMEX
    EstratosIPCC<-inputData@EstratosMADMEX_IPCC
    
    AREAS_ESTRATOS_KEY = "madmex_05_10"
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO1_KEY = "inegi_s4"
    ESTRATO2_KEY = "inegi_s5"
  }
  
  BaseT1<-inputData@BaseT1
  BaseT2<-inputData@BaseT2
  
  
  BaseT1<-BaseT1[!(is.na(BaseT1$folio)),]
  BaseT2<-BaseT2[!(is.na(BaseT2$folio)),]
  
  BaseT1_orig<-BaseT1
  
  BaseVars = getAllVariables(BaseT1_orig)

  ##############################Se crean bases de "T1" y "T2 s?lo con las variables de inter?s"###################################
  fe_variable=0
  if (fe_variable_gui %in% names(BaseVars)) {
    print (paste("Using EF variable:", fe_variable_gui, " index:", BaseVars[[fe_variable_gui]]))
    
    BaseT1dep<-data.frame(folio=BaseT1$folio, sitioT1=BaseT1$sitio, FechaT1=BaseT1$levantamiento_fecha_ejecucion,
                          tipificacionT1=BaseT1$tipificacion, carbono_arbolesT1=BaseT1[,fe_variable_gui])
    BaseT2dep<-data.frame(folio=BaseT2$folio, sitioT2=BaseT2$sitio, FechaT2=BaseT2$levantamiento_fecha_ejecucion,
                          tipificacionT2=BaseT2$tipificacion, carbono_arbolesT2=BaseT2[,fe_variable_gui])
  } else {
    print(paste("Cannot find EF variable:",fe_variable_gui))
    df <- data.frame(test=character()) 
    
    return(new("ResultSet",
               result=df,
               module="Estimadores de razón",
               variable=FE_VAR,
               status=FALSE))
  }
  
  
  ##############################En cada base se cre una variable de "Conglomerado-Sito"###################################
  BaseT1dep$CongSitioT1<-paste(as.character(BaseT1dep$folio),"-",as.character(BaseT1dep$sitioT1))
  BaseT2dep$CongSitioT2<-paste(as.character(BaseT2dep$folio),"-",as.character(BaseT2dep$sitioT2))
  
  ##################################Se unen las bases "BaseT1dep" y "BaseT2dep"#######################################
  BaseT1T2<- merge(BaseT1dep, BaseT2dep, by.x = "CongSitioT1", by.y = "CongSitioT2",all=TRUE)
  
  
  ###################Se identifica el estrato "del BUR" al que pertenece cada sitio en T1 y t2#######################
  #Se seleccionan las variables de inter?s de la base de "Estratos"
  EstratosBURdep<-data.frame(folio=EstratosBUR$numnal, sitio=EstratosBUR$sitio, EstratoSlV=EstratosBUR[,ESTRATO1_KEY],
                             EstratoSV=EstratosBUR[,ESTRATO2_KEY])
  
  #En la base "EstratosBURdep" se crea una nueva variable de "Cong-Sitio"
  EstratosBURdep$CongSitio<-paste(as.character(EstratosBURdep$folio),"-",as.character(EstratosBURdep$sitio))
  
  #Se unen las bases "BaseT1T2" y "EstratosBURdep"
  BaseT1T2<- merge(BaseT1T2, EstratosBURdep, by.x = "CongSitioT1", by.y = "CongSitio",all=TRUE)
  
  
  ###################Se identifica el estrato "del IPCC" al que pertenece cada sitio en T1 y t2#######################
  BaseT1T2<- merge(BaseT1T2, EstratosIPCC, by.x = "EstratoSlV", by.y = "pf_redd_clave_subcat_leno_pri_sec",all=TRUE)
  
  
  #############################Se filtran los sitios reportados como "Iniciales" en T1 y T2############################
  #se filtra todas las UMP cuya "tipificaci?n" es "Inicial", "Reemplazo" o "Monitoreo" en T1
  BaseT1T2=BaseT1T2[BaseT1T2$tipificacionT1=="Inicial" |
                      #              BaseT1T2$tipificacionT1=="Reemplazo" |
                      BaseT1T2$tipificacionT1=="Monitoreo",]
  
  #se filtra todas las USM cuya "tipificaci?n" es "Inicial", "Reemplazo" o "Omitido-Remuestreo" en T2
  BaseT1T2=BaseT1T2[BaseT1T2$tipificacionT2=="Inicial" |
                      #              BaseT1T2$tipificacionT2=="Reemplazo" |
                      BaseT1T2$tipificacionT2=="Omitido-Remuestreo" & BaseT1T2$tipificacionT1=="Monitoreo" & BaseT1T2[,ESTRATOS_IPCC]=="Praderas",]
  
  
  ######################Se filtran las "Tierras Forestales" o "Praderas" definidas por el IPCC########################
  BaseT1T2=BaseT1T2[BaseT1T2[,ESTRATOS_IPCC]=="Tierras Forestales" | BaseT1T2[,ESTRATOS_IPCC]=="Praderas",]
  
  #############Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera" en T1 y T2#########
  BaseT1T2$CarbAerVivT1<-ifelse(BaseT1T2$tipificacionT1=="Monitoreo" & BaseT1T2[,ESTRATOS_IPCC]=="Praderas",0,
                                as.numeric(as.character(BaseT1T2$carbono_arbolesT1)))
  
  BaseT1T2$CarbAerVivT2<-ifelse(BaseT1T2$tipificacionT1=="Monitoreo" & BaseT1T2[,ESTRATOS_IPCC]=="Praderas"&
                                  BaseT1T2$tipificacionT2=="Omitido-Remuestreo",0, as.numeric(as.character(BaseT1T2$carbono_arbolesT2)))
  
  ##############Se filtran los sitios que en T1 y/o en T2 contienen valores "NA" en el carbono estimado#############
  #Se filtran todos los "NA" de la variable "CarbAerViv" en T1
  BaseT1T2<-BaseT1T2[!(is.na(BaseT1T2$CarbAerVivT1)),]
  
  #Se filtran todos los "NA" de la variable "CarbAerVivT2correg" en T2
  BaseT1T2<-BaseT1T2[!(is.na(BaseT1T2$CarbAerVivT2)),]
  
  ##############################Se filtran las transiciones de las zonas de permanencia###############################
  #Se crea una variable de "Estratos de Transici?n"
  BaseT1T2$EstTrnsT1T2<-paste(as.character(BaseT1T2$EstratoSlV),"-",as.character(BaseT1T2$EstratoSV))
  
  #Se fltran los sitios que no son de permanencia
  # STATIC DEFINITION OF PERSISTENT AREAS
  if (lcc_type_gui == "BUR") {
    BaseT1T2=BaseT1T2[
      BaseT1T2$EstTrnsT1T2=="ACUI - ACUI"  |
        BaseT1T2$EstTrnsT1T2=="AGR - AGR"  |
        BaseT1T2$EstTrnsT1T2=="AH - AH"  |
        BaseT1T2$EstTrnsT1T2=="BC - BC"  |
        BaseT1T2$EstTrnsT1T2=="BCO/P - BCO/P"  |
        BaseT1T2$EstTrnsT1T2=="BCO/S - BCO/S"  |
        BaseT1T2$EstTrnsT1T2=="BE/P - BE/P"  |
        BaseT1T2$EstTrnsT1T2=="BE/S - BE/S"  |
        BaseT1T2$EstTrnsT1T2=="BM/P - BM/P"  |
        BaseT1T2$EstTrnsT1T2=="BM/S - BM/S"  |
        BaseT1T2$EstTrnsT1T2=="EOTL/P - EOTL/P"  |
        BaseT1T2$EstTrnsT1T2=="EOTL/S - EOTL/S"  |
        BaseT1T2$EstTrnsT1T2=="EOTnL/P - EOTnL/P"  |
        BaseT1T2$EstTrnsT1T2=="H2O - H2O"  |
        BaseT1T2$EstTrnsT1T2=="MXL/P - MXL/P"  |
        BaseT1T2$EstTrnsT1T2=="MXL/S - MXL/S"  |
        BaseT1T2$EstTrnsT1T2=="MXnL/P - MXnL/P"  |
        BaseT1T2$EstTrnsT1T2=="MXnL/S - MXnL/S"  |
        BaseT1T2$EstTrnsT1T2=="OT - OT"  |
        BaseT1T2$EstTrnsT1T2=="P - P"  |
        BaseT1T2$EstTrnsT1T2=="SC/P - SC/P"  |
        BaseT1T2$EstTrnsT1T2=="SC/S - SC/S"  |
        BaseT1T2$EstTrnsT1T2=="SP/P - SP/P"  |
        BaseT1T2$EstTrnsT1T2=="SP/S - SP/S"  |
        BaseT1T2$EstTrnsT1T2=="SSC/P - SSC/P"  |
        BaseT1T2$EstTrnsT1T2=="SSC/S - SSC/S"  |
        BaseT1T2$EstTrnsT1T2=="VHL/P - VHL/P"  |
        BaseT1T2$EstTrnsT1T2=="VHL/S - VHL/S"  |
        BaseT1T2$EstTrnsT1T2=="VHnL/P - VHnL/P",]
    
    Estrato<-substr(x = AreasEstratos[,AREAS_ESTRATOS_KEY], 
                    start = 1, stop =as.integer(gregexpr("-",AreasEstratos[,AREAS_ESTRATOS_KEY]))-2)
  } else if (lcc_type_gui == "MADMEX" | lcc_type_gui == "INEGI") {
    BaseT1T2=BaseT1T2[
      BaseT1T2$EstTrnsT1T2=="AGRI - AGRI" | 
        BaseT1T2$EstTrnsT1T2=="AH - AH" | 
        BaseT1T2$EstTrnsT1T2=="BC_AyaCedOya - BC_AyaCedOya" | 
        BaseT1T2$EstTrnsT1T2=="BC_MatSubMez - BC_MatSubMez" | 
        BaseT1T2$EstTrnsT1T2=="BC_PinTasMat - BC_PinTasMat" | 
        BaseT1T2$EstTrnsT1T2=="BL_Chap - BL_Chap" | 
        BaseT1T2$EstTrnsT1T2=="BL_EncGal - BL_EncGal" | 
        BaseT1T2$EstTrnsT1T2=="BL_InduPla - BL_InduPla" | 
        BaseT1T2$EstTrnsT1T2=="B_Secun - B_Secun" | 
        BaseT1T2$EstTrnsT1T2=="H2O - H2O" | 
        BaseT1T2$EstTrnsT1T2=="HUM_Pop - HUM_Pop" | 
        BaseT1T2$EstTrnsT1T2=="HUM_Tul - HUM_Tul" | 
        BaseT1T2$EstTrnsT1T2=="MAT_Cra - MAT_Cra" | 
        BaseT1T2$EstTrnsT1T2=="MAT_DesMicMez - MAT_DesMicMez" | 
        BaseT1T2$EstTrnsT1T2=="MAT_DesRos - MAT_DesRos" | 
        BaseT1T2$EstTrnsT1T2=="MAT_EspTam - MAT_EspTam" | 
        BaseT1T2$EstTrnsT1T2=="MAT_RosCost - MAT_RosCost" | 
        BaseT1T2$EstTrnsT1T2=="MAT_Sar - MAT_Sar" | 
        BaseT1T2$EstTrnsT1T2=="MAT_SarCra - MAT_SarCra" | 
        BaseT1T2$EstTrnsT1T2=="MAT_SarCraNeb - MAT_SarCraNeb" | 
        BaseT1T2$EstTrnsT1T2=="NN - NN" | 
        BaseT1T2$EstTrnsT1T2=="PAST - PAST" | 
        BaseT1T2$EstTrnsT1T2=="SC_BajaMat_Sub - SC_BajaMat_Sub" | 
        BaseT1T2$EstTrnsT1T2=="SC_Med_Sub - SC_Med_Sub" | 
        BaseT1T2$EstTrnsT1T2=="SC_Secun - SC_Secun" | 
        BaseT1T2$EstTrnsT1T2=="SP_AltaMed - SP_AltaMed" | 
        BaseT1T2$EstTrnsT1T2=="SP_Alta_Sub - SP_Alta_Sub" | 
        BaseT1T2$EstTrnsT1T2=="SP_BajaMed_Sub - SP_BajaMed_Sub" | 
        BaseT1T2$EstTrnsT1T2=="SP_MangPet - SP_MangPet" | 
        BaseT1T2$EstTrnsT1T2=="SP_MesoBaja - SP_MesoBaja" | 
        BaseT1T2$EstTrnsT1T2=="SP_Secun - SP_Secun" | 
        BaseT1T2$EstTrnsT1T2=="SVA - SVA" | 
        BaseT1T2$EstTrnsT1T2=="V_Cost - V_Cost" | 
        BaseT1T2$EstTrnsT1T2=="V_Desert - V_Desert" | 
        BaseT1T2$EstTrnsT1T2=="V_GipHalXer - V_GipHalXer" | 
        BaseT1T2$EstTrnsT1T2=="V_HalHid - V_HalHid" ,]
    
    Estrato<-substr(x = AreasEstratos[,AREAS_ESTRATOS_KEY], 
                    start = 1, stop =as.integer(gregexpr("-",AreasEstratos[,AREAS_ESTRATOS_KEY]))-1)
  }
  
  #Se identifica el ?rea de cada estrato
  #Se identifica el Estrato
  
  AreaHa<-AreasEstratos$areas_cves4_cves5_pmn
  
  AreasEstratos<-data.frame(Estrato,AreaHa)
  
  #####################################Se imputa el ?rea de muestreo a nivel de sitio################################
  ai=rep(0.04,nrow(BaseT1T2)) 
  
  t1=BaseT1T2$FechaT1
  t2=BaseT1T2$FechaT2
  conglomerado=BaseT1T2$folio.x
  estrato=BaseT1T2$EstTrnsT1T2
  y_t1=BaseT1T2$CarbAerVivT1
  y_t2=BaseT1T2$CarbAerVivT2
  
  #rm(BaseT1T2)
  
  resultados = 0
  resultados=Cambios(y_t1=y_t1, y_t2=y_t2, t1=t1, t2=t2, conglomerado=conglomerado, 
                     estrato=estrato, ai=ai, AreasEstratos=AreasEstratos)
  
  if (resultados==0) {
    return(new("ResultSet",
               result=df,
               module="Estimadores de razón",
               variable=FE_VAR,
               status=FALSE))
  }
  
  return(new("ResultSet",
             result=resultados,
             module="Cambios en almacenes de carbono",
             variable=FE_VAR,
             status=TRUE))
  
}


