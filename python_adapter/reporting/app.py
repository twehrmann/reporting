'''
Created on Jul 22, 2015

@author: thilo
'''

from flask import Flask, abort, url_for
import os, json
from models.models import get_table_object, AlchemyEncoder
from flask.helpers import send_from_directory
from sqlalchemy.engine import create_engine
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

app = Flask(__name__)
app.config.from_object(os.environ['APP_SETTINGS'])

db.init_app(app)


@app.route('/')
def hello():
    return "Hello World!"

@app.route('/static1')
def test():
    return app.send_static_file('production.txt')



@app.route('/pot/<LCC_SCHEME>/<STOCK>.json')
def table_json(LCC_SCHEME, STOCK):
    engine=db.get_engine(app)

    tablename = "fe_pot_strata_%s_%s" % (STOCK.lower(),LCC_SCHEME.lower())
    table_data = get_table_object(engine, tablename)
    if len(table_data) >0:
        return json.dumps(table_data, cls=AlchemyEncoder)
    else:
        abort(404)
        
@app.route('/pot/<LCC_SCHEME>/<STOCK>.html')
def table_html(LCC_SCHEME, STOCK):
    engine=db.get_engine(app)

    from html import HTML
    
    h = HTML()
    t = h.table(border='1')


    tablename = "fe_pot_strata_%s_%s" % (STOCK.lower(),LCC_SCHEME.lower())
    table_data = get_table_object(engine,tablename)
    table_string = json.dumps(table_data, cls=AlchemyEncoder)
    table_dict = json.loads(table_string)
        
    if len(table_data) >0:
        r = t.tr
        header = list()
        
        for counter, row in enumerate(table_dict):
            keys=row.keys()
            keys.sort()
            if counter==0:
                for item in keys:
                    r.th(item)
                r.tr
                
            for item in keys:
                r.td(str(row[item]))            
            r.tr
            
                   
        return str(h)
    else:
        abort(404) 


if __name__ == '__main__':
    app.run()