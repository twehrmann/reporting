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



