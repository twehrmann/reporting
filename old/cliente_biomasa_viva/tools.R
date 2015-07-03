library(yaml)
config = yaml.load_file("/Volumes/SSD2go_tw/conafor/reporting/config/database.yml")


setClass(Class="ResultSet",
         representation(
           result_BaseEstrato="data.frame",
           result_SummTotBv2="data.frame",
           module="character",
           variable="character",
           status="logical"
         )
)



