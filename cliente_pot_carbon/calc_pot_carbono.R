library(Carbono5)

setwd("/Volumes/SSD2go_tw/conafor/R Client/cliente_pot_carbon")

metadata_baset1 = "Calculo_20140421_CarbonoSitio(2004-2012)_VERSION_19_raices_CASO1y2_TOTALESt1.csv"
BaseT1_orig<-read.csv(metadata_baset1,header=TRUE)

EstratoCong_BUR<-read.csv("EstratosCongPMNgusSerieIV_2.csv",header=TRUE)
EstratoCong_MADMEX<-read.csv("EstratosCongMADMEXgusSerieIV_2.csv",header=TRUE)


Estratos_BUR_IPCC<-read.csv("EstratsPMN_IPCC.csv",header=TRUE)
Estratos_MADMEX_IPCC<-read.csv("EstratsMADMEX_IPCC.csv",header=TRUE)

AreasEstratos_BUR<-read.csv("AreasEstratosPMN.csv",header=TRUE)
AreasEstratos_MADMEX<-read.csv("AreasEstratosMADMEX.csv",header=TRUE)



calcFE <- function(fe_variable_gui, lcc_type_gui) {
  print("GUI setting")
  print(fe_variable_gui)
  print(lcc_type_gui)
  BaseT1 <- BaseT1_orig
  
  if (lcc_type_gui == "BUR") {
    EstratoCong <- EstratoCong_BUR
    EstratosIPCC <- Estratos_BUR_IPCC
    AreasEstratos <- AreasEstratos_BUR
  } else if (lcc_type_gui == "MADMEX") {
    EstratoCong <- EstratoCong_MADMEX
    EstratosIPCC <- Estratos_MADMEX_IPCC
    AreasEstratos <- AreasEstratos_MADMEX
  }
  
  #Se crea una variable de "Conglomerado - Sitio" en las bases "BaseT1" y "EstratoCong"
  BaseT1$CongSitio<-paste(BaseT1$folio,"-",BaseT1$sitio)
  EstratoCong$CongSitio<-paste(EstratoCong$NUMNAL,"-",EstratoCong$Sitio)
  
  #Se identifica el tipo de estrato PMN por conglomerado
  BaseT1<- merge(BaseT1, EstratoCong, by.x = "CongSitio", by.y = "CongSitio",all=TRUE)
  #Se identifica el tipo de estrato IPCC por conglomerado
  
  if (lcc_type_gui == "BUR") {
    BaseT1<- merge(BaseT1, EstratosIPCC, by.x = "clave_pmn4", by.y = "pf_redd_clave_subcat_leno_pri_sec",all=TRUE)
  } else if (lcc_type_gui == "MADMEX") {
    BaseT1<- merge(BaseT1, EstratosIPCC, by.x = "clave_madmex00", by.y = "pf_redd_clave_subcat_leno_pri_sec",all=TRUE)
  }
  
  ###############################################################################
  ####Se filtran los estratos que no pertenencen a las categor?as de "Tierras"###
  ######################## Forestales" o "Praderas" del IPCC#####################
  BaseT1=BaseT1[BaseT1$pf_redd_ipcc_2003=="Tierras Forestales" | BaseT1$pf_redd_ipcc_2003=="Praderas",]
  length(BaseT1$folio)
  
  #se filtra todas las USM cuya "tipificaci?n" es "Inicial", "Reemplazo" o "Monitoreo"
  BaseT1=BaseT1[BaseT1$tipificacion=="Inicial" |
                  BaseT1$tipificacion=="Reemplazo" |
                  BaseT1$tipificacion=="Monitoreo",]
  length(BaseT1$folio)
  
  # carbono_arboles
  # carbono_tocones
  # carbono_muertospie
  # total_carbono
  # biomasa_arboles
  # biomasa_tocones
  # biomasa_muertospie
  # total_biomasa
  # carbono_raices_por_sitio
  # biomasa_raices_por_sitio
  
  fe_variable=0
  if (fe_variable_gui == "carbono_arboles") {
    print ("Using carbono_arboles")
    fe_variable=BaseT1$carbono_arboles
  } else if (fe_variable_gui == "carbono_tocones") {
    fe_variable=BaseT1$carbono_tocones
    print ("Using carbono_tocones")
  } else if (fe_variable_gui == "carbono_muertospie") {
    fe_variable=BaseT1$carbono_muertospie
    print ("Using carbono_muertospie")
  }
  #Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera"
  BaseT1$CarbArboles<-ifelse(BaseT1$tipificacion=="Monitoreo" & BaseT1$pf_redd_ipcc_2003=="Praderas",0,
                             as.numeric(as.character(fe_variable)))
  
  #Se filtran todos los "NA" de la variable "CarbAerViv"
  BaseT1<-BaseT1[!(is.na(BaseT1$CarbArboles)),]
  
  
  #*****************************************************************************#
  #A)CARBONO DE ?RBOLES##########################################################
  
  ###############################################################################
  #####Se crean variables auxiliares para obtener el estimador de Razon por ha###
  yi<-BaseT1$CarbArboles
  
  ###Note que los ?rboles mayores a 7.5 cm s?lo se midieron en parcelas###
  #####de 400m2, por lo que el ?rea de cada uno de estos sitios es de 0.04has####
  ai <- rep(0.04,length(yi))
  
  #Estrato
  if (lcc_type_gui == "BUR") {
    Estrato<-BaseT1$clave_pmn4
    AreasEstratos<-data.frame(Estrato=AreasEstratos$cves,AreaHa=AreasEstratos$cves4_pmn)
  }
  else   if (lcc_type_gui == "MADMEX") {
    Estrato<-BaseT1$clave_madmex00
    AreasEstratos<-data.frame(Estrato=AreasEstratos$cves,AreaHa=AreasEstratos$cves2_pmn)
  }
  
  #Conglomerado
  Conglomerado<-BaseT1$folio
  
  
  
  resultados<-ER(yi=yi,ai=ai,Estrato=Estrato,Conglomerado=Conglomerado,AreasEstratos=AreasEstratos)
  
  return(resultados)
  
}

print ("BUR")
data=calcFE("carbono_arboles","BUR")
write.csv(data, file = "FE_pot_carbono_arboles_bur.csv")

print("MADMEX")
data=calcFE("carbono_arboles","MADMEX")
write.csv(data, file = "FE_pot_carbono_arboles_madmex.csv")

