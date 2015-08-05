
###############################################################################
######################Se cargan las linrer?as necesarias#######################
###############################################################################

library(doBy)
library(ggplot2)
library(grid)
library(gridExtra)

###############################################################################
#############################Se carga la direcci?n#############################
###############################################################################

#Direcci?n de la cual se leer? el archivo
setwd("/Volumes/SSD2go_tw/conafor/R scripts Oswaldo/Recuperacion Reforestacion")

###############################################################################
##############################Se lee la base###################################
BaseT1<-read.csv("Calculo_20131030_CarbonoHectarea(2004-2012)_VERSION_19_t1.csv")
length(BaseT1$folio)

BaseT2<-read.csv("Calculo_20131030_CarbonoHectarea(2004-2012)_VERSION_19_t2.csv")
length(BaseT2$folio)

EstratoCongT1<-read.csv("EstratosCongPMNgusSerieIV.csv")
length(EstratoCongT1$NUMNAL)

EstratoCongT2<-read.csv("EstratosCongPMNgusSerieV.csv")
length(EstratoCongT2$NUMNAL)

EstratosIPCC<-read.csv("EstratosPMN_IPCC.csv")
length(EstratosIPCC$pf_redd_clave_subcat_leno_pri_sec)

AreasEstratos<-read.csv("AreasEstratos.csv")
length(AreasEstratos$Cves4_Cves5_pmn )

###############################################################################
####Se identifica la clase a la que pertenece cada estrato del INEGEI e IPCC###
#Se identifica el tipo de estrato PMN 4 por conglomerado en T1
length(BaseT1$folio)
BaseT1<- merge(BaseT1, EstratoCongT1, by.x = "folio", by.y = "NUMNAL",all=TRUE)
#Se identifica el tipo de estrato IPCC por conglomerado en T1
BaseT1<- merge(BaseT1, EstratosIPCC, by.x = "cve4_pmn", by.y = "pf_redd_clave_subcat_leno_pri_sec",all=TRUE)
length(BaseT1$folio)

#Se identifica el tipo de estrato PMN 5 por conglomerado en T2
BaseT2<- merge(BaseT2, EstratoCongT2, by.x = "folio", by.y = "NUMNAL",all=TRUE)
length(BaseT2$folio)

###############################################################################
#Se imputan los 0 en los conglomerdos reportados "Monitoreo" y que ten?an "Pradera"
BaseT1$CarbAerVivT1<-ifelse(BaseT1$tipificacion=="Monitoreo" & BaseT1$pf_redd_ipcc_2003=="Praderas",0,
       as.numeric(as.character(BaseT1$carbono_arboles)))
BaseT2$CarbAerVivT2<-as.numeric(as.character(BaseT2$carbono_arboles))

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
Bt2t1PosBC=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BC - BC",]
length(Bt2t1PosBC$folio)
Bt2t1PosBCO_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BCO/P - BCO/P",]
length(Bt2t1PosBCO_P$folio)
Bt2t1PosBCO_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BCO/S - BCO/S",]
length(Bt2t1PosBCO_S$folio)
Bt2t1PosBE_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BE/P - BE/P",]
length(Bt2t1PosBE_P$folio)
Bt2t1PosBE_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BE/S - BE/S",]
length(Bt2t1PosBE_S$folio)
Bt2t1PosBM_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BM/P - BM/P",]
length(Bt2t1PosBM_P$folio)
Bt2t1PosBM_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="BM/S - BM/S",]
length(Bt2t1PosBM_S$folio)
Bt2t1PosEOTL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="EOTL/P - EOTL/P",]
length(Bt2t1PosEOTL_P$folio)
Bt2t1PosEOTL_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="EOTL/S - EOTL/S",]
length(Bt2t1PosEOTL_S$folio)
Bt2t1PosEOTnL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="EOTnL/P - EOTnL/P",]
length(Bt2t1PosEOTnL_P$folio)
Bt2t1PosMXL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MXL/P - MXL/P",]
length(Bt2t1PosMXL_P$folio)
Bt2t1PosMXL_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MXL/S - MXL/S",]
length(Bt2t1PosMXL_S$folio)
Bt2t1PosMXnL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MXnL/P - MXnL/P",]
length(Bt2t1PosMXnL_P$folio)
Bt2t1PosMXnL_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="MXnL/S - MXnL/S",]
length(Bt2t1PosMXnL_S$folio)
Bt2t1PosP=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="P - P",]
length(Bt2t1PosP$folio)
Bt2t1PosSC_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SC/P - SC/P",]
length(Bt2t1PosSC_P$folio)
Bt2t1PosSC_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SC/S - SC/S",]
length(Bt2t1PosSC_S$folio)
Bt2t1PosSP_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP/P - SP/P",]
length(Bt2t1PosSP_P$folio)
Bt2t1PosSP_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SP/S - SP/S",]
length(Bt2t1PosSP_S$folio)
Bt2t1PosSSC_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SSC/P - SSC/P",]
length(Bt2t1PosSSC_P$folio)
Bt2t1PosSSC_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="SSC/S - SSC/S",]
length(Bt2t1PosSSC_S$folio)
Bt2t1PosVHL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="VHL/P - VHL/P",]
length(Bt2t1PosVHL_P$folio)
Bt2t1PosVHL_S=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="VHL/S - VHL/S",]
length(Bt2t1PosVHL_S$folio)
Bt2t1PosVHnL_P=Bt2t1Pos[Bt2t1Pos$EstTrnsT1T2=="VHnL/P - VHnL/P",]
length(Bt2t1PosVHnL_P$folio)

