#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Jul 24, 2015

@author: thilo
'''
from models.models import get_all_observations, \
    get_udm_observations, get_udm, get_all_udm, get_strata, get_all_metadata,\
    get_metadata_single_table
import json
from sqlsoup import TableClassType
from html import HTML
import collections
import datetime
from config import getConfig
import decimal


config = getConfig()

OBS_COLUMN_MAPPER = config["OBS_COLUMN_MAPPER"]
UDM_COLUMN_MAPPER = config["UDM_COLUMN_MAPPER"]
STRATA_COLUMN_MAPPER = config["STRATA_COLUMN_MAPPER"]


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



def view_observations(engine, cycle, (a, b), mode=None):
    if mode not in OBS_COLUMN_MAPPER.keys():
        mode = None
    obs = get_all_observations(engine,cycle,  a, b)
    return transformStructure(obs, mode, OBS_COLUMN_MAPPER, shortenString=True)
   

def view_single_observations(engine, cycle, udm_id, mode=None):
    if mode not in OBS_COLUMN_MAPPER.keys():
        mode = None     
    obs = get_udm_observations(engine, cycle, udm_id)
    return transformStructure(obs, mode, OBS_COLUMN_MAPPER, shortenString=True)


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

def view_metadata(engine):
    metadata=get_all_metadata(engine)
    return transformStructure(metadata, None, None)

def view_metadata_table(engine,tablename):
    metadata=get_metadata_single_table(engine, tablename)
    return transformStructure(metadata, None, None)


def makeHtmlTable(table_data, title=None):
    h = HTML()
    if title != None:
        h.title(title)
        
    t = h.table(border='1')
    
    if len(table_data) > 0:
        r = t.tr
        keys=table_data[0]["structure"]
        for key in keys:
            r.th(key)
        r.tr

        for row in table_data[1:]:      
            for item in keys:
                r.td(unicode(row[item]))    
            r.tr
    return unicode(h)