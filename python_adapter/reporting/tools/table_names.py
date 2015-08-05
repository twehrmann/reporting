'''
Created on Aug 5, 2015

@author: thilo
'''
from config import getConfig

config = getConfig()

DB_SCHEMA = config["DB_SCHEMA_RESULTS"]
CYCLES_UDM = config["BASE_TABLES_UDM"]
CYCLES_OBS = config["BASE_TABLES_OBS"]



def getObservationTable(cycle):
    if cycle not in CYCLES_OBS.keys():
        raise Exception("Cycle %s not defined" % cycle)
    
    table_name = CYCLES_OBS[cycle]
    schema_name = config["DB_SCHEMA_BASE"]
    
    return schema_name, table_name

def getUdmTable(cycle):
    if cycle not in CYCLES_UDM.keys():
        raise Exception("Cycle %s not defined" % cycle)
    
    table_name = CYCLES_UDM[cycle]
    schema_name = config["DB_SCHEMA_BASE"]
    
    return schema_name, table_name

def getStrataTables(subcategory, strata_type, cycle, stock):
    schema_name = config["DB_SCHEMA_RESULTS"]
    
    if subcategory.lower() == "tf-tf":
        table_name = str(config["STRATA_DEFINITION"][subcategory.lower()]) % (stock.lower(), strata_type.lower())
    elif subcategory.lower() == "tf-ot":
        table_name = str(config["STRATA_DEFINITION"][subcategory.lower()]) % (stock.lower(), strata_type.lower())
    elif subcategory.lower() == "tfd-tf":
        table_name = str(config["STRATA_DEFINITION"][subcategory.lower()]) % (stock.lower(), strata_type.lower())
    elif subcategory.lower() == "tf-tfd":
        table_name = str(config["STRATA_DEFINITION"][subcategory.lower()]) % (stock.lower(), strata_type.lower())
    else:
        raise Exception("No table mapped to %s,%s,%s,%s"%(subcategory, strata_type, cycle, stock))
    
    return  schema_name, table_name

def getMetadataTable():
    schema_name = config["DB_SCHEMA_RESULTS"]
    table_name = config["BASE"]["metadata_table"]
    
    return  schema_name, table_name