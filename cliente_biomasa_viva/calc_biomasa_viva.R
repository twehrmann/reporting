library(doBy)


fe_variable_gui ="carbono_arboles"
lcc_type_gui = "BUR"


calcBiomasaViva <- function(fe_variable_gui, lcc_type_gui, inputData) {
  print("GUI setting (Biomasa viva)")
  print(fe_variable_gui)
  print(lcc_type_gui)
#  print(inputData)
  BaseT1<-inputData@BaseT1
  print(length(BaseT1$folio))
  
  EstratoCong<-inputData@EstratoCong
  print(length(EstratoCong$numnal))
  
  EstratosIPCC<-inputData@EstratosIPCC
  print(length(EstratosIPCC$pf_redd_clave_subcat_leno_pri_sec))
  
  AreasEstratos<-inputData@AreasEstratos
  print(length(AreasEstratos$cves))
  
  
  
  
  ###############################################################################
  #Se identifica el tipo de estrato PMN por conglomerado
  BaseT1<- merge(BaseT1, EstratoCong, by.x = "folio", by.y = "numnal",all=TRUE)
  #Se identifica el tipo de estrato IPCC por conglomerado
  BaseT1<- merge(BaseT1, EstratosIPCC, by.x = "cve4_pmn", by.y = "pf_redd_clave_subcat_leno_pri_sec",all=TRUE)
  
  #write.csv(BaseT1, file = "BaseT1.csv")
  
  ###############################################################################
  ####Se filtran los estratos que no pertenencen a las categor?as de "Tierras####
  ######################## Forestales" o "Praderas" del IPCC#####################
  BaseT1=BaseT1[BaseT1$pf_redd_ipcc_2003=="Tierras Forestales" | BaseT1$pf_redd_ipcc_2003=="Praderas",]
  length(BaseT1$folio)
  
  #se filtra todas las USM cuya "tipificaci?n" es "Inicial", "Reemplazo" o "Monitoreo"
  BaseT1=BaseT1[BaseT1$tipificacion=="Inicial" |
                  BaseT1$tipificacion=="Reemplazo" |
                  BaseT1$tipificacion=="Monitoreo",]
  length(BaseT1$folio)
  
  #Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera"
  BaseT1$CarbArboles<-ifelse(BaseT1$tipificacion=="Monitoreo" & BaseT1$pf_redd_ipcc_2003=="Praderas",0,
                             as.numeric(as.character(BaseT1$carbono_arboles)))
  
  #Se filtran todos los "NA" de la variable "CarbAerViv"
  BaseT1<-BaseT1[!(is.na(BaseT1$CarbArboles)),]
  length(BaseT1$folio)
  
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
  BaseT1$EstCong<-paste(as.character(BaseT1$cve4_pmn),"-",as.character(BaseT1$folio))
  BaseT1$contador<-1
  
  #Se agrega los datos por "Estato-Conglomerado"
  temp_env <<- new.env(hash=T) #hashed environment for easy access
  temp_env$BaseT1 =BaseT1
  temp_env$BaseT1$contador<-1
  myfun_Ni <- function(x){c(Ni=length(x))}
  Summ_NiEstCong<-summaryBy(temp_env$BaseT1$contador ~ temp_env$BaseT1$EstCong,data=temp_env$BaseT1,FUN=myfun_Ni,
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
  myfun_Ni <- function(x){c(yi=sum(x[!is.na(x)]))}
  SummCongEst<-summaryBy(temp_env2$Summ_NiEstCong$contador ~ temp_env2$Summ_NiEstCong$Estrato,data=temp_env2$Summ_NiEstCong,FUN=myfun_Ni, 
                         keep.names=TRUE, var.names=c("nCong"))
  rm(temp_env2,envir=.GlobalEnv) # cleanup 
  
  #Tabla con el n?mero de Sitios por "Estrato"
  temp_env3 <<- new.env(hash=T) #hashed environment for easy access
  temp_env3$Summ_NiEstCong =Summ_NiEstCong
  myfun_ni <- function(x){c(yi=sum(x[!is.na(x)]))}
  Summ_ni<-summaryBy(temp_env3$Summ_NiEstCong$NumSitios ~ temp_env3$Summ_NiEstCong$Estrato,data=temp_env3$Summ_NiEstCong,FUN=myfun_ni,
                     keep.names=TRUE, var.names=c("nSit"))
  rm(temp_env3,envir=.GlobalEnv) # cleanup 
  
  #Tabla con suma total de biomasa por "Estrato"
  temp_env4 <<- new.env(hash=T) #hashed environment for easy access
  temp_env4$BaseT1 =BaseT1
  myfun_yi <- function(x){c(yi=sum(x[!is.na(x)]))}
  Summ_Var<-summaryBy(temp_env4$BaseT1$yi + temp_env4$BaseT1$ai + temp_env4$BaseT1$yi2 + temp_env4$BaseT1$yiai + temp_env4$BaseT1$ai2 ~ temp_env4$BaseT1$cve4_pmn,
                      data=temp_env4$BaseT1,FUN=myfun_yi,keep.names=TRUE, var.names=c("yi","ai","yi2","yiai","ai2"))
  rm(temp_env4,envir=.GlobalEnv) # cleanup 
  
  #Union de todas las tablas en una sola
  BaseEstrato<- 0
  BaseEstrato<- merge(SummCongEst, Summ_ni, by.x = "Estrato", by.y = "Estrato",all=TRUE)
  BaseEstrato<- merge(BaseEstrato, Summ_Var, by.x = "Estrato", by.y = "cve4_pmn",all=TRUE)
  
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
  
  BaseEstrato
  
  write.csv(BaseEstrato, file = "BaseEstratoV20.csv")
  ###############################################################################
  #####Se crean variables auxiliares para obtener el estimador de Razon por ha###
  BaseT1$yij <- BaseT1$carbono_arboles
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
  myfun_Ni <- function(x){c(Ni=sum(x))}
  Summ_Ni<-0
  Summ_Ni<-summaryBy(temp_env5$BaseT1$Countij ~temp_env5$ BaseT1$folio,data=temp_env5$BaseT1,FUN=myfun_Ni,keep.names=TRUE, var.names="NumUMSreal")
  rm(temp_env5,envir=.GlobalEnv) # cleanup 
  
  #Tabla con suma total de carbono por parcela (yi)
  temp_env6 <<- new.env(hash=T) #hashed environment for easy access
  temp_env6$BaseT1 =BaseT1
  myfun_yi <- function(x){c(yi=sum(x))}
  Summ_yi<-0
  Summ_yi<-summaryBy(temp_env6$BaseT1$yij ~ temp_env6$BaseT1$folio,data=temp_env6$BaseT1,FUN=myfun_yi,keep.names=TRUE, var.names="yi")
  rm(temp_env6,envir=.GlobalEnv) # cleanup 
  
  #Tabla con el ?rea total muestreada por parcela
  temp_env7 <<- new.env(hash=T) #hashed environment for easy access
  temp_env7$BaseT1 =BaseT1
  myfun_ai <- function(x){c(ai=sum(x))}
  Summ_ai<-0
  Summ_ai<-summaryBy(temp_env7$BaseT1$aij ~ temp_env7$BaseT1$folio,data=temp_env7$BaseT1,FUN=myfun_ai,keep.names=TRUE, var.names="ai")
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
  myfun_Sum <- function(x){c(Sum=sum(x[!is.na(x)]))}
  SummTot1<-0
  SummTot1<-summaryBy(temp_env8$SummaryNiYiAi$Count+ temp_env8$SummaryNiYiAi$yi + temp_env8$SummaryNiYiAi$ai +
                        temp_env8$SummaryNiYiAi$yi2 + temp_env8$SummaryNiYiAi$yiai + temp_env8$SummaryNiYiAi$ai2 ~ temp_env8$SummaryNiYiAi$Estrato,
                      data=temp_env8$SummaryNiYiAi,FUN=myfun_Sum,keep.names=TRUE, var.names=c("TotUMPreal","SumYi",
                                                                                    "SumAi","SumYi2","SumYiAi","SumAi2"))
  rm(temp_env8,envir=.GlobalEnv) # cleanup 
  
  #Se obtiene el ?rea promedio muestreada por Parcela (UMP)
  temp_env9 <<- new.env(hash=T) #hashed environment for easy access
  temp_env9$SummaryNiYiAi =SummaryNiYiAi
  myfun_Prom <- function(x){c(Prom_ai=mean(x[!is.na(x)]))}
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
  SummTotBv2$f<-SummTotBv2$TotUMPreal/SummTotBv2$cves4_pmn
  #Se obtiene el ESTIMADOR DE RAZ?N
  SummTotBv2$EstRasonHa<-SummTotBv2$SumYi/SummTotBv2$SumAi
  #Se obtiene la VARIANZA del estimador de Raz?n
  SummTotBv2$VarEstRasonHa<-((1-SummTotBv2$f)/(SummTotBv2$TotUMPreal*(SummTotBv2$TotUMPreal-1)*SummTotBv2$PromAi^2))*
    (SummTotBv2$SumYi2-2*SummTotBv2$EstRasonHa*SummTotBv2$SumYiAi + ((SummTotBv2$EstRasonHa)^2)*SummTotBv2$SumAi2)
  #Se obtiene la INCERTIDUMBRE del estimador de Raz?n
  SummTotBv2$U<-((1.96*sqrt(SummTotBv2$VarEstRasonHa))/SummTotBv2$EstRasonHa)*100
  
  write.csv(SummTotBv2, file = "SummTotBv2.csv")
  
  
  return (SummTotBv2)
  
  
}


