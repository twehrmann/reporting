#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Jul 28, 2015

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

    
def main():
    print getConfig()

if __name__ == '__main__':
    main()