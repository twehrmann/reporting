library(doBy)

myfun_Ni <- function(x){c(Ni=sum(x))}
myfun_niNA <- function(x){c(yi=sum(x[!is.na(x)]))}

myfun_NiLength <- function(x){c(Ni=length(x))}
myfun_NiSum <- function(x){c(yi=sum(x[!is.na(x)]))}
myfun_yiSum <- function(x){c(yi=sum(x[!is.na(x)]))}
myfun_aiSum <- function(x){c(ai=sum(x))}
myfun_Sum <- function(x){c(Sum=sum(x[!is.na(x)]))}
myfun_Prom <- function(x){c(Prom_ai=mean(x[!is.na(x)]))}
myfun_yi <- function(x){c(yi=sum(x))}


runModule_biomasa_viva <- function(fe_variable_gui, lcc_type_gui) {
  data=calcBiomasaViva(fe_variable_gui, lcc_type_gui, inputData)
  success=FALSE
  
  module = "biomasa_viva"
  level = "sitio"
  
  stock_type = fe_variable_gui
  lcc = lcc_type_gui
  
  db_table_name_sum = tolower(c(DB_SCHEME, paste0("FE_bm_sum_sitio_",fe_variable_gui,"_",lcc_type_gui)))
  filename_sum = tolower(paste0(OUTPUT_PATH,"/",db_table_name_sum[2]))
  
  db_table_name_estrato = tolower(c(DB_SCHEME, paste0("FE_bm_estrato_sitio_",fe_variable_gui,"_",lcc_type_gui)))
  filename_estrato = tolower(paste0(OUTPUT_PATH,"/",db_table_name_estrato[2]))
  
  if (data@status) {
    success = writeResults(filename_sum, db_table_name_sum, data@result_SummTotBv2)
    description = "sum per sitio"
    success = registerResult(db_table_name_sum[2], db_table_name_sum[1], description, module, stock_type, lcc, level)
    
    success = writeResults(filename_estrato, db_table_name_estrato, data@result_BaseEstrato)
    description = "biomasa por estrato por sitio"
    success = registerResult(db_table_name_estrato[2], db_table_name_estrato[1], description, module, stock_type, lcc, level)
    
    
  } else {
    success=FALSE
  }
  print(success)
  
  return(success)
}


fe_variable_gui ="carbono_arboles"
lcc_type_gui = "BUR"


