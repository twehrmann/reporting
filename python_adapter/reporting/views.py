#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Jul 24, 2015

@author: thilo
'''

from flask import Flask
from flask.ext.log import Logging

from models.models import get_all_observations, \
    get_udm_observations, get_udm, get_all_udm, get_strata, get_all_metadata,\
    get_metadata_single_table, get_biomasa_udm, get_national
    
from html import HTML
from config import getConfig, OBS_COLUMN_MAPPER, UDM_COLUMN_MAPPER,\
    STRATA_COLUMN_MAPPER, UDM_BIOMASA_MAPPER
from tools.converter import transformStructure
from tools.table_names import DB_SCHEMA


app = Flask(__name__)
with app.app_context():
    # within this block, current_app points to app.
    app.config['FLASK_LOG_LEVEL'] = getConfig()["BASE"]["loglevel"]
    flask_log = Logging(app)

    



def view_observations(engine, cycle, (a, b), mode=None):
    app.logger.info("OBSERVATION VIEW for %s between %s:%s [%s]" % (cycle, a, b, mode))
    if mode not in OBS_COLUMN_MAPPER.keys():
        mode = None
    obs = get_all_observations(engine,cycle,  a, b)
    return transformStructure(obs, mode, OBS_COLUMN_MAPPER, shortenString=True)
   

def view_single_observations(engine, cycle, udm_id, mode=None):
    app.logger.info("SINGLE OBSERVATION VIEW for %s if udm_id %d" % (cycle, udm_id))
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
    app.logger.info("UDM VIEW for %s between %s:%s [%s]" % (cycle, a, b, mode))
    if mode not in UDM_COLUMN_MAPPER.keys():
        mode = None
    obs=get_all_udm(engine, (a,b), cycle)
    return transformStructure(obs, mode, UDM_COLUMN_MAPPER)

def view_udm(engine, strata_type, cycle, stock, mode):
    if mode not in UDM_BIOMASA_MAPPER.keys():
        mode = None
    
    obs=get_biomasa_udm(engine, strata_type, cycle, stock)
    return transformStructure(obs, mode, UDM_BIOMASA_MAPPER)


def view_strata(engine, subcategory, strata_type, cycle, stock, mode):
    if mode not in STRATA_COLUMN_MAPPER.keys():
        mode = None
    
    obs=get_strata(engine, subcategory, strata_type, cycle, stock)
    return transformStructure(obs, mode, STRATA_COLUMN_MAPPER)

def view_national(engine, strata_type, cycle):
        
    obs=get_national(engine, strata_type, cycle)
    return transformStructure(obs, None, STRATA_COLUMN_MAPPER)

def view_metadata(engine):
    metadata=get_all_metadata(engine)
    return transformStructure(metadata, None, None)

def view_metadata_table(engine,tablename):
    metadata=get_metadata_single_table(engine, DB_SCHEMA, tablename)
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