'''
Created on Jul 22, 2015

@author: thilo
'''

import sys, os
import yaml
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

if os.environ.get('REPORT_DEF'):
    CONFIG = os.environ['REPORT_DEF']
else:
    print "Please set OS variable REPORT_DEF to the config yaml file..."
    sys.exit(2)

def getConfig(configFile=CONFIG):
    configStructure = dict()
    
    with open(configFile, 'r') as stream:
        configStructure= yaml.load(stream, Loader=Loader)
    
    
    configStructure["BASE"]["R_BASE"] = os.getenv('R_REPORTING_DIR', configStructure["BASE"]["R_BASE"])
    return configStructure

   

OBS_COLUMN_MAPPER = getConfig()["OBS_COLUMN_MAPPER"]
UDM_COLUMN_MAPPER = getConfig()["UDM_COLUMN_MAPPER"]
STRATA_COLUMN_MAPPER = getConfig()["STRATA_COLUMN_MAPPER"]
UDM_BIOMASA_MAPPER = getConfig()["UDM_BIOMASA_MAPPER"]
 


class Config(object):
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'm*\xc8Mw\xaa\x91\xd9o\xa0\xf5\xd0\x03!\xbc\xe9\xa9\x0f\x10\x94\xac,\x8e\xd8'
    SQLALCHEMY_DATABASE_URI = getConfig()["BASE"]["DB_STRING"]
    SQLALCHEMY_ECHO = False
    SQLALCHEMY_POOL_SIZE = 10


class ProductionConfig(Config):
    DEBUG = False


class StagingConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class DevelopmentConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class TestingConfig(Config):
    TESTING = True


if __name__ == '__main__':
    print(os.environ['DATABASE_URL'])


def main():
    print getConfig()

if __name__ == '__main__':
    print CONFIG
    main()