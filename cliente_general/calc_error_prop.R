library(doBy)
library(relimp)# libreria para visualizar la matriz de datos


calcErrorProp <- function(lcc_type_gui, inputData) {
  loginfo("Calculando FE con incerditumbres")
  loginfo(paste("GUI setting: ", lcc_type_gui))
  BaseCruces<-0
  BaseDinamica<-0
  TablaFEdefor<-0
  TablaFEdegra<-0
  TablaFAperma<-0
  TablaFArecup<-0
  
  if (lcc_type_gui == "BUR") {
    BaseCruces<-inputData@BaseCruces_BUR
    BaseDinamica<-inputData@BaseDinamica_BUR  
    
    TablaFEdefor<-inputData@TablaFEdefor_BUR
    TablaFEdegra<-inputData@TablaFEdegra_BUR
    TablaFArecup<-inputData@TablaFArecup_BUR

    #Se identifica el estrato permamnete 
    TablaFApermaP<-inputData@TablaFApermaP_BUR
  } else if (lcc_type_gui == "MADMEX") {
    BaseCruces<-inputData@BaseCruces_MADMEX
    BaseDinamica<-inputData@BaseDinamica_MADMEX  
    
    TablaFEdefor<-inputData@TablaFEdefor_MADMEX
    TablaFEdegra<-inputData@TablaFEdegra_MADMEX
    TablaFArecup<-inputData@TablaFArecup_MADMEX
    
    #Se identifica el estrato permamnete 
    TablaFApermaP<-inputData@TablaFApermaP_BUR
  }
  
  TablaFEdeforPrad<-TablaFEdefor
  TablaFArecupPrad<-TablaFArecup
  TablaFArefo<-TablaFArecup
  
  TablaFApermaP$Estrato2<-substr(x = TablaFApermaP$Estrato, start = 1, stop =as.integer(gregexpr("-",TablaFApermaP$Estrato))-2)
  TablaFAperma<-data.frame(Estrato=TablaFApermaP$Estrato2,n=TablaFApermaP$n,FE=TablaFApermaP$FE,U=TablaFApermaP$U)
  
  ###################################################################################################################
  #se concatenan los tipos de covertura entre S2 y S3
  BaseCruces$S2_S3_p<-paste(as.character(BaseCruces$pmn_s4),"-",as.character(BaseCruces$pmn_s5))
  
  #Se agregan las ?reas para las transiciones entre S2 y S3
  temp_env <<- new.env(hash=T) #hashed environment for easy access
  temp_env$BaseCruces =BaseCruces
  FunSum <- function(x){c(Sum=sum(x[!is.na(x)]))}
  BaseTransiS2S3<-0
  BaseTransiS2S3<-summaryBy(temp_env$BaseCruces$Count ~ temp_env$BaseCruces$S2_S3_p,
                            data=temp_env$BaseCruces, FUN=FunSum,keep.names=TRUE, var.names=c("Areas"))
  loginfo(length(BaseTransiS2S3$S2_S3_p))
  rm(temp_env,envir=.GlobalEnv) # cleanup 
  
  #Se identifica el tipo de din?mica en cada estrato de tratsici?n entre S2 y S3
  #Se crea una base con las posibles clases de transici?n y los tipos de din?mica
  BaseDinamicaDep<-0
  BaseDinamicaDep<-data.frame(S2_S3=BaseDinamica$combinacion_,DinamicaG=BaseDinamica$Dinamica)
  #Se etiqueta las transiciones de acuerdo a las clases del IPCC
  BaseDinamicaDep$Dinamica<-ifelse(BaseDinamicaDep$DinamicaG=="DEFORESTACION","TF-OU",
                                   ifelse(BaseDinamicaDep$DinamicaG=="DEFORESTACION PRADERA","TF-PRA",
                                          ifelse(BaseDinamicaDep$DinamicaG=="DEGRADACION","TF-TFd",
                                                 ifelse(BaseDinamicaDep$DinamicaG=="PERDIDA PRADERAS","PRAD-OU",
                                                        ifelse(BaseDinamicaDep$DinamicaG=="PERMANENCIA","TF-TF",
                                                               ifelse(BaseDinamicaDep$DinamicaG=="PERMANENCIA PRADERA","PRAD-PRAD",
                                                                      ifelse(BaseDinamicaDep$DinamicaG=="RECUPERACION","TFd-TF",
                                                                             ifelse(BaseDinamicaDep$DinamicaG=="RECUPERACION PRADERA","OU-PRAD",
                                                                                    ifelse(BaseDinamicaDep$DinamicaG=="REFORESTACION","OU-TF",
                                                                                           ifelse(BaseDinamicaDep$DinamicaG=="NA","NA","NO APLICA"))))))))))
  #Se asigna el tipo de din?mica a cada transici?n 
  BaseTransiS2S3<- merge(BaseTransiS2S3, BaseDinamicaDep, by.x = "S2_S3_p", by.y = "S2_S3",all=TRUE)
  loginfo(length(BaseTransiS2S3$S2_S3_p))
  
  #se filtran los NULL en la variable "Areas"
  BaseTransiS2S3<-BaseTransiS2S3[!(is.na(BaseTransiS2S3$Areas)),]
  loginfo(length(BaseTransiS2S3$S2_S3_p))
  
  #Se eliminan el estrato "NO APLICA"
  BaseTransiS2S3<-BaseTransiS2S3[BaseTransiS2S3$Dinamica!="NO APLICA",]
  loginfo(length(BaseTransiS2S3$S2_S3_p))
  
  DifSeries<-4
  
  ###################################################################################################################
  #Se identifica el tipo de estrato al que se le asignar? el FE
  ###################################################################################################################
  #Se desagrega el estrato de transici?n S2-S3
  Est1<-substr(x = BaseTransiS2S3$S2_S3_p, start = 1, stop =as.integer(gregexpr("-",BaseTransiS2S3$S2_S3_p))-2)
  Est2<-substr(x = BaseTransiS2S3$S2_S3_p, start = as.integer(gregexpr("-",BaseTransiS2S3$S2_S3_p))+2,
               stop =nchar(BaseTransiS2S3$S2_S3_p))
  #Se identifica el estrato al que se le asignar? el FE
  BaseTransiS2S3$EstratoFE<-ifelse(BaseTransiS2S3$Dinamica=="TF-OU",Est1,
                                   ifelse(BaseTransiS2S3$Dinamica=="TF-PRA",Est1,
                                          ifelse(BaseTransiS2S3$Dinamica=="TF-TFd",Est1,
                                                 ifelse(BaseTransiS2S3$Dinamica=="NO APLICA","NO APLICA",
                                                        ifelse(BaseTransiS2S3$Dinamica=="PRAD-OU",Est1,
                                                               ifelse(BaseTransiS2S3$Dinamica=="TF-TF",Est2,
                                                                      ifelse(BaseTransiS2S3$Dinamica=="PRAD-PRAD",Est2,
                                                                             ifelse(BaseTransiS2S3$Dinamica=="TFd-TF",Est1,
                                                                                    ifelse(BaseTransiS2S3$Dinamica=="OU-PRAD",Est2,
                                                                                           ifelse(BaseTransiS2S3$Dinamica=="OU-TF",Est2,"Error"))))))))))
  
  #Se crea una variable "Din?mica-Estrato" (al que se le asignar? el FE)
  BaseTransiS2S3$DinEstFE<-paste(BaseTransiS2S3$Dinamica,"--",BaseTransiS2S3$EstratoFE)
  
  #Se crean los estratos "Din?mica-Estrato" en las bases con las que se cargar?n los FE
  #DEFORESTACI?N (PRAD-OU/TF-OU)
  TablaFEdefor$DinEstFE<-ifelse(TablaFEdefor$Estrato=="EOTnL/P"  |
                                  TablaFEdefor$Estrato=="MXnL/P"  |
                                  TablaFEdefor$Estrato=="MXnL/S"  |
                                  TablaFEdefor$Estrato=="P"  |
                                  TablaFEdefor$Estrato=="VHnL/P" 
                                ,paste("PRAD-OU","--",TablaFEdefor$Estrato),
                                paste("TF-OU","--",TablaFEdefor$Estrato))
  
  #DEFORESTACI?N (TF-PRAD)
  TablaFEdeforPrad$DinEstFE<- paste("TF-PRA","--",TablaFEdeforPrad$Estrato)
  
  #PERMANENCIA
  TablaFAperma$DinEstFE<-ifelse(TablaFAperma$Estrato=="EOTnL/P"  |
                                  TablaFAperma$Estrato=="MXnL/P"  |
                                  TablaFAperma$Estrato=="MXnL/S"  |
                                  TablaFAperma$Estrato=="P"  |
                                  TablaFAperma$Estrato=="VHnL/P"
                                ,paste("PRAD-PRAD","--",TablaFAperma$Estrato),
                                paste("TF-TF","--",TablaFAperma$Estrato))
  #DEGRADACION
  TablaFEdegra$DinEstFE<-paste("TF-TFd","--",TablaFEdegra$Estrato)
  
  #RECUPERACI?N
  TablaFArecup$DinEstFE<-paste("TFd-TF","--",TablaFArecup$Estrato)
  
  #REFORESTACI?N
  TablaFArefo$DinEstFE<-ifelse(TablaFArefo$Estrato=="EOTnL/P"  |
                                 TablaFArefo$Estrato=="MXnL/P"  |
                                 TablaFArefo$Estrato=="MXnL/S"  |
                                 TablaFArefo$Estrato=="P"  |
                                 TablaFArefo$Estrato=="VHnL/P"
                               ,paste("OU-PRAD","--",TablaFArefo$Estrato),
                               paste("OU-TF","--",TablaFArefo$Estrato))
  
  #Se crea una s?la base de FE y FA con su respectiva din?mica
  TablaFEFA<-rbind(TablaFEdefor,TablaFEdeforPrad,TablaFAperma,TablaFEdegra,TablaFArecup,TablaFArefo)
  
  #Se le asigna un FE o FA a cada combinaci?n de "Din?mica" y "Estrato"
  BaseTransiS2S3<- merge(BaseTransiS2S3, TablaFEFA, by.x = "DinEstFE", by.y = "DinEstFE",all=TRUE)
  
  #Se estima la Emisi?n/Absorci?n por poligono de cambio/permanencia
  #Se anualiza el ?rea
  BaseTransiS2S3$AreasAnualizada<-ifelse(BaseTransiS2S3$Dinamica=="TF-OU" | BaseTransiS2S3$Dinamica=="TF-PRA"
                                         | BaseTransiS2S3$Dinamica=="PRAD-OU",BaseTransiS2S3$Areas/DifSeries,
                                         BaseTransiS2S3$Areas)
  BaseTransiS2S3$EmisAbs<-BaseTransiS2S3$FE*BaseTransiS2S3$AreasAnualizada
  
  #Se imputa una incertidumbre del Dato de Actividad
  BaseTransiS2S3$U_DA<-0
  
  #Se propaga la incertidumbre del FE y DA
  BaseTransiS2S3$U_FE_DA<-sqrt(BaseTransiS2S3$U^2+BaseTransiS2S3$U_DA^2)
  
  #Se crea una variable para propagar la incertidumbre de la emisi?n por Clase IPCC
  BaseTransiS2S3$Ui2_Ai2<-(BaseTransiS2S3$EmisAbs*BaseTransiS2S3$U_FE_DA)^2
  
  #Se agrega la emisi?n y las incertidumbres a nivel de Clase IPCC
  temp_env2 <<- new.env(hash=T) #hashed environment for easy access
  temp_env2$BaseTransiS2S3 =BaseTransiS2S3
  FunSum <- function(x){c(Sum=sum(x[!is.na(x)]))}
  TablaEmiAbsS2S3<-0
  TablaEmiAbsS2S3<-summaryBy(temp_env2$BaseTransiS2S3$AreasAnualizada + temp_env2$BaseTransiS2S3$EmisAbs + temp_env2$BaseTransiS2S3$Ui2_Ai2 ~ temp_env2$BaseTransiS2S3$Dinamica,
                             data=temp_env2$BaseTransiS2S3, FUN=FunSum,keep.names=TRUE, var.names=c("Area","EmisionesAbsorciones","Ui2_Ai2"))
  length(TablaEmiAbsS2S3$Dinamica)
  rm(temp_env2,envir=.GlobalEnv) # cleanup 
  
  #Se estima la incertidumbre por clase del IPCC
  TablaEmiAbsS2S3$U<-sqrt(TablaEmiAbsS2S3$Ui2_Ai2)/abs(TablaEmiAbsS2S3$EmisionesAbsorciones)
  
  
  
  
  return(new("ResultSet_error_prop",
             TablaEmiAbsS2S3=TablaEmiAbsS2S3,
             TablaFEFA=TablaFEFA,
             BaseTransiS2S3=BaseTransiS2S3,
             module="Estimadores de emission/absorbcion y incertidumbres por clase del IPCC",
             variable="N/A",
             status=TRUE
  )
  )
  
}

