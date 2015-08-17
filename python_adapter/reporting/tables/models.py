#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Jul 22, 2015

@author: thilo
'''

from flask import Flask
from flask.ext.log import Logging

from sqlalchemy import Table
import sqlsoup

from sqlalchemy.exc import NoSuchTableError

from reporting.config import getConfig
from reporting.tools.table_names import getObservationTable, getUdmTable,\
    getStrataTables, getMetadataTable, getUdmBiomasaTables, getNationalTables,\
    DB_SCHEMA

config = getConfig()

CYCLES_UDM = config["BASE_TABLES_UDM"]

app = Flask(__name__)
with app.app_context():
    # within this block, current_app points to app.
    app.config['FLASK_LOG_LEVEL'] = getConfig()["BASE"]["loglevel"]
    flask_log = Logging(app)

   



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

def get_all_observations(engine, cycle, limit_a=0, limit_b=100):
    schema_name, table_name = getObservationTable(cycle)

    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.slice(limit_a, limit_a+limit_b).all()
    else:
        return list()
    
def get_all_observation_count(engine, cycle):
    schema_name, table_name = getObservationTable(cycle)
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.count()
    else:
        return 0

def get_udm_observations(engine, cycle, udm_id):
    schema_name, table_name = getObservationTable(cycle)
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.filter_by(id_unidad_muestreo=udm_id).all()
    else:
        return list()

def get_udm(engine, udm_id, cycle):
    schema_name, table_name = getUdmTable(cycle)
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.filter_by(id_unidad_muestreo=udm_id).all()
    else:
        return list()
    
def get_all_udm(engine, (limit_a, limit_b), cycle):
    schema_name, table_name = getUdmTable(cycle)
    mapping = readTable(engine, schema_name, table_name)

    if mapping != None:
        return mapping.slice(limit_a, limit_a+limit_b).all()
    else:
        return list()
    
def get_all_udm_count(engine, cycle):
    schema_name, table_name = getUdmTable(cycle)
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.count()
    else:
        return 0
    
def get_biomasa_udm(engine, strata_type, cycle, stock):
    schema_name, table_name = getUdmBiomasaTables(strata_type, cycle, stock)
    
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.all()
    else:
        return list()

def get_strata(engine, subcategory, strata_type, cycle, stock):
    schema_name, table_name = getStrataTables(subcategory, strata_type, cycle, stock)
    
    mapping = readTable(engine, schema_name, table_name)

    if mapping != None:
        return mapping.all()
    else:
        return list()
    
def get_national(engine, strata_type,cycle):
    schema_name, table_name = getNationalTables(strata_type, cycle)
    
    mapping = readTable(engine, schema_name, table_name)
    if mapping != None:
        return mapping.filter(mapping.Dinamica!= None).all()
    else:
        return list()

    
def get_all_metadata(engine):
    schema_name, table_name = getMetadataTable()
    mapping = readTable(engine, schema_name, table_name, prim_key=True)
    if mapping != None:
        return mapping.all()
    else:
        return list()
    
def get_metadata_single_table(engine, db_schema, product_table):
    schema_name, table_name = getMetadataTable()
    mapping = readTable(engine, schema_name, table_name, prim_key=True)

    if mapping != None:
        table_metadata = mapping.filter_by(table_name = product_table, table_scheme = db_schema).first()
        return table_metadata
    else:
        raise Exception("No product table: %s found"%product_table)

