#setwd("/Users/thilo/conafor/R scripts Oswaldo/cliente_pot_carbon")
setwd("/srv/shiny-server/cliente_delta_carbon")


print("Read FE variables")
metadata_baset1 = "Calculo_20140421_CarbonoSitio(2004-2012)_VERSION_19_raices_CASO1y2_TOTALESt1.csv"
BaseT1_orig<-read.csv(metadata_baset1,header=TRUE,nrows=10)



BaseVars = vector(mode="list", length=length(names(BaseT1_orig)))
names(BaseVars) = names(BaseT1_orig)
for (i in 1:length(BaseVars) ) {
  BaseVars[i] = names(BaseT1_orig)[i]
}

getAllVariables <- function() {
  return (BaseVars)
}

vars = getAllVariables()
varList = list("total_carbono"="total_carbono",
               "carbono_arboles"="carbono_arboles",
               "carbono_tocones"="carbono_tocones",
               "carbono_muertospie"="carbono_muertospie",
               "total_carbono"="total_carbono",
               "biomasa_arboles"="biomasa_arboles",
               "biomasa_tocones"="biomasa_tocones",
               "biomasa_muertospie"="biomasa_muertospie",
               "total_biomasa"="total_biomasa",
               "carbono_raices_por_sitio"="carbono_raices_por_sitio",
               "biomasa_raices_por_sitio"="biomasa_raices_por_sitio"
)
selectedVars = list()



shinyUI(fluidPage(
  titlePanel(h1( "Cliente del sistema de FE")             
  ),
  sidebarLayout(
    sidebarPanel( 
      radioButtons("radio", label = h3("clasificacion"),
                   choices = list("BUR" = "BUR"),selected = "BUR"),
      h3("Carbon pool"),
      selectInput("selectPC", label = "FE variable", 
                  choices = varList, 
                  selected = "total_carbono")
      
    ),
    mainPanel(
      h2("Resultado"),
      hr(),
      h4("Metadata:"),
      p(paste("metadata_baset1:","bla")),
      downloadButton('downloadDataCSV','Save Data as CSV File'),
      downloadButton('downloadDataEXCEL','Save Data as Excel File'),
      hr(),
      
      fluidRow(dataTableOutput("value2")),
      hr()
      
    )
  )
))