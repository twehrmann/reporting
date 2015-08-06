'''
Created on Aug 6, 2015

@author: thilo
'''
import json
from sqlsoup import TableClassType

import collections
import datetime
from config import getConfig
import decimal


config = getConfig()

def sqlAlchemy2Dict(obj, shortenString=False):
    if isinstance(obj.__class__, TableClassType):
        # an SQLAlchemy class
        structure = collections.OrderedDict()
        for field in [x for x in dir(obj) if not x.startswith('_') and x != 'metadata']:
            data = obj.__getattribute__(field)
            #print data, type(data)
            
            # Format variables
            if isinstance(data, datetime.date):
                data = data.strftime(config["BASE"]["date_fmt"])
            if isinstance(data, datetime.datetime):
                data = data.strftime(config["BASE"]["timestamp_fmt"])
            if isinstance(data, decimal.Decimal):
                    data = float(data)
                    
            if isinstance(data, float):
                if int(float(data)) == data:
                    data = int(float(data))
                else:
                    data = float(config["BASE"]["float_fmt"] % data)
            if isinstance(data, str) or isinstance(data, unicode):
                if len(data) > int(config["BASE"]["max_string_length"]) and shortenString:
                    data = data[:config["BASE"]["max_string_length"]]+"..."
            try:
                if field != "c":  # eliminate column names
                    json.dumps(data)  # this will fail on non-encodable values, like other classes
                    structure[field] = data
            except TypeError, error:
                print error
                print field, data, type(data)
                structure[field] = None

        return structure
    
def transformStructure(obs, mode, translation, shortenString=False):
    structure = list()
    if len(obs) > 0:
        if mode != None:
            if mode in translation.keys():
                structure.append({"structure":translation[mode]})
                for item in obs:
                    structure.append({k: v for k, v in sqlAlchemy2Dict(item, shortenString).items() if k in translation[mode]})
        else:
            structure.append({"structure":sqlAlchemy2Dict(obs[0]).keys()})
            for item in obs:
                structure.append(sqlAlchemy2Dict(item, shortenString))
        return structure
    else:
        return None


