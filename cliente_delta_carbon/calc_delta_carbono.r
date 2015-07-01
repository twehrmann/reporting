
library(dCarbono)

setwd("/Volumes/SSD2go_tw/conafor/reporting/cliente_delta_carbon")


#BaseT1<-read.csv("Calculo_20140421_CarbonoSitio(2004-2012)_VERSION_19_raices_CASO1y2_TOTALESt1.csv")
BaseT1<-read.csv("CarbonoSitio(2004-2007)_VERSION_20.csv")
BaseT1<-BaseT1[!(is.na(BaseT1$folio)),]

#BaseT2<-read.csv("Calculo_20140421_CarbonoSitio(2004-2012)_VERSION_19_raices_CASO1y2_TOTALESt2.csv")
BaseT2<-read.csv("CarbonoSitio(2009-2013)_VERSION_20.csv")


BaseT2<-BaseT2[!(is.na(BaseT2$folio)),]

AreasEstratos<-read.csv("AreasEstratos.csv")

EstratosBUR<-read.csv("1234_pmn45.csv")

EstratosIPCC<-read.csv("EstratosPMN_IPCC.csv")

("Read data files...")


metadata_baset1 = "Calculo_20140421_CarbonoSitio(2004-2012)_VERSION_19_raices_CASO1y2_TOTALESt1.csv"
BaseT1_orig<-read.csv(metadata_baset1,header=TRUE)

BaseVars = vector(mode="list", length=length(names(BaseT1_orig)))
names(BaseVars) = names(BaseT1_orig)
for (i in 1:length(BaseVars) ) {
  BaseVars[i] = i
}

getAllVariables <- function() {
  return (BaseVars)
}

calcFE <- function(fe_variable_gui, lcc_type_gui) {
  print("GUI setting")
  print(fe_variable_gui)
  print(lcc_type_gui)
  ##############################Se crean bases de "T1" y "T2 s?lo con las variables de inter?s"###################################
  fe_variable=0
  if (fe_variable_gui %in% names(BaseVars)) {
    print (paste("Using FE variable:", fe_variable_gui, " index:", BaseVars[[fe_variable_gui]]))
    BaseT1dep<-data.frame(folio=BaseT1$folio, sitioT1=BaseT1$sitio, FechaT1=BaseT1$levantamiento_fecha_ejecucion,
                          tipificacionT1=BaseT1$tipificacion, carbono_arbolesT1=BaseT1[,fe_variable_gui])
    
    BaseT2dep<-data.frame(folio=BaseT2$folio, sitioT2=BaseT2$sitio, FechaT2=BaseT2$levantamiento_fecha_ejecucion,
                          tipificacionT2=BaseT2$tipificacion, carbono_arbolesT2=BaseT2[,fe_variable_gui])
  } else {
    print(paste("Cannot find EF variable:",fe_variable_gui))
    return(0)
  }
  
  
  ##############################En cada base se cre una variable de "Conglomerado-Sito"###################################
  BaseT1dep$CongSitioT1<-paste(as.character(BaseT1dep$folio),"-",as.character(BaseT1dep$sitioT1))
  BaseT2dep$CongSitioT2<-paste(as.character(BaseT2dep$folio),"-",as.character(BaseT2dep$sitioT2))
  
  ##################################Se unen las bases "BaseT1dep" y "BaseT2dep"#######################################
  BaseT1T2<- merge(BaseT1dep, BaseT2dep, by.x = "CongSitioT1", by.y = "CongSitioT2",all=TRUE)
  
  
  ###################Se identifica el estrato "del BUR" al que pertenece cada sitio en T1 y t2#######################
  #Se seleccionan las variables de inter?s de la base de "Estratos"
  EstratosBURdep<-data.frame(folio=EstratosBUR$NUMNAL, sitio=EstratosBUR$Sitio, EstratoSlV=EstratosBUR$clave_pmn4,
                             EstratoSV=EstratosBUR$clave_pmn5)
  
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
                      BaseT1T2$tipificacionT2=="Omitido-Remuestreo" & BaseT1T2$tipificacionT1=="Monitoreo" & BaseT1T2$pf_redd_ipcc_2003=="Praderas",]
  
  
  ######################Se filtran las "Tierras Forestales" o "Praderas" definidas por el IPCC########################
  BaseT1T2=BaseT1T2[BaseT1T2$pf_redd_ipcc_2003=="Tierras Forestales" | BaseT1T2$pf_redd_ipcc_2003=="Praderas",]
  
  #############Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera" en T1 y T2#########
  BaseT1T2$CarbAerVivT1<-ifelse(BaseT1T2$tipificacionT1=="Monitoreo" & BaseT1T2$pf_redd_ipcc_2003=="Praderas",0,
                                as.numeric(as.character(BaseT1T2$carbono_arbolesT1)))
  
  BaseT1T2$CarbAerVivT2<-ifelse(BaseT1T2$tipificacionT1=="Monitoreo" & BaseT1T2$pf_redd_ipcc_2003=="Praderas"&
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
  
  #Se identifica el ?rea de cada estrato
  #Se identifica el Estrato
  Estrato<-substr(x = AreasEstratos$Cves4_Cves5_pmn, 
                  start = 1, stop =as.integer(gregexpr("-",AreasEstratos$Cves4_Cves5_pmn))-2)
  AreaHa<-AreasEstratos$AreasCves4_Cves5_pmn
  
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
  
  out=Cambios(y_t1=y_t1, y_t2=y_t2, t1=t1, t2=t2, conglomerado=conglomerado, 
              estrato=estrato, ai=ai, AreasEstratos=AreasEstratos)
  
  return(out)
  
}


print ("BUR")
data=calcFE("carbono_arboles","BUR")
write.csv(data, file = "FE_pot_carbono_arboles_bur_v20.csv")
