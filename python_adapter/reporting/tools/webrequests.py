'''
Created on Aug 11, 2015

@author: thilo
'''

import json
import requests

def getResource(url):
    print url
    req = requests.get(url)
    
    return req