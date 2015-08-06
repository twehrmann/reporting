#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Jul 22, 2015

@author: thilo
'''

from flask import Flask, abort, url_for, Response, request
import os, json
from models.models import get_view_object, get_metadata_single_table

from flask_sqlalchemy import SQLAlchemy
from tools.cross_domain import crossdomain
from html import HTML
from flask.ext.script import Manager
from flask.ext.log import Logging

from views import view_observations, view_single_observations, view_single_udm, \
    view_all_udm, view_strata, makeHtmlTable, view_metadata, view_metadata_table, \
    view_udm
from config import getConfig
from tools.output_formats import makeJsonResponse, makeHtmlReponse, \
    makeExcelResponse, ExcelReport
from tools.table_names import getObservationTable, getUdmTable, getStrataTables, \
    getUdmBiomasaTables
import time
import datetime
from tools.r_calculation import code, BASE, CARBONO5, DCARBONO, BIOMASA, \
    RECUPERATION, FEFA
from collections import OrderedDict


config = getConfig()
MAX_DEF_RESULT = 100

app = Flask(__name__)
app.config.from_object(os.environ['APP_SETTINGS'])
app.config['FLASK_LOG_LEVEL'] = config["BASE"]["loglevel"]
app.debug = True
flask_log = Logging(app)

manager = Manager(app)

db = SQLAlchemy()
db.init_app(app)


@app.route('/reports.<resource_format>')
def list_reports(resource_format):
    engine = db.get_engine(app)

    report_overview = dict()
    report_overview["categories"] = dict()
    report_overview["categories"]["level"] = list()
    report_overview["categories"]["stock"] = list()
    report_overview["categories"]["lcc"] = list()
    report_overview["categories"]["module"] = list()
    report_overview["categories"]["cycle"] = list()
    
    report_overview["niveles"] = dict()
    report_overview["niveles"]["Observación"] = {"order":0, "title":"Observación", "description":"Aquí se muestran las estimaciones de carbono de los individuos (árboles, muertos en pie, tocones, etc) medidos en el INFyS."}
    report_overview["niveles"]["Unidad de muestreo"] = {"order":1, "title":"Unidad de muestreo", "description":"En este nivel de reporte se agrega las estimaciones de carbono a nivel de la unidad de muestro de cada variable (arbolado vivo, MLC, hojarasca, suelo)"}
    report_overview["niveles"]["Estrato"] = {"order":2, "title":"Estrato", "description":"Los estratos corresponden a los esquemas de clasificación al cual se desean obtener los Factores de Emisión (MAD-Mex, INEGI agregado)"}
    report_overview["niveles"]["Nacional"] = {"order":3, "title":"Nacional", "description":"Esquemas de reporte a nivel nacional: INEGEI, FRA, REDD+, etc"}
    
    report_overview["niveles"]["Observación"]["level"] = "observation"
    report_overview["niveles"]["Observación"]["stocks"] = dict()
    report_overview["niveles"]["Observación"]["stocks"]["Arbolado vivo"] = {"order":0, "var":"carbono_arboles"}
    report_overview["niveles"]["Observación"]["stocks"]["Arboles muertos en pie"] = {"order":1, "var":"carbono_muertospie"}
    report_overview["niveles"]["Observación"]["stocks"]["Tocones"] = {"order":2, "var":"carbono_tocones"}
    report_overview["niveles"]["Observación"]["stocks"]["Hojarasca"] = {"order":3, "var":"NA"}
    report_overview["niveles"]["Observación"]["stocks"]["Suelos"] = {"order":4, "var":"NA"}
    
    report_overview["niveles"]["Unidad de muestreo"]["level"] = "sitio"
    report_overview["niveles"]["Unidad de muestreo"]["stocks"] = dict()
    report_overview["niveles"]["Unidad de muestreo"]["stocks"]["Arbolado vivo"] = {"order":0, "var":"carbono_arboles"}
    report_overview["niveles"]["Unidad de muestreo"]["stocks"]["Arboles muertos en pie"] = {"order":1, "var":"carbono_muertospie"}
    report_overview["niveles"]["Unidad de muestreo"]["stocks"]["Tocones"] = {"order":2, "var":"carbono_tocones"}
    report_overview["niveles"]["Unidad de muestreo"]["stocks"]["MLC"] = {"order":3, "var":"NA"}
    report_overview["niveles"]["Unidad de muestreo"]["stocks"]["Hojarasca"] = {"order":4, "var":"NA"}
    report_overview["niveles"]["Unidad de muestreo"]["stocks"]["Suelos"] = {"order":5, "var":"NA"}
    
    report_overview["niveles"]["Estrato"]["level"] = "strata"
    report_overview["niveles"]["Estrato"]["stocks"] = dict()
    report_overview["niveles"]["Estrato"]["stocks"]["Arbolado vivo"] = {"order":0, "var":"carbono_arboles"}
    report_overview["niveles"]["Estrato"]["stocks"]["Arboles muertos en pie"] = {"order":1, "var":"carbono_muertospie"}
    report_overview["niveles"]["Estrato"]["stocks"]["Tocones"] = {"order":2, "var":"carbono_tocones"}
    report_overview["niveles"]["Estrato"]["stocks"]["MLC"] = {"order":3, "var":"NA"}
    report_overview["niveles"]["Estrato"]["stocks"]["Hojarasca"] = {"order":4, "var":"NA"}
    report_overview["niveles"]["Estrato"]["stocks"]["Suelos"] = {"order":5, "var":"NA"}
    
    report_overview["niveles"]["Estrato"]["subcategory"] = dict()
    report_overview["niveles"]["Estrato"]["subcategory"]["TF:TF"] = {"title":"Tierras Forestales convertidas en Tierras Forestales", "module":"dcarbono"}
    report_overview["niveles"]["Estrato"]["subcategory"]["TFd:TF"] = {"title":"Tierras Forestales  degradadas convertidas en Tierras Forestales", "module":"recup"}
    report_overview["niveles"]["Estrato"]["subcategory"]["TF:TFd"] = {"title":"Tierras Forestales convertidas en Tierras Forestales degradadas", "module":"degrad"}
    report_overview["niveles"]["Estrato"]["subcategory"]["TF:OT"] = {"title":"Tierras Forestales convertidas en Otras Tierras", "module":"carbono5"}
    report_overview["niveles"]["Estrato"]["subcategory"]["OT:TF"] = {"title":"Otras Tierras convertidas en Tierras Forestales", "module":"carbono5"}
    
    report_overview["niveles"]["Estrato"]["stratification"] = dict()
    report_overview["niveles"]["Estrato"]["stratification"]["BUR"] = {"title":"INEGI (Agrupado en las clases del BUR)", "lcc":"BUR"}
    report_overview["niveles"]["Estrato"]["stratification"]["FRA"] = {"title":"INEGI (Agrupado en las clases del BUR)", "lcc":"FRA"}
    report_overview["niveles"]["Estrato"]["stratification"]["MADMEX"] = {"title":"Madmex 32 clases", "lcc":"MADMEX"}
    report_overview["niveles"]["Estrato"]["stratification"]["INEGI@MADMEX"] = {"title":"INEGI (Agrupado en las clases del MADMEX)", "lcc":"INEGI"}
    
    report_overview["niveles"]["Estrato"]["period"] = dict()
    report_overview["niveles"]["Estrato"]["period"]["T1"] = {"title":"2004-2007"}
    report_overview["niveles"]["Estrato"]["period"]["T2"] = {"title":"2009-2014"}
    
    report_overview["niveles"]["Nacional"]["subcategory"] = dict()
    report_overview["niveles"]["Nacional"]["subcategory"]["BUR"] = {"title":"Inventario Nacional  de Gases de Efecto Invernadero en el sector de Uso de Suelo y Cambio de Uso de Suelo (INGEI-USCUS) en las categorías Tierras Forestales, Praderas y Deforestación", "enabled":True}
    report_overview["niveles"]["Nacional"]["subcategory"]["REDD+"] = {"title":"Reporte REDD+", "enabled":True}
    report_overview["niveles"]["Nacional"]["subcategory"]["FRA"] = {"title":"Reporte Anual Forestal (FRA)", "enabled":False}
    report_overview["niveles"]["Nacional"]["subcategory"]["NRE"] = {"title":"Niveles de Referencia de Emisiones (NRE)", "enabled":False}
    
    table_data = get_view_object(engine, "v_lcc")
    for item in table_data:
        report_overview["categories"]["lcc"].append(item[0])
        
    table_data = get_view_object(engine, "v_levels")
    for item in table_data:
        report_overview["categories"]["level"].append(item[0])
        
    table_data = get_view_object(engine, "v_modules")
    for item in table_data:
        report_overview["categories"]["module"].append(item[0])
        
    table_data = get_view_object(engine, "v_stock_types")
    for item in table_data:
        report_overview["categories"]["stock"].append(item[0])
    
      
    json_response = json.dumps(report_overview)
    response = Response(json_response, content_type='application/json; charset=utf-8')
    response.headers.add('content-length', len(json_response))
    response.status_code = 200
    return response


@app.route('/report/observation/T<int:cycle>.<resource_format>')
@crossdomain(origin='*')
def observation_json(cycle, resource_format):
    view_mode = request.args.get('mode')
    a = int(float(request.args.get('from', default=0)))
    b = int(float(request.args.get('to', default=MAX_DEF_RESULT)))
   
    app.logger.debug('Observation range %d - %d' % (a, b))
    engine = db.get_engine(app)
    obs = view_observations(engine, "T%d" % cycle, (a, b), view_mode)
    
    if resource_format == "json":
        return makeJsonResponse(obs)
    elif resource_format == "html":
        return makeHtmlReponse(makeHtmlTable(obs, title='Observation range id: %d - %d' % (a, b)))
    elif resource_format == "xls":
        db_schema, tablename = getObservationTable(cycle)
        excel = ExcelReport()
        excel.filename = "reporte_nivel_observacion"
        excel.metadata = get_metadata_single_table(engine, db_schema, tablename)
        excel.setSource(cycle)

        return makeExcelResponse(obs, excel)

    
    
        
@app.route('/report/observation/T<int:cycle>/<int:udm_id>.<resource_format>')
@crossdomain(origin='*')
def observation_udm_json(cycle, udm_id, resource_format):
    udm_id = int(float(udm_id))
    view_mode = request.args.get('mode')

    engine = db.get_engine(app)
    obs = view_single_observations(engine, "T%d" % cycle, udm_id, mode=view_mode)
    
    if obs != None:
        if resource_format == "json":
            return makeJsonResponse(obs)
        elif resource_format == "html":
            return makeHtmlReponse(makeHtmlTable(obs))
        elif resource_format == "xls":
            db_schema, tablename = getObservationTable(cycle)
        excel = ExcelReport()
        excel.filename = "reporte_nivel_observacion"
        excel.metadata = get_metadata_single_table(engine, db_schema, tablename)
        excel.setSource(cycle)
        return makeExcelResponse(obs, excel)
    else:
        abort(404)
        

@app.route('/report/udm/T<int:cycle>/<int:id>.<resource_format>')
@crossdomain(origin='*')
def single_udm_json(cycle, id, resource_format):
    view_mode = request.args.get('mode')
    engine = db.get_engine(app)
    obs = view_single_udm(engine, id, "T%d" % cycle, view_mode)
    
    if obs != None:
        if resource_format == "json":
            return makeJsonResponse(obs)
        elif resource_format == "html":
            return makeHtmlReponse(makeHtmlTable(obs))
        elif resource_format == "xls":
            db_schema, tablename = getUdmTable(cycle)
            excel = ExcelReport()
            excel.filename = "reporte_nivel_udm_%d" % id
            excel.metadata = get_metadata_single_table(engine, db_schema, tablename)
            excel.setSource(cycle)
            return makeExcelResponse(obs, excel)
    else:
        abort(404)
        
@app.route('/report/udm/T<int:cycle>.<resource_format>')
@crossdomain(origin='*')
def all_udm_json(cycle, resource_format):
    view_mode = request.args.get('mode')
    a = int(float(request.args.get('from', default=0)))
    b = int(float(request.args.get('to', default=MAX_DEF_RESULT)))
    cycle = "T%d" % cycle
    engine = db.get_engine(app)
    obs = view_all_udm(engine, (a, b), cycle, view_mode)
    
    if len(obs) > 0:
        if resource_format == "json":
            return makeJsonResponse(obs)
        elif resource_format == "html":
            return makeHtmlReponse(makeHtmlTable(obs))
        elif resource_format == "xls":
            db_schema, tablename = getUdmTable(cycle)
            excel = ExcelReport()
            excel.filename = "reporte_nivel_udm"
            excel.metadata = get_metadata_single_table(engine, db_schema, tablename)
            excel.setSource(cycle)
            return makeExcelResponse(obs, excel)
    else:
        abort(404)
 
@app.route('/report/udm/<strata_type>/T<int:cycle>/<stock>.<resource_format>')
@crossdomain(origin='*')
def single_udm(strata_type, cycle, stock, resource_format):
    view_mode = request.args.get('mode', "all")
    engine = db.get_engine(app)
    cycle = "T%d" % cycle
    obs = view_udm(engine, strata_type, cycle, stock, view_mode)

    if len(obs) > 0:
        if resource_format == "json":
            return makeJsonResponse(obs)
        elif resource_format == "html":
            return makeHtmlReponse(makeHtmlTable(obs))
        elif resource_format == "xls":
            db_schema, tablename = getUdmBiomasaTables(strata_type, cycle, stock)
            excel = ExcelReport()
            excel.filename = "reporte_nivel_strata"
            excel.metadata = get_metadata_single_table(engine, db_schema, tablename)
            excel.setSource(cycle)
            return makeExcelResponse(obs, excel)
    else:
        abort(404)
               
@app.route('/report/strata/<subcategory>/<strata_type>/T<int:cycle>/<stock>.<resource_format>')
@crossdomain(origin='*')
def single_strata(subcategory, strata_type, cycle, stock, resource_format):
    view_mode = request.args.get('mode')
    engine = db.get_engine(app)
    cycle = "T%d" % cycle
    
    obs = view_strata(engine, subcategory, strata_type, cycle, stock, view_mode)
    
    if len(obs) > 0:
        if resource_format == "json":
            return makeJsonResponse(obs)
        elif resource_format == "html":
            return makeHtmlReponse(makeHtmlTable(obs))
        elif resource_format == "xls":
            db_schema, tablename = getStrataTables(subcategory, strata_type, cycle, stock)
            excel = ExcelReport()
            excel.filename = "reporte_nivel_strata"
            excel.metadata = get_metadata_single_table(engine, db_schema, tablename)
            excel.setSource(cycle)
            return makeExcelResponse(obs, excel)
    else:
        abort(404)
        

@app.route('/report/version.html')
@crossdomain(origin='*')
def get_metadata_report():
    engine = db.get_engine(app)
    metadata = view_metadata(engine)
    if len(metadata) > 0:
        return makeHtmlReponse(makeHtmlTable(metadata)) 
    else:
        abort(404)
        
@app.route('/report/version/<tablename>.html')
@crossdomain(origin='*')
def get_metadata_table_report(tablename):
    engine = db.get_engine(app)
    metadata = view_metadata_table(engine, tablename)
    if len(metadata) > 0:
        return makeHtmlReponse(makeHtmlTable(metadata)) 
    else:
        abort(404)
   
@app.route("/")
@manager.command
def site_map():
    h = HTML()
    output = []
    variables_examples =  getConfig()["BASE"]["EXAMPLE_URLS"]
    variables_documentation = getConfig()["BASE"]["DOCUMENTATION_URLS"]
    
    for rule in app.url_map.iter_rules():
        documentation = list()
        options = {}
        for arg in rule.arguments:
            print "V",arg
            options[arg] = variables_examples[arg]
            documentation.append({arg:variables_documentation[arg]})

        print url_for(rule.endpoint, **options)
        url = url_for(rule.endpoint, _external=True, **options)
        output.append((rule.endpoint, url, documentation))

    with h.ul as l:
        for line in sorted(output):
            l.li("[%s]: %s: %s" % (line[0], line[1], line[2]))
            l.a
        
    return str(h)

@app.route('/report/calculate')
@crossdomain(origin='*')
def calculate_reports():
    REPORT_DEBUG = request.args.get('debug', "true").upper()
    processing_time = OrderedDict()
    
    
    h = HTML()
    h.title = "Report generation [%s] " % str(datetime.datetime.now())
    start = time.time()
    old_time = time.time()
    
    import rpy2.robjects as robjects
    base = config["BASE"]["R_BASE"]
    for component in [CARBONO5, DCARBONO, BIOMASA, RECUPERATION, FEFA]:
        r_code = code[BASE] % (base, REPORT_DEBUG) + code[component]
        try:
            r = robjects.r(r_code)
        except ValueError, error:
            return str(error)
        
        processing_time[component] = str(time.time() - old_time)
        old_time = time.time()
      
    h.h2("Processing time:")
    with h.ul as l:
        for key, value  in processing_time.iteritems():
            l.li("%s: %s sec" % (key, value))

    h.br
    h.p("Total processing time: %s sec." % str(time.time() - start))
    h.br
    print "Processing time: %s" % str(time.time() - start)
    
    return str(h)


if __name__ == '__main__':
    app.logger.info("Starting web interface to REDD+ reports...")
    app.run(host=config["BASE"]["IP"], port=config["BASE"]["port"])
