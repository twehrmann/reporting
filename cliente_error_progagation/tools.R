library(yaml)
config = yaml.load_file("/Volumes/SSD2go_tw/conafor/reporting/config/database.yml")


setClass(Class="ResultSet",
         representation(
           TablaEmiAbsS2S3="data.frame",
           TablaFEFA="data.frame",
           BaseTransiS2S3="data.frame",
           module="character",
           variable="character",
           status="logical"
         )
)


