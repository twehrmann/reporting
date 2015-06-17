
source("tools.R")
source("db_access.R")
source("calc_error_prop.R")

inputData = getBaseData()


data=0
DB_SCHEME="client_output"
db_table_name = c(DB_SCHEME,"FE_emisiones_abs_s2s3")

data=calcErrorProp(inputData)
success = storeResults(db_table_name, data@TablaEmiAbsS2S3)
print(success)

db_table_name = c(DB_SCHEME,"TablaFEFA")
success = storeResults(db_table_name, data@TablaFEFA)
print(success)

db_table_name = c(DB_SCHEME,"BaseTransiS2S3")
success = storeResults(db_table_name, data@BaseTransiS2S3)
print(success)


