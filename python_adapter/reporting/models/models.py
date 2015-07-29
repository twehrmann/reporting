#!/usr/bin/env python
# -*- coding: utf-8 -*-
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

from tools.config import getConfig
import decimal

config = getConfig()

DB_SCHEMA = config["DB_SCHEMA_RESULTS"]
CYCLES = config["BASE_TABLES_UDM"]




def get_table_object(engine, table_name, limit_a=0, limit_b=100, prim_key=False):
    db = sqlsoup.SQLSoup(engine)
    try:
        pa_t = Table(table_name, db._metadata, autoload=True, schema=DB_SCHEMA)
        if prim_key == False:
            pa = db.map(pa_t)
        else:
            pa = db.map(pa_t, primary_key=[pa_t.c.id])

        return pa.slice(limit_a, limit_b).all()
    except NoSuchTableError:
        return list()
    
def get_view_object(engine, view_name):
    db = sqlsoup.SQLSoup(engine)
    result = list()
    rp = db.execute('select var, count from %s.%s ' % (DB_SCHEMA, view_name))
    for var, count in rp.fetchall():
        result.append((var, count))
        
    return result
    

def readTable(engine, scheme, table, prim_key=False):
    db = sqlsoup.SQLSoup(engine)
    print "Accessing table %s.%s" % (scheme, table)

    try:
        observation_table = Table(table, db._metadata, autoload=True, schema=scheme)
        if prim_key == False:
            table_data = db.map(observation_table)
        else:
            table_data = db.map(observation_table, primary_key=[observation_table.c.id])

        return table_data
    except NoSuchTableError, err:
        print err
        return None

def get_all_observations(engine, limit_a=0, limit_b=100):
    table_name = config["BASE_TABLES_OBS"]["T1"]
    schema_name = config["DB_SCHEMA_BASE"]
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.slice(limit_a, limit_b).all()
    else:
        return list()

def get_udm_observations(engine, udm_id):
    table_name = config["BASE_TABLES_OBS"]["T1"]
    schema_name = config["DB_SCHEMA_BASE"]
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.filter_by(id_unidad_muestreo=udm_id).all()
    else:
        return list()

def get_udm(engine, udm_id, cycle):
    if cycle not in CYCLES.keys():
        return list()
    
    table_name = CYCLES[cycle]
    schema_name = config["DB_SCHEMA_BASE"]
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.filter_by(id_unidad_muestreo=udm_id).all()
    else:
        return list()
    
def get_all_udm(engine, (limit_a, limit_b), cycle):
    if cycle not in CYCLES.keys():
        return list()
    
    table_name = CYCLES[cycle]
    schema_name = config["DB_SCHEMA_BASE"]
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.slice(limit_a, limit_b).all()
    else:
        return list()

def get_strata(engine, subcategory, strata_type, cycle, stock):
    table_name = None
    if subcategory.lower() == "tf-tf":
        table_name = str(config["STRATA_DEFINITION"][subcategory.lower()]) % (stock.lower(), strata_type.lower())
    elif subcategory.lower() == "tf-ot":
        table_name = str(config["STRATA_DEFINITION"][subcategory.lower()]) % (stock.lower(), strata_type.lower())
    elif subcategory.lower() == "tfd-tf":
        table_name = str(config["STRATA_DEFINITION"][subcategory.lower()]) % (stock.lower(), strata_type.lower())
    elif subcategory.lower() == "tf-tfd":
        table_name = str(config["STRATA_DEFINITION"][subcategory.lower()]) % (stock.lower(), strata_type.lower())
    
    if table_name == None:
        return list()
    mapping = readTable(engine, DB_SCHEMA, table_name)
    if mapping != None:
        return mapping.all()
    else:
        return list()
    
def get_all_metadata(engine):
    table_name = config["BASE"]["metadata_table"]
    mapping = readTable(engine, DB_SCHEMA, table_name, prim_key=True)
    if mapping != None:
        return mapping.all()
    else:
        return list()
