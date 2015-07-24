'''
Created on Jul 22, 2015

@author: thilo
'''

from sqlalchemy import Table
import sqlsoup
import json

from sqlsoup import TableClassType
from sqlalchemy.exc import NoSuchTableError
from sqlalchemy.orm import load_only

DB_SCHEMA = "client_output"
CYCLES = {"T1":"calculo_sitio_v20_t1", "T2":"calculo_sitio_v20_t2"}

class AlchemyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj.__class__, TableClassType):
            # an SQLAlchemy class
            fields = {}
            for field in [x for x in dir(obj) if not x.startswith('_') and x != 'metadata']:
                data = obj.__getattribute__(field)
                try:
                    if field != "c":    # eliminate column names
                        json.dumps(data) # this will fail on non-encodable values, like other classes
                        fields[field] = data
                except TypeError:
                    fields[field] = None
            # a json-encodable dict
            return fields
    
        return json.JSONEncoder.default(self, obj)


def get_table_object(engine, table_name, limit_a=0, limit_b=100):
    db = sqlsoup.SQLSoup(engine)
    try:
        pa_t = Table(table_name, db._metadata, autoload=True, schema=DB_SCHEMA)
        pa = db.map(pa_t)

        return pa.slice(limit_a,limit_b).all()
    except NoSuchTableError:
        return list()
    
def get_view_object(engine, view_name):
    db = sqlsoup.SQLSoup(engine)
    result = list()
    rp = db.execute('select var, count from %s.%s '% (DB_SCHEMA,view_name))
    for var,count in rp.fetchall():
        result.append((var, count))
        
    return result

if __name__ == '__main__':
    for item in get_table_object("fe_pot_strata_carbono_arboles_bur"):
        print item.Estrato
        
    print json.dumps(get_table_object("fe_pot_strata_carbono_arboles_bur"), cls=AlchemyEncoder)
    

def readTable(engine, scheme, table):
    db = sqlsoup.SQLSoup(engine)
    print "Accessing table %s.%s" % (scheme, table)

    try:
        observation_table = Table(table, db._metadata, autoload=True, schema=scheme)
        table_data = db.map(observation_table)

        return table_data
    except NoSuchTableError, err:
        print err
        return None

def get_all_observations(engine, limit_a=0, limit_b=100):
    table_name = "calculo_20140303_CarbonoArbolado_raices_caso1y2"
    schema_name = "mssql"
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.slice(limit_a,limit_b).all()
    else:
        return list()

def get_udm_observations(engine, udm_id):
    table_name = "calculo_20140303_CarbonoArbolado_raices_caso1y2"
    schema_name = "mssql"
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.filter_by(id_unidad_muestreo=udm_id).all()
    else:
        return list()

def get_udm(engine, udm_id, cycle):
    if cycle not in CYCLES.keys():
        return list()
    
    table_name = CYCLES[cycle]
    schema_name = "mssql"
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.filter_by(id_unidad_muestreo=udm_id).all()
    else:
        return list()
    
def get_all_udm(engine, (limit_a, limit_b), cycle):
    if cycle not in CYCLES.keys():
        return list()
    
    table_name = CYCLES[cycle]
    schema_name = "mssql"
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.slice(limit_a,limit_b).all()
    else:
        return list()

def get_strata(engine, subcategory, strata_type, cycle, stock):
    if subcategory.lower() == "tf-tf":
        table_name= "fe_delta_strata_%s_%s" % (stock.lower(), strata_type.lower())
    elif subcategory.lower() == "tf-ot":
        table_name = "fe_pot_strata_%s_%s" % (stock.lower(), strata_type.lower())
    elif subcategory.lower() == "tf-tf":
        pass
    elif subcategory.lower() == "tf-tf":
        pass
    
    mapping = readTable(engine, DB_SCHEMA, table_name)
    if mapping != None:
        return mapping.all()
    else:
        return list()