#####Graficas de los incrementos brutos de carbono por PERIODO de remedici?n####
ipBCOp<-qplot(Bt2t1PosBCO_P$TiempoRem,Bt2t1PosBCO_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="BCOp")
ipBCOs<-qplot(Bt2t1PosBCO_S$TiempoRem,Bt2t1PosBCO_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="BCOs")
ipBEp<-qplot(Bt2t1PosBE_P$TiempoRem,Bt2t1PosBE_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="BEp")
ipBEs<-qplot(Bt2t1PosBE_S$TiempoRem,Bt2t1PosBE_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="BEs")
ipBMp<-qplot(Bt2t1PosBM_P$TiempoRem,Bt2t1PosBM_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="BMp")
ipBMs<-qplot(Bt2t1PosBM_S$TiempoRem,Bt2t1PosBM_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="BMs")
ipEOTLp<-qplot(Bt2t1PosEOTL_P$TiempoRem,Bt2t1PosEOTL_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="EOTLp")
ipEOTLs<-qplot(Bt2t1PosEOTL_S$TiempoRem,Bt2t1PosEOTL_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="EOTLs")
ipEOTnLp<-qplot( Bt2t1PosEOTnL_P$TiempoRem, Bt2t1PosEOTnL_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="EOTnLp")
ipMXLp<-qplot(Bt2t1PosMXL_P$TiempoRem,Bt2t1PosMXL_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="MXLp")
ipMXLs<-qplot(Bt2t1PosMXL_S$TiempoRem,Bt2t1PosMXL_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="MXLs")
ipMXnLp<-qplot(Bt2t1PosMXnL_P$TiempoRem,Bt2t1PosMXnL_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="MXnLp")
ipMXnLs<-qplot(Bt2t1PosMXnL_S$TiempoRem,Bt2t1PosMXnL_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="MXnLs")
ipPas<-qplot(Bt2t1PosP$TiempoRem,Bt2t1PosP$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="Pas")
ipSCp<-qplot(Bt2t1PosSC_P$TiempoRem,Bt2t1PosSC_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="SCp")
ipSCs<-qplot(Bt2t1PosSC_S$TiempoRem,Bt2t1PosSC_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="SCs")
ipSPp<-qplot(Bt2t1PosSP_P$TiempoRem,Bt2t1PosSP_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="SPp")
ipSPs<-qplot(Bt2t1PosSP_S$TiempoRem,Bt2t1PosSP_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="SPs")
ipSSCp<-qplot(Bt2t1PosSSC_P$TiempoRem,Bt2t1PosSSC_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="SSCp")
ipSSCs<-qplot(Bt2t1PosSSC_S$TiempoRem,Bt2t1PosSSC_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="SSCs")
ipVHLp<-qplot(Bt2t1PosVHL_P$TiempoRem,Bt2t1PosVHL_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="VHLp")
ipVHLs<-qplot(Bt2t1PosVHL_S$TiempoRem,Bt2t1PosVHL_S$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="VHLs")
ipVHnLp<-qplot(Bt2t1PosVHnL_P$TiempoRem,Bt2t1PosVHnL_P$CCHa,xlab="Periodo de Remedici?n",
 ylab="(ton/ha)", main="VHnLp")

#Graficas de los incrementos brutos de carbono por periodo de remedici?n-Agrupadas#
grid.arrange(ipBCOp, ipBCOs, ipBEp, ipBEs, ipBMp, ipBMs, ncol = 2, 
		main = "Incrementos Brutos de Carbono por Periodo de Remedici?n")

grid.arrange(ipEOTLs, ipMXLp, ipMXLs, ipMXnLp, ipMXnLs, ipPas, ncol = 2, 
		main = "Incrementos Brutos de Carbono por Periodo de Remedici?n")

grid.arrange(ipSCp, ipSCs, ipSPp, ipSPs, ipSSCp, ipSSCs, ncol = 2, 
		main = "Incrementos Brutos de Carbono por Periodo de Remedici?n")

grid.arrange(ipVHLp, ipVHLs, ipVHnLp, ncol = 2, 
		main = "Incrementos Brutos de Carbono por Periodo de Remedici?n")

################################################################################
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

write.csv(ParamModel, file = "TablaEstFErecuperaRefo.csv")


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



























