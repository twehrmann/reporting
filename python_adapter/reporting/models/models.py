'''
Created on Jul 22, 2015

@author: thilo
'''

from sqlalchemy import Table
import sqlsoup
import json

from sqlalchemy.ext.declarative import DeclarativeMeta
from sqlsoup import TableClassType
from sqlalchemy.exc import NoSuchTableError


class AlchemyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj.__class__, TableClassType):
            # an SQLAlchemy class
            fields = {}
            for field in [x for x in dir(obj) if not x.startswith('_') and x != 'metadata']:
                data = obj.__getattribute__(field)
                try:
                    print "X",field
                    if field != "c":    # eliminate column names
                        json.dumps(data) # this will fail on non-encodable values, like other classes
                        fields[field] = data
                except TypeError:
                    fields[field] = None
            # a json-encodable dict
            return fields
    
        return json.JSONEncoder.default(self, obj)


def get_table_object(engine, table_name, limit_a=0, limit_b=100):
    db_schema = "client_output"
    db = sqlsoup.SQLSoup(engine)
    try:
        pa_t = Table(table_name, db._metadata, autoload=True, schema=db_schema)
        pa = db.map(pa_t)

        return pa.slice(limit_a,limit_b).all()
    except NoSuchTableError:
        return list()


if __name__ == '__main__':
    for item in get_table_object("fe_pot_strata_carbono_arboles_bur"):
        print item.Estrato
        
    print json.dumps(get_table_object("fe_pot_strata_carbono_arboles_bur"), cls=AlchemyEncoder)
    


        