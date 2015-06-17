library(shiny)
library(Carbono5)
list.of.packages <- c("xlsx")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(xlsx)



setwd("/Users/thilo/conafor/R scripts Oswaldo/cliente_pot_carbon")

print("Read data files...")


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
  
  fe_variable=0
  if (fe_variable_gui %in% names(BaseVars)) {
    print (paste("Using FE variable:", fe_variable_gui, " index:", BaseVars[[fe_variable_gui]]))
    fe_variable=BaseT1[,fe_variable_gui]
  } else {
    print(paste("Cannot find EF variable:",fe_variable_gui))
    return(0)
  }
  #fe_variable=BaseT1$carbono_arboles
  
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

shinyServer(function(input, output) {
  dataInput <- reactive({ calcFE(input$selectPC, input$radio) })
  
  output$value <- renderPrint({ input$radio })
  output$value2 <- renderDataTable(dataInput())
  
  output$downloadDataCSV <- downloadHandler(
    filename = c('data.csv'),
    content = function(file) {
      write.csv(dataInput(), file)
    }
  )
  output$downloadDataEXCEL <- downloadHandler(
    filename = c('data.xlsx'),
    content = function(file) {
      paste(tempdir(), file, sep="")
      write.xlsx(dataInput(), file)
    }
  )
  output$metadata <- renderPrint(metadata_baset1)
  
})