calcBiomasaViva <- function(fe_variable_gui, lcc_type_gui, inputData) {
  loginfo("Calculando biomasa viva por sitio...")
  loginfo(paste("GUI setting: ", fe_variable_gui, "/",lcc_type_gui))
  
  FE_VAR = fe_variable_gui
  BaseT1<-inputData@BaseT1
  
  
  if (lcc_type_gui == "BUR") {
    AreasEstratos<-inputData@AreasEstratos_BUR
    EstratoCong<-inputData@EstratoCong_BUR
    EstratosIPCC<-inputData@EstratosIPCC_BUR
    
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO_KEY = "cve4_pmn"
    ESTRATO_LC_KEY = "cves4_pmn"
    
  } else if (lcc_type_gui == "MADMEX") { 
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO_KEY = "madmex_05"
    ESTRATO_LC_KEY = ESTRATO_KEY
    
    AreasEstratos<-inputData@AreasEstratos_MADMEX
    EstratoCong<-inputData@EstratoCong_MADMEX
    EstratosIPCC<-inputData@EstratosIPCC_MADMEX
    EstratoCong$cve4_pmn = EstratoCong$madmex_05
  } else if (lcc_type_gui == "INEGI") { 
    ESTRATOS_IPCC = "pf_redd_ipcc_2003"
    ESTRATO_KEY = "inegi_s4"
    ESTRATO_LC_KEY = ESTRATO_KEY
    
    AreasEstratos<-inputData@AreasEstratos_MADMEX
    EstratoCong<-inputData@EstratoCong_MADMEX
    EstratosIPCC<-inputData@EstratosIPCC_MADMEX
    EstratoCong$cve4_pmn = EstratoCong$inegi_s4
  }
  
  
  
  ###############################################################################
  #Se identifica el tipo de estrato PMN por conglomerado
  BaseT1<- merge(BaseT1, EstratoCong, by.x = "folio", by.y = "numnal",all=TRUE)
  #Se identifica el tipo de estrato IPCC por conglomerado
  BaseT1<- merge(BaseT1, EstratosIPCC, by.x = ESTRATO_KEY, by.y = "pf_redd_clave_subcat_leno_pri_sec",all=TRUE)
  
  #write.csv(BaseT1, file = "BaseT1.csv")
  
  ###############################################################################
  ####Se filtran los estratos que no pertenencen a las categor?as de "Tierras####
  ######################## Forestales" o "Praderas" del IPCC#####################
  BaseT1=BaseT1[BaseT1[,ESTRATOS_IPCC]=="Tierras Forestales" | BaseT1[,ESTRATOS_IPCC]=="Praderas",]
  
  #se filtra todas las USM cuya "tipificaci?n" es "Inicial", "Reemplazo" o "Monitoreo"
  BaseT1=BaseT1[BaseT1$tipificacion=="Inicial" |
                  BaseT1$tipificacion=="Reemplazo" |
                  BaseT1$tipificacion=="Monitoreo",]
  
  #Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera"
  BaseT1$CarbArboles<-ifelse(BaseT1$tipificacion=="Monitoreo" & BaseT1[,ESTRATOS_IPCC]=="Praderas",0,
                             as.numeric(as.character(BaseT1[,FE_VAR])))
  
  #Se filtran todos los "NA" de la variable "CarbAerViv"
  BaseT1<-BaseT1[!(is.na(BaseT1$CarbArboles)),]
  
  #write.csv(BaseT1p, file = "BaseT1p.csv")
  
  #*****************************************************************************#
  #A)CARBONO DE ?RBOLES##########################################################
  
  ###############################################################################
  #####Se crean variables auxiliares para obtener el estimador de Razon por ha###
  BaseT1$yi <- BaseT1$CarbArboles
  ###Note que los ?rboles de entre 2.5cm y 7.5 cm s?lo se midieron en parcelas###
  #####de 400m2, por lo que el ?rea de cada uno de estos sitios es de 0.04has####
  BaseT1$ai <- 0.04
  ###############################################################################
  #Se crean las variables para obtener la varianza del estimador de raz?n por ha#
  BaseT1$yi2 <-(BaseT1$yi)^2
  BaseT1$yiai<-(BaseT1$yi*BaseT1$ai)
  BaseT1$ai2 <-(BaseT1$ai)^2
  
  ###############################################################################
  ###################Se agrega la base a nivel de Estrato########################
  
  ###Tabla con el n?mero parcelas por "Estrato-Conglomerado"
  #Se crea una variable para cuantificar el "n?mero parcelas por Estato-Conglomerado"
  BaseT1$EstCong<-paste(as.character(BaseT1[,ESTRATO_KEY]),"-",as.character(BaseT1$folio))
  BaseT1$contador<-1
  
  #Se agrega los datos por "Estato-Conglomerado"
  temp_env <<- new.env(hash=T) #hashed environment for easy access
  temp_env$BaseT1 =BaseT1
  temp_env$BaseT1$contador<-1
  Summ_NiEstCong<-summaryBy(temp_env$BaseT1$contador ~ temp_env$BaseT1$EstCong,data=temp_env$BaseT1,FUN=myfun_NiLength,
                            keep.names=TRUE, var.names=c("NumSitios"))
  
  rm(temp_env,envir=.GlobalEnv) # cleanup 
  
  
  ###Se identifica el n?mero de Conglomerados por "Estrato"
  #Se identifica el Conglomerado
  Summ_NiEstCong$Estrato<-substr(x = Summ_NiEstCong$EstCong, start = 1, 
                                 stop =as.integer(gregexpr("-",Summ_NiEstCong$EstCong))-2)
  Summ_NiEstCong$contador<-1
  
  #Se grega la info por estrato
  temp_env2 <<- new.env(hash=T) #hashed environment for easy access
  temp_env2$Summ_NiEstCong =Summ_NiEstCong
  SummCongEst<-summaryBy(temp_env2$Summ_NiEstCong$contador ~ temp_env2$Summ_NiEstCong$Estrato,data=temp_env2$Summ_NiEstCong,FUN=myfun_NiSum, 
                         keep.names=TRUE, var.names=c("nCong"))
  rm(temp_env2,envir=.GlobalEnv) # cleanup 
  
  #Tabla con el n?mero de Sitios por "Estrato"
  temp_env3 <<- new.env(hash=T) #hashed environment for easy access
  temp_env3$Summ_NiEstCong =Summ_NiEstCong
  Summ_ni<-summaryBy(temp_env3$Summ_NiEstCong$NumSitios ~ temp_env3$Summ_NiEstCong$Estrato,data=temp_env3$Summ_NiEstCong,FUN=myfun_niNA,
                     keep.names=TRUE, var.names=c("nSit"))
  rm(temp_env3,envir=.GlobalEnv) # cleanup 
  
  #Tabla con suma total de biomasa por "Estrato"
  temp_env4 <<- new.env(hash=T) #hashed environment for easy access
  temp_env4$BaseT1 =BaseT1
  
  #TODO: cve4_pmn cannot be used as varaible
  Summ_Var<-summaryBy(temp_env4$BaseT1$yi + temp_env4$BaseT1$ai + temp_env4$BaseT1$yi2 + temp_env4$BaseT1$yiai + temp_env4$BaseT1$ai2 ~ temp_env4$BaseT1$cve4_pmn,
                      data=temp_env4$BaseT1,FUN=myfun_yiSum,keep.names=TRUE, var.names=c("yi","ai","yi2","yiai","ai2"))
  rm(temp_env4,envir=.GlobalEnv) # cleanup 
  Summ_Var[,ESTRATO_KEY] = Summ_Var$cve4_pmn
  
  #Union de todas las tablas en una sola
  BaseEstrato<- 0
  BaseEstrato<- merge(SummCongEst, Summ_ni, by.x = "Estrato", by.y = "Estrato",all=TRUE)
  BaseEstrato<- merge(BaseEstrato, Summ_Var, by.x = "Estrato", by.y = ESTRATO_KEY,all=TRUE)
  
  ###############################################################################
  ###Se obtienen los estimadores de raz?n, sus varianzas e incertidumbres
  #Obtenci?n de los ER
  BaseEstrato$ER_Carboles<-BaseEstrato$yi/BaseEstrato$ai
  #Se obtiene el ?rea promedio muestreada a nivel de conglomerado
  BaseEstrato$Prom_ai<-(BaseEstrato$ai/BaseEstrato$nCong)
  #Se obtiene la DESVIACI?N ST?NDAR del estimador de Raz?n
  #Se estima f para cada estrato
  #BaseEstrato$f<-0
  #BaseEstrato$f<-BaseEstrato$nCong/BaseEstrato$AreasCves4_Cves5_pmn
  #Se obtienen las DS
  BaseEstrato$SdER_Carboles<-sqrt((1/(BaseEstrato$nCong*(BaseEstrato$nCong-1)*BaseEstrato$Prom_ai^2))*
                                    (BaseEstrato$yi2-2*BaseEstrato$ER_Carboles*BaseEstrato$yiai+BaseEstrato$ai2*
                                       (BaseEstrato$ER_Carboles)^2))
  #Se obtiene la INCERTIDUMBRE del estimador de Raz?n
  BaseEstrato$U_Carboles<-((1.96*BaseEstrato$SdER_Carboles)/BaseEstrato$ER_Carboles)*100
  
  #write.csv(BaseEstrato, file = "BaseEstratoV20.csv")
  ###############################################################################
  #####Se crean variables auxiliares para obtener el estimador de Razon por ha###
  BaseT1$yij <- BaseT1[,FE_VAR]
  ##Note que los ?rboles de >7.5 cm de diam s?lo se midieron en parcelas##
  ########de 400m2, por lo que el ?rea de todos estos sitios es de 0.04has#######
  BaseT1$aij <- ifelse(is.na(BaseT1$yij)=="TRUE",NA,0.04)
  #Se obtiene el n?ero total de parcelas con dato de carbono (no valores perdidos)
  BaseT1$Countij<- ifelse(is.na(BaseT1$yij)=="TRUE",NA,1)
  
  ###############################################################################
  ###################Se agrega la base a nivel de parcela########################
  
  #Tabla con el n?mero real de sitios por parcela
  temp_env5 <<- new.env(hash=T) #hashed environment for easy access
  temp_env5$BaseT1 =BaseT1
  Summ_Ni<-0
  Summ_Ni<-summaryBy(temp_env5$BaseT1$Countij ~temp_env5$ BaseT1$folio,data=temp_env5$BaseT1,FUN=myfun_Ni,keep.names=TRUE, var.names="NumUMSreal")
  rm(temp_env5,envir=.GlobalEnv) # cleanup 
  
  #Tabla con suma total de carbono por parcela (yi)
  temp_env6 <<- new.env(hash=T) #hashed environment for easy access
  temp_env6$BaseT1 =BaseT1
  Summ_yi<-0
  Summ_yi<-summaryBy(temp_env6$BaseT1$yij ~ temp_env6$BaseT1$folio,data=temp_env6$BaseT1,FUN=myfun_yi,keep.names=TRUE, var.names="yi")
  rm(temp_env6,envir=.GlobalEnv) # cleanup 
  
  #Tabla con el ?rea total muestreada por parcela
  temp_env7 <<- new.env(hash=T) #hashed environment for easy access
  temp_env7$BaseT1 =BaseT1
  Summ_ai<-0
  Summ_ai<-summaryBy(temp_env7$BaseT1$aij ~ temp_env7$BaseT1$folio,data=temp_env7$BaseT1,FUN=myfun_aiSum,keep.names=TRUE, var.names="ai")
  rm(temp_env7,envir=.GlobalEnv) # cleanup 
  
  #Union de todas las tablas en una sola
  SummaryNi<-0
  SummaryNiYi<-0
  SummaryNiYiAi<-0
  SummaryNiYi<- merge(Summ_Ni, Summ_yi, by.x = "folio", by.y = "folio",all=TRUE)
  SummaryNiYiAi<- merge(SummaryNiYi, Summ_ai, by.x = "folio", by.y = "folio",all=TRUE)
  
  #write.csv(SummaryNiYiAi, file = "SummaryNiYiAi.csv")
  
  ###############################################################################
  #Se crean las variables para obtener la varianza del estimador de raz?n por ha#
  SummaryNiYiAi$yi2<-SummaryNiYiAi$yi^2
  SummaryNiYiAi$yiai<-SummaryNiYiAi$yi*SummaryNiYiAi$ai
  SummaryNiYiAi$ai2 <-SummaryNiYiAi$ai^2
  
  #########Se crea la variable "Estrato" en la tabla resumen##########
  SummaryNiYiAi<- merge(SummaryNiYiAi, EstratoCong, by.x = "folio", by.y = "numnal",all=TRUE)
  #Se crea la variable estrato
  SummaryNiYiAi$Estrato<-SummaryNiYiAi$cve4_pmn
  
  #Se filtran todos los "NA" de la variable "NumUMSreal"
  SummaryNiYiAi<-SummaryNiYiAi[!(is.na(SummaryNiYiAi$NumUMSreal)),]
  length(SummaryNiYiAi$folio)
  
  #Se crea un Contador
  SummaryNiYiAi$Count<-1
  
  #write.csv(SummaryNiYiAi, file = "SummaryNiYiAi.csv")
  
  ###############################################################################
  ####Se agregan las variables yi, ai, yiai por estrato y todas las variables ###
  #######necesarias para obtener los estimadores de razon y sus varianzas########
  #x[!is.na(x)]
  
  #Suma de NumTotParcelas, yi, ai, yi2, aiyi, ai2
  temp_env8 <<- new.env(hash=T) #hashed environment for easy access
  temp_env8$SummaryNiYiAi =SummaryNiYiAi
  SummTot1<-0
  SummTot1<-summaryBy(temp_env8$SummaryNiYiAi$Count+ temp_env8$SummaryNiYiAi$yi + temp_env8$SummaryNiYiAi$ai +
                        temp_env8$SummaryNiYiAi$yi2 + temp_env8$SummaryNiYiAi$yiai + temp_env8$SummaryNiYiAi$ai2 ~ temp_env8$SummaryNiYiAi$Estrato,
                      data=temp_env8$SummaryNiYiAi,FUN=myfun_Sum,keep.names=TRUE, var.names=c("TotUMPreal","SumYi",
                                                                                              "SumAi","SumYi2","SumYiAi","SumAi2"))
  rm(temp_env8,envir=.GlobalEnv) # cleanup 
  
  #Se obtiene el ?rea promedio muestreada por Parcela (UMP)
  temp_env9 <<- new.env(hash=T) #hashed environment for easy access
  temp_env9$SummaryNiYiAi =SummaryNiYiAi
  SummTot2<-0
  SummTot2<-summaryBy(temp_env9$SummaryNiYiAi$ai ~ temp_env9$SummaryNiYiAi$Estrato,data=temp_env9$SummaryNiYiAi,
                      FUN=myfun_Prom,keep.names=TRUE,var.names="PromAi")
  rm(temp_env9,envir=.GlobalEnv) # cleanup 
  
  #Se unen las dos bases de SUMAS y PROMEDIOS
  SummTotBv2<-0
  SummTotBv2<- merge(SummTot1, SummTot2, by.x = "Estrato", by.y = "Estrato",all=TRUE)
  
  #Se adjunta el ?rea de cada estrato
  SummTotBv2<- merge(SummTotBv2, AreasEstratos, by.x = "Estrato", by.y = "cves",all=TRUE)
  
  #Se filtran todos los estratos que no tienen dato
  SummTotBv2<-SummTotBv2[!(is.na(SummTotBv2$TotUMPreal)),]
  length(SummTotBv2$Estrato)
  
  #write.csv(SummTotBv2, file = "SummTotBv2.csv")
  
  ###############################################################################
  ###############Se obtienen los estimadores de Razon y sus varianzas ###########
  
  #Se estima f para cada estrato
  SummTotBv2$f<-SummTotBv2$TotUMPreal/SummTotBv2[,ESTRATO_LC_KEY]
  #Se obtiene el ESTIMADOR DE RAZ?N
  SummTotBv2$EstRasonHa<-SummTotBv2$SumYi/SummTotBv2$SumAi
  #Se obtiene la VARIANZA del estimador de Raz?n
  SummTotBv2$VarEstRasonHa<-((1-SummTotBv2$f)/(SummTotBv2$TotUMPreal*(SummTotBv2$TotUMPreal-1)*SummTotBv2$PromAi^2))*
    (SummTotBv2$SumYi2-2*SummTotBv2$EstRasonHa*SummTotBv2$SumYiAi + ((SummTotBv2$EstRasonHa)^2)*SummTotBv2$SumAi2)
  #Se obtiene la INCERTIDUMBRE del estimador de Raz?n
  SummTotBv2$U<-((1.96*sqrt(SummTotBv2$VarEstRasonHa))/SummTotBv2$EstRasonHa)*100
  
  #write.csv(SummTotBv2, file = "SummTotBv2.csv")
  
  
  return(new("ResultSet_biomasa_sitio",
             result_SummTotBv2=SummTotBv2,
             result_BaseEstrato=BaseEstrato,
             module="FE por sitio",
             variable=FE_VAR,
             status=TRUE))
}