'''
Created on Jul 22, 2015

@author: thilo
'''

from flask.ext.script import Manager
from flask.ext.migrate import Migrate, MigrateCommand
import os

from app import app
from flask_sqlalchemy import SQLAlchemy

app.config.from_object(os.environ['APP_SETTINGS'])
db = SQLAlchemy(app)

migrate = Migrate(app, db)
manager = Manager(app)

manager.add_command('db', MigrateCommand)

if __name__ == '__main__':
    manager.run()
