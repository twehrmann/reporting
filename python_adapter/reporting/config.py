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
    with open(configFile, 'r') as stream:
        return yaml.load(stream, Loader=Loader)
    
    return dict()

    


class Config(object):
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'm*\xc8Mw\xaa\x91\xd9o\xa0\xf5\xd0\x03!\xbc\xe9\xa9\x0f\x10\x94\xac,\x8e\xd8'
    SQLALCHEMY_DATABASE_URI = "postgresql://postgres:postgres.@reddbase/reporting"


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
    main()