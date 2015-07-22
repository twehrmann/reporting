'''
Created on Jul 22, 2015

@author: thilo
'''

import os


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
