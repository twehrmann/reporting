library(yaml)
config = yaml.load_file("/Volumes/SSD2go_tw/conafor/reporting/config/database.yml")


setClass(Class="ResultSet",
         representation(
           result="data.frame",
           module="character",
           variable="character",
           status="logical"
         )
)

getAllVariables <- function(base) {
  BaseVars = vector(mode="list", length=length(names(base)))
  names(BaseVars) = names(base)
  for (i in 1:length(BaseVars) ) {
    BaseVars[i] = i
  }
  
  return (BaseVars)
}


