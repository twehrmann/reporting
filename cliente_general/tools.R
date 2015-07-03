assign("last.warning", NULL, envir = baseenv())
options(error=recover)

library(WriteXLS)
library(logging)
basicConfig()

library(yaml)
config = yaml.load_file("/Volumes/SSD2go_tw/conafor/reporting/config/database.yml")
OUTPUT_PATH = config$results$output_dir
DB_SCHEME=config$results$db_schema
BASE_VERSION = config$results$base_model_version



# Result representation for carbono5 module
setClass(Class="ResultSet_carbono5",
         representation(
           result="data.frame",
           module="character",
           variable="character",
           status="logical"
         )
)

# Result representation for dcarbono module
setClass(Class="ResultSet_dcarbono",
         representation(
           result="data.frame",
           module="character",
           variable="character",
           status="logical"
         )
)

# Result representation for biomasa viva module
setClass(Class="ResultSet_biomasa_sitio",
         representation(
           result_BaseEstrato="data.frame",
           result_SummTotBv2="data.frame",
           module="character",
           variable="character",
           status="logical"
         )
)

# Result representation for error propagation module
setClass(Class="ResultSet_error_prop",
         representation(
           TablaEmiAbsS2S3="data.frame",
           TablaFEFA="data.frame",
           BaseTransiS2S3="data.frame",
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

storeResultCSV <- function(filename, data) {
  loginfo(paste("Writing result to CSV file",filename))
  write.csv(data, file = filename)
  return(TRUE)
}

storeResultExcel <- function(filename, data) {
  loginfo(paste("Writing result to XLS file",filename))
  WriteXLS("data", ExcelFileName = filename)
  return(TRUE)
}