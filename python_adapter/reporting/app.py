#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Jul 22, 2015

@author: thilo
'''

from flask import Flask, abort, url_for, Response, request
import os, json
from models.models import get_table_object, AlchemyEncoder, \
    get_view_object, get_all_observations, get_udm_observations

from flask_sqlalchemy import SQLAlchemy
from tools.cross_domain import crossdomain
from html import HTML
from flask.ext.script import Manager
from flask.ext.log import Logging

import urllib
from views import view_observations, view_single_observations, view_single_udm,\
    view_all_udm, view_strata, makeHtmlTable




app = Flask(__name__)
app.config.from_object(os.environ['APP_SETTINGS'])
app.config['FLASK_LOG_LEVEL'] = 'DEBUG'
flask_log = Logging(app)

manager = Manager(app)

db = SQLAlchemy()
db.init_app(app)


@app.route('/reports.json')
def list_reports():
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
 

@app.route('/report/observation')
@crossdomain(origin='*')
def observation_json():
    view_mode = None#"arbolado_vivo"
    a = request.args.get('from')
    b = request.args.get('to')
    if a == None:
        a = 0
    else:
        a = int(float(a))
    if b == None:
        b = 100
    else:
        b = int(float(b))
        
    app.logger.debug('Observation range %d - %d' % (a,b))
    engine = db.get_engine(app)
    
    obs = view_observations(engine, (a, b), view_mode)
    
    return json.dumps(obs)
    
        
@app.route('/report/observation/<udm_id>.json')
@crossdomain(origin='*')
def observation_udm_json(udm_id):
    udm_id = int(float(udm_id))
    view_mode = request.args.get('mode')

    engine = db.get_engine(app)
    obs = view_single_observations(engine, udm_id, mode=view_mode)
    
    if obs != None:
        return json.dumps(obs)
    else:
        abort(404)
        

@app.route('/report/udm/<cycle>/<id>.json')
@crossdomain(origin='*')
def single_udm_json(cycle, id):
    view_mode = request.args.get('mode')
    engine = db.get_engine(app)
    obs = view_single_udm(engine, id, cycle, view_mode)
    
    if len(obs) > 0:
        return json.dumps(obs)
    else:
        abort(404)
        
@app.route('/report/udm/<cycle>')
@crossdomain(origin='*')
def all_udm_json(cycle):
    view_mode = request.args.get('mode')
    a = request.args.get('from')
    b = request.args.get('to')
    if a == None:
        a = 0
    else:
        a = int(float(a))
    if b == None:
        b = 100
    else:
        b = int(float(b))
        
    engine = db.get_engine(app)
    obs = view_all_udm(engine, (a,b), cycle, view_mode)
    
    if len(obs) > 0:
        return json.dumps(obs, cls=AlchemyEncoder)
    else:
        abort(404)
        
@app.route('/report/strata/<subcategory>/<strata_type>/<cycle>/<stock>.json')
@crossdomain(origin='*')
def single_strata(subcategory, strata_type, cycle, stock):
    view_mode = request.args.get('mode')
    engine = db.get_engine(app)
    obs = view_strata(engine, subcategory, strata_type, cycle, stock, view_mode)
    
    if len(obs) > 0:
        return json.dumps(obs)
    else:
        abort(404)
        
@app.route('/report/strata/<subcategory>/<strata_type>/<cycle>/<stock>.html')
@crossdomain(origin='*')
def single_strata_html(subcategory, strata_type, cycle, stock):
    view_mode = request.args.get('mode')
    engine = db.get_engine(app)
    obs = view_strata(engine, subcategory, strata_type, cycle, stock, view_mode)
    
    if len(obs) > 0:
        return Response(makeHtmlTable(obs), mimetype="text/html")     
    else:
        abort(404)

@app.route('/pot/<LCC_SCHEME>/<STOCK>.json')
@crossdomain(origin='*')
def table_json(LCC_SCHEME, STOCK):
    engine = db.get_engine(app)

    tablename = "fe_pot_strata_%s_%s" % (STOCK.lower(), LCC_SCHEME.lower())
    table_data = get_table_object(engine, tablename)
    if len(table_data) > 0:
        return Response(h, mimetype="text/html")   
    else:
        abort(404)        

def has_no_empty_params(rule):
    defaults = rule.defaults if rule.defaults is not None else ()
    arguments = rule.arguments if rule.arguments is not None else ()
    return len(defaults) >= len(arguments)

   
@app.route("/")
@manager.command
def site_map():
    links = []
    h = HTML()
    output = []
    for rule in app.url_map.iter_rules():

        options = {}
        for arg in rule.arguments:
            options[arg] = "[{0}]".format(arg)

        url = url_for(rule.endpoint, _external=True, **options)
        output.append((rule.endpoint, url))

    with h.ul as l:
        for line in sorted(output):
            l.li("[%s]: %s" % (line[0], line[1]))
            l.a
        
    return str(h)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5555)
