#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Jul 22, 2015

@author: thilo
'''

from flask import Flask, abort, url_for, Response, request
import os, json
from models.models import  get_metadata_single_table, get_all_udm_count,\
    get_all_observation_count, get_all_observations

from flask_sqlalchemy import SQLAlchemy
from tools.cross_domain import crossdomain
from html import HTML
from flask.ext.script import Manager
from flask.ext.log import Logging

from views import view_observations, view_single_observations, view_single_udm, \
    view_all_udm, view_strata, makeHtmlTable, view_metadata, view_metadata_table, \
    view_udm, view_national
from config import getConfig
from tools.output_formats import makeJsonResponse, makeHtmlReponse, \
    makeExcelResponse, ExcelReport
from tools.table_names import getObservationTable, getUdmTable, getStrataTables, \
    getUdmBiomasaTables, getNationalTables
import time
import datetime
from tools.r_calculation import code, BASE, CARBONO5, DCARBONO, BIOMASA, \
    RECUPERATION, FEFA
from collections import OrderedDict
from flask.templating import render_template
from tools.converter import url2Dict
from flask.helpers import send_from_directory


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
               
@app.route('/report/strata/<subcategory>/<strata_type>/T<int:cycle>/<stock>.<resource_format>', methods=['GET'])
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
        
@app.route('/report/national/<strata_type>/T<int:cycle>.<resource_format>', methods=['GET'])
@crossdomain(origin='*')
def national_report(strata_type, cycle, resource_format):
    engine = db.get_engine(app)
    cycle = "T%d" % cycle
    
    obs = view_national(engine, strata_type, cycle)
    
    if len(obs) > 0:
        if resource_format == "json":
            return makeJsonResponse(obs)
        elif resource_format == "html":
            return makeHtmlReponse(makeHtmlTable(obs))
        elif resource_format == "xls":
            db_schema, tablename = getNationalTables(strata_type, cycle)
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
   

def get_siteEndpoints():
    output = []
    variables_examples =  getConfig()["BASE"]["EXAMPLE_URLS"]
    variables_documentation = getConfig()["BASE"]["DOCUMENTATION_URLS"]
        
    for rule in app.url_map.iter_rules():
        documentation = list()
        
        options = {}
        for arg in rule.arguments:
            print "ARG:",arg
            options[arg] = variables_examples[arg]
            documentation.append({arg:variables_documentation[arg]})

        print "URL",url_for(rule.endpoint, **options)
        url = url_for(rule.endpoint, _external=True, **options)
        output.append((rule.endpoint, url, documentation))
        
    return output

@app.route("/")
@manager.command
def site_map():
    h = HTML()
    


    with h.ul as l:
        for line in sorted(get_siteEndpoints()):
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

@app.route('/robots.txt')
@app.route('/sitemap.xml')
def static_from_root():
    return send_from_directory(app.static_folder, request.path[1:])

@app.route('/SINAMEF/')
def webui(name=None):
    return render_template('sistema.html', name=name)

@app.route('/SINAMEF/datatable', methods=[ 'POST'])
def dataTableInterface(name=None):
    data = request.data
 
    draw_counter = int(float(url2Dict(data)[u"draw"][0]))
    source = url2Dict(data)[u"sourceResource"][0]

    if "report/udm/T" in source:
        cycle =url2Dict(data)[u"cycle"][0]
        view_mode=url2Dict(source)[u"mode"][0]
        a=int(float(url2Dict(data)[u"start"][0]))
        b=int(float(url2Dict(data)[u"length"][0]))
                
        engine = db.get_engine(app)
        row_counter = get_all_udm_count(engine, cycle)
        obs = obs = view_all_udm(engine, (a,b),cycle, mode=view_mode)
        
        return makeJsonResponse(obs, totalRecords=row_counter, draw=draw_counter)
    
    elif "report/observation/T" in source:
        cycle =url2Dict(data)[u"cycle"][0]
        view_mode=url2Dict(source)[u"mode"][0]
        a=int(float(url2Dict(data)[u"start"][0]))
        b=int(float(url2Dict(data)[u"length"][0]))
                
        engine = db.get_engine(app)
        row_counter = get_all_observation_count(engine, cycle)
        obs = view_observations(engine, cycle, (a, b), mode=view_mode)
        
        return makeJsonResponse(obs, totalRecords=row_counter, draw=draw_counter)
    
    elif "report/national/" in source:
        cycle =url2Dict(data)[u"cycle"][0]
        strata_type=url2Dict(data)[u"strata_type"][0]
                
        engine = db.get_engine(app)
        row_counter = get_all_observation_count(engine, cycle)
        obs = view_national(engine, strata_type, cycle)
        
        return makeJsonResponse(obs, totalRecords=row_counter, draw=draw_counter)
    
    else:
        print "Not supported..."
        print url2Dict(data)[u"sourceResource"][0]
        return json.dumps(dict({"error":"Not supported: %s" % source}))

if __name__ == '__main__':
    app.logger.info("Starting web interface to REDD+ reports...")
    app.run(host=config["BASE"]["IP"], port=config["BASE"]["port"])
