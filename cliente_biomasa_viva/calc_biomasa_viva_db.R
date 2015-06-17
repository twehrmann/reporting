
source("tools.R")
source("db_access.R")
source("calc_biomasa_viva.R")

print("Read data files...")
inputData = getBaseData()

data=calcBiomasaViva("carbono_arboles","BUR", inputData)
print (data)
DB_SCHEME="client_output"
db_table_name = c(DB_SCHEME,"biomasa_viva")
success=storeResults(db_table_name, data)
print (success)
