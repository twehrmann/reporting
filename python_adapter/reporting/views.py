'''
Created on Jul 24, 2015

@author: thilo
'''
from models.models import get_all_observations, AlchemyEncoder,\
    get_udm_observations, get_udm, get_all_udm, get_strata
import json
from sqlsoup import TableClassType
from html import HTML


OBS_COLUMN_MAPPER = {"arbolado_vivo":["id_unidad_muestreo", "numero_arbol", "carbono_arboles"]}
UDM_COLUMN_MAPPER = {}
STRATA_COLUMN_MAPPER = {"short":["Estrato", "NumCong", "NumSitios", "AreaHa", "ER", "U"]}

def sqlAlchemy2Dict(obj):
    if isinstance(obj.__class__, TableClassType):
        # an SQLAlchemy class
        structure = {}
        for field in [x for x in dir(obj) if not x.startswith('_') and x != 'metadata']:
            data = obj.__getattribute__(field)
            try:
                if field != "c":  # eliminate column names
                    json.dumps(data)  # this will fail on non-encodable values, like other classes
                    structure[field] = data
            except TypeError:
                structure[field] = None

        return structure
    
def transformStructure(obs, mode, translation):
    structure = list()
    
    if mode != None:
        for item in obs:
            structure.append({k: v for k, v in sqlAlchemy2Dict(item).items() if k in translation[mode]})
    else:
        for item in obs:
            structure.append(sqlAlchemy2Dict(item))
    
    return structure



def view_observations(engine, (a, b), mode=None):
    if mode not in OBS_COLUMN_MAPPER.keys():
        mode = None
    obs = get_all_observations(engine, a, b)
    return transformStructure(obs, mode, OBS_COLUMN_MAPPER)
   

def view_single_observations(engine, udm_id, mode=None):
    if mode not in OBS_COLUMN_MAPPER.keys():
        mode = None     
    obs = get_udm_observations(engine, udm_id)
    return transformStructure(obs, mode, OBS_COLUMN_MAPPER)


def view_single_udm(engine, udm_id,cycle, mode=None):
    if mode not in UDM_COLUMN_MAPPER.keys():
        mode = None
    obs=get_udm(engine, udm_id, cycle)
    return transformStructure(obs, mode, UDM_COLUMN_MAPPER)


def view_all_udm(engine, (a,b),cycle, mode=None):
    if mode not in UDM_COLUMN_MAPPER.keys():
        mode = None
    obs=get_all_udm(engine, (a,b), cycle)
    return transformStructure(obs, mode, UDM_COLUMN_MAPPER)

def view_strata(engine, subcategory, strata_type, cycle, stock, mode):
    if mode not in STRATA_COLUMN_MAPPER.keys():
        mode = None
    
    obs=get_strata(engine, subcategory, strata_type, cycle, stock)
    return transformStructure(obs, mode, STRATA_COLUMN_MAPPER)

def makeHtmlTable(table_data):
    h = HTML()
    t = h.table(border='1')
 
    if len(table_data) > 0:
        r = t.tr
        header = list()
        
        for counter, row in enumerate(table_data):
            keys = row.keys()
            keys.sort()
            if counter == 0:
                for item in keys:
                    r.th(item)
                r.tr
                
            for item in keys:
                r.td(str(row[item]))            
            r.tr
    return str(h)