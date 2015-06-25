library(Carbono5)


calcFE <- function(fe_variable_gui, lcc_type_gui, inputData) {
  print("GUI setting")
  print(fe_variable_gui)
  print(lcc_type_gui)
  BaseT1 <- inputData@BaseT1_orig
  
  if (lcc_type_gui == "BUR") {
    EstratoCong <- inputData@EstratoCong_BUR
    EstratosIPCC <- inputData@Estratos_BUR_IPCC
    AreasEstratos <- inputData@AreasEstratos_BUR
    AREAS_ESTRATOS_KEY = "cves4_pmn"
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO_KEY = "clave_pmn4"
  } else if (lcc_type_gui == "MADMEX") {
    EstratoCong <- inputData@EstratoCong_MADMEX
    EstratosIPCC <- inputData@Estratos_MADMEX_IPCC
    AreasEstratos <- inputData@AreasEstratos_MADMEX
    ESTRATO_KEY = "clave_madmex00"
    AREAS_ESTRATOS_KEY = "cves4_pmn"
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
  }
  
  #Se crea una variable de "Conglomerado - Sitio" en las bases "BaseT1" y "EstratoCong"
  BaseT1$CongSitio<-paste(BaseT1$folio,"-",BaseT1$sitio)
  EstratoCong$CongSitio<-paste(EstratoCong$numnal,"-",EstratoCong$sitio)
  
  #Se identifica el tipo de estrato PMN por conglomerado
  BaseT1<- merge(BaseT1, EstratoCong, by.x = "CongSitio", by.y = "CongSitio",all=TRUE)
  #Se identifica el tipo de estrato IPCC por conglomerado
  
  BaseT1<- merge(BaseT1, EstratosIPCC, by.x = ESTRATO_KEY, by.y = "pf_redd_clave_subcat_leno_pri_sec",all=TRUE)
  
  ###############################################################################
  ####Se filtran los estratos que no pertenencen a las categor?as de "Tierras"###
  ######################## Forestales" o "Praderas" del IPCC#####################
  BaseT1=BaseT1[BaseT1[,ESTRATOS_IPCC]=="Tierras Forestales" | BaseT1[,ESTRATOS_IPCC]=="Praderas",]
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
  FE_VAR=fe_variable_gui
  
  all_vars = getAllVariables(BaseT1)
  
  print (fe_variable_gui %in% names(all_vars))
  if (! (fe_variable_gui %in% names(all_vars))) {
    df <- data.frame(test=character()) 
    
    return(new("ResultSet",
               result=df,
               module="Estimadores de razón",
               variable=FE_VAR,
               status=FALSE))
  }
  
  
  fe_variable=BaseT1[,FE_VAR]
  #Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera"
  BaseT1$FEvar<-ifelse(BaseT1$tipificacion=="Monitoreo" & BaseT1[,ESTRATOS_IPCC]=="Praderas",0,
                       as.numeric(as.character(fe_variable)))
  
  #Se filtran todos los "NA" de la variable "CarbAerViv"
  BaseT1<-BaseT1[!(is.na(BaseT1$FEvar)),]
  
  
  #*****************************************************************************#
  #A)CARBONO DE ?RBOLES##########################################################
  
  ###############################################################################
  #####Se crean variables auxiliares para obtener el estimador de Razon por ha###
  yi<-BaseT1$FEvar
  
  ###Note que los ?rboles mayores a 7.5 cm s?lo se midieron en parcelas###
  #####de 400m2, por lo que el ?rea de cada uno de estos sitios es de 0.04has####
  ai <- rep(0.04,length(yi))
  
  #Estrato
  Estrato<-BaseT1[,ESTRATO_KEY]
  AreasEstratos<-data.frame(Estrato=AreasEstratos$cves,AreaHa=AreasEstratos[,AREAS_ESTRATOS_KEY])
  
  #Conglomerado
  Conglomerado<-BaseT1$folio
  
  
  
  resultados<-ER(yi=yi,ai=ai,Estrato=Estrato,Conglomerado=Conglomerado,AreasEstratos=AreasEstratos)
  
  return(new("ResultSet",
             result=resultados,
             module="Estimadores de razón",
             variable=FE_VAR,
             status=TRUE))
  
}

