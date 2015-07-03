
###############################################################################
######################Se cargan las linrer?as necesarias#######################
###############################################################################

library(doBy)

###############################################################################
#############################Se carga la direcci?n#############################
###############################################################################

#Direcci?n de la cual se leer? el archivo
setwd("/Volumes/SSD2go_tw/conafor/R Client/cliente_biomasa_viva")

###############################################################################
##############################Se lee la base###################################
BaseT1<-read.csv("BaseCarbono.csv")
length(BaseT1$folio)

EstratoCong<-read.csv("EstratosCongPMNgusSerieIV.csv")
length(EstratoCong$NUMNAL)

EstratosIPCC<-read.csv("EstratsPMN_IPCC.csv")
length(EstratosIPCC$pf_redd_clave_subcat_leno_pri_sec)

AreasEstratos<-read.csv("AreasEstratos.csv")
length(AreasEstratos$cves)

###############################################################################
#Se identifica el tipo de estrato PMN por conglomerado
BaseT1<- merge(BaseT1, EstratoCong, by.x = "folio", by.y = "NUMNAL",all=TRUE)
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
myfun_Ni <- function(x){c(Ni=length(x))}
Summ_NiEstCong<-summaryBy(BaseT1$contador ~ BaseT1$EstCong,data=BaseT1,FUN=myfun_Ni,
		    keep.names=TRUE, var.names=c("NumSitios"))

###Se identifica el n?mero de Conglomerados por "Estrato"
#Se identifica el Conglomerado
Summ_NiEstCong$Estrato<-substr(x = Summ_NiEstCong$EstCong, start = 1, 
					stop =as.integer(gregexpr("-",Summ_NiEstCong$EstCong))-2)
Summ_NiEstCong$contador<-1
#Se grega la info por estrato
myfun_Ni <- function(x){c(yi=sum(x[!is.na(x)]))}
SummCongEst<-summaryBy(Summ_NiEstCong$contador ~ Summ_NiEstCong$Estrato,data=Summ_NiEstCong,FUN=myfun_Ni, 
								keep.names=TRUE, var.names=c("nCong"))

#Tabla con el n?mero de Sitios por "Estrato"
myfun_ni <- function(x){c(yi=sum(x[!is.na(x)]))}
Summ_ni<-summaryBy(Summ_NiEstCong$NumSitios ~ Summ_NiEstCong$Estrato,data=Summ_NiEstCong,FUN=myfun_ni,
							keep.names=TRUE, var.names=c("nSit"))

#Tabla con suma total de biomasa por "Estrato"
myfun_yi <- function(x){c(yi=sum(x[!is.na(x)]))}
Summ_Var<-summaryBy(BaseT1$yi + BaseT1$ai + BaseT1$yi2 + BaseT1$yiai + BaseT1$ai2 ~ BaseT1$cve4_pmn,
			data=BaseT1,FUN=myfun_yi,keep.names=TRUE, var.names=c("yi","ai","yi2","yiai","ai2"))

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
myfun_Ni <- function(x){c(Ni=sum(x))}
Summ_Ni<-0
Summ_Ni<-summaryBy(BaseT1$Countij ~ BaseT1$folio,data=BaseT1,FUN=myfun_Ni,keep.names=TRUE, var.names="NumUMSreal")

#Tabla con suma total de carbono por parcela (yi)
myfun_yi <- function(x){c(yi=sum(x))}
Summ_yi<-0
Summ_yi<-summaryBy(BaseT1$yij ~ BaseT1$folio,data=BaseT1,FUN=myfun_yi,keep.names=TRUE, var.names="yi")

#Tabla con el ?rea total muestreada por parcela
myfun_ai <- function(x){c(ai=sum(x))}
Summ_ai<-0
Summ_ai<-summaryBy(BaseT1$aij ~ BaseT1$folio,data=BaseT1,FUN=myfun_ai,keep.names=TRUE, var.names="ai")

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
SummaryNiYiAi<- merge(SummaryNiYiAi, EstratoCong, by.x = "folio", by.y = "NUMNAL",all=TRUE)
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
myfun_Sum <- function(x){c(Sum=sum(x[!is.na(x)]))}
SummTot1<-0
SummTot1<-summaryBy(SummaryNiYiAi$Count+ SummaryNiYiAi$yi + SummaryNiYiAi$ai +
          SummaryNiYiAi$yi2 + SummaryNiYiAi$yiai + SummaryNiYiAi$ai2 ~ SummaryNiYiAi$Estrato,
          data=SummaryNiYiAi,FUN=myfun_Sum,keep.names=TRUE, var.names=c("TotUMPreal","SumYi",
          "SumAi","SumYi2","SumYiAi","SumAi2"))
#Se obtiene el ?rea promedio muestreada por Parcela (UMP)
myfun_Prom <- function(x){c(Prom_ai=mean(x[!is.na(x)]))}
SummTot2<-0
SummTot2<-summaryBy(SummaryNiYiAi$ai ~ SummaryNiYiAi$Estrato,data=SummaryNiYiAi,
                    FUN=myfun_Prom,keep.names=TRUE,var.names="PromAi")
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

######################################FIN######################################
