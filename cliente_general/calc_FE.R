library(Carbono5)


runModule_carbono5 <- function(fe_variable_gui, lcc_type_gui) {
  db_table_name = tolower(c(DB_SCHEME, paste0("FE_pot_strata_",fe_variable_gui,"_",lcc_type_gui)))
  filename = tolower(paste0(OUTPUT_PATH,"/",db_table_name[2]))
  description = ""
  module = "carbono5"
  level = "strata"
  stock_type = fe_variable_gui
  lcc = lcc_type_gui
  
  data=calcFE(fe_variable_gui, lcc_type_gui, inputData)
  if (data@status) {
    success = writeResults(filename, db_table_name, data@result)
    success = registerResult(db_table_name[2], db_table_name[1], description, module, stock_type, lcc,level)
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}

fe_variable_gui="carbono_arboles"
lcc_type_gui="BUR"

calcFE <- function(fe_variable_gui, lcc_type_gui, inputData) {
  loginfo("Calculando Factores de Emision...")
  loginfo(paste("UI setting: ", fe_variable_gui, "/",lcc_type_gui))
  
  
  if (fe_variable_gui == "carbono_tocones") {
    loginfo("Sel. BaseT2")
    BaseT1 <- inputData@BaseT2 }
  else {
    loginfo("Sel. BaseT1")
    BaseT1 <- inputData@BaseT1
  }
  
  if (lcc_type_gui == "BUR") {
    EstratoCong <- inputData@EstratoCong_BUR
    EstratosIPCC <- inputData@Estratos_BUR_IPCC
    AreasEstratos <- inputData@AreasEstratos_BUR
    AREAS_ESTRATOS_KEY = "cves4_pmn"
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATOS_KEY = "pf_redd_clave_subcat_leno_pri_sec"
    ESTRATO_KEY = "clave_pmn4"
  } else if (lcc_type_gui == "MADMEX") {
    EstratoCong <- inputData@EstratoCong_MADMEX
    EstratosIPCC <- inputData@Estratos_MADMEX_IPCC
    AreasEstratos <- inputData@AreasEstratos_MADMEX
    ESTRATO_KEY = "madmex_05"
    AREAS_ESTRATOS_KEY = "madmex_05"
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATOS_KEY = "pf_redd_clave_subcat_leno_pri_sec"
  }else if (lcc_type_gui == "INEGI") {
    EstratoCong <- inputData@EstratoCong_MADMEX
    EstratosIPCC <- inputData@Estratos_MADMEX_IPCC
    AreasEstratos <- inputData@AreasEstratos_MADMEX
    ESTRATO_KEY = "inegi_s4"
    AREAS_ESTRATOS_KEY = "inegi_s4"
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATOS_KEY = "pf_redd_clave_subcat_leno_pri_sec"
  }
  
  #Se crea una variable de "Conglomerado - Sitio" en las bases "BaseT1" y "EstratoCong"
  BaseT1$CongSitio<-paste(BaseT1$folio,"-",BaseT1$sitio)
  EstratoCong$CongSitio<-paste(EstratoCong$numnal,"-",EstratoCong$sitio)
  
  #Se identifica el tipo de estrato PMN por conglomerado
  BaseT1<- merge(BaseT1, EstratoCong, by.x = "CongSitio", by.y = "CongSitio",all=TRUE)
  #Se identifica el tipo de estrato IPCC por conglomerado
  
  BaseT1<- merge(BaseT1, EstratosIPCC, by.x = ESTRATO_KEY, by.y = ESTRATOS_KEY,all=TRUE)
  
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
  
  fe_variable=0
  FE_VAR=fe_variable_gui
  
  all_vars = getAllVariables(BaseT1)
  
  
  if (! (fe_variable_gui %in% names(all_vars))) {
    df <- data.frame(test=character()) 
    logerror(paste("Variable:",fe_variable_gui,"not found in ",names(all_vars)))
    return(new("ResultSet_carbono5",
               result=df,
               module="Estimadores de razón",
               variable=FE_VAR,
               status=FALSE))
  }
  
  
  fe_variable=BaseT1[,FE_VAR]
  #Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera"
  BaseT1$FEvar<-ifelse(BaseT1$tipificacion=="Monitoreo" & BaseT1[,ESTRATOS_IPCC]=="Praderas",0,
                       as.numeric(as.character(fe_variable)))
  
  #Se filtran todos los "NA" de la variable $FEvar
  BaseT1<-BaseT1[!(is.na(BaseT1$FEvar)),]
  
  
  ###############################################################################
  #####Se crean variables auxiliares para obtener el estimador de Razon por ha###
  yi<-BaseT1$FEvar
  
  ###Note que los árboles mayores a 7.5 cm s?lo se midieron en parcelas###
  #####de 400m2, por lo que el ?rea de cada uno de estos sitios es de 0.04has####
  ai <- rep(0.04,length(yi))
  
  #Estrato
  Estrato<-BaseT1[,ESTRATO_KEY]
  AreasEstratos<-data.frame(Estrato=AreasEstratos$cves,AreaHa=AreasEstratos[,AREAS_ESTRATOS_KEY])
  
  #Conglomerado
  Conglomerado<-BaseT1$folio
  
  resultados<-ER(yi=yi,ai=ai,Estrato=Estrato,Conglomerado=Conglomerado,AreasEstratos=AreasEstratos)
  
  return(new("ResultSet_carbono5",
             result=resultados,
             module="Estimadores de razón",
             variable=FE_VAR,
             status=TRUE))
  
}

