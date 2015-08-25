#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on Jul 29, 2015

@author: thilo
'''

from flask import  Response, send_file
import json
import xlsxwriter
import StringIO
import datetime
from reporting.config import getConfig

config = getConfig()

class ExcelReport(object):
    filename = None
    metadata = None
    source = None
    base = config["EXCEL_FORMAT"]
    
    def getTitle(self):
        if self.metadata.stock_type not in  self.base["stocks"].keys():
            title = "%s" % (self.base[self.metadata.module]["title"])
        else:
            title = "%s (%s)" % (self.base["stocks"][self.metadata.stock_type], self.base[self.metadata.module]["title"])
        return title
    
    def getSource(self):
        if self.source != None:
            return self.source
        else:
            return ""
    def getColumns(self):
        return [key.keys()[0] for key in self.base[self.metadata.module]["columns"]]
    
    def getColumnName(self, column):

        if column in self.getColumns():
            ids = {key.keys()[0]:counter for counter, key in enumerate(self.base[self.metadata.module]["columns"])}
            return self.base[self.metadata.module]["columns"][ids[column]][column]
        else:
            raise Exception ("Column %s of %s not in defined columns: %s" % (column, self.metadata.module, str(self.getColumns())))
    
    def setSource(self, cycle=None):
        if self.base[self.metadata.module] == None:
            raise Exception("No Excel description found for file: %s"%self.filename)
        if "%" in self.base[self.metadata.module]["source"]:
            self.source = self.base[self.metadata.module]["source"] % cycle
        else:
            self.source = self.base[self.metadata.module]["source"]
            
        print self.source
        
    def getDateCalculation(self):
        return "Calculado: %s " % str(self.metadata.generated)
    
    def getDateCreation(self):
        return "Generado: %s " % str(datetime.datetime.now())
   

        

 
def makeJsonResponse(data, totalRecords=-1, draw=1):
    outputStruct = dict()
    outputStruct["draw"]=draw
    if totalRecords == -1:
        outputStruct["recordsTotal"]=len(data)-1
        outputStruct["recordsFiltered"]=len(data)-1
    else:
        outputStruct["recordsTotal"]=totalRecords
        outputStruct["recordsFiltered"]=totalRecords
    
    outputStruct["data"]=list()

    for item in data[1:]:
        outputStruct["data"].append(item)
        
    json_response = json.dumps(outputStruct, sort_keys=True)

    response = Response(json_response, content_type='application/json')
    response.headers.add('Content-length', len(json_response))
    response.status_code = 200

    return response

def makeHtmlReponse(data):
    response = Response(data, content_type='text/html')
    response.status_code = 200

    return response
    
def makeExcelResponse(data, excelReport):
    ROW_OFFSET = 4
    COL_OFFSET = 1
    
    strIO = StringIO.StringIO()
    workbook = xlsxwriter.Workbook(strIO, {'in_memory': True, 'constant_memory': True})
    bold = workbook.add_format({'bold': True})
    big_bold =  workbook.add_format({'bold': True, 'size': 14})
    italic = workbook.add_format({'italic': True})
    
    worksheet = workbook.add_worksheet(name=excelReport.filename)
    worksheet.write(0, 1, excelReport.getTitle(), big_bold)
    worksheet.write(1, 1, excelReport.getSource(), big_bold)
    worksheet.write(0, 6, excelReport.getDateCalculation(), italic)
    worksheet.write(1, 6, excelReport.getDateCreation(), italic)
    
    columns = excelReport.getColumns()

    columns_sorted = list()
    for key in excelReport.getColumns():
        if key in set(data[0]["structure"]):
            columns_sorted.append(key)

    for column, key in enumerate(columns_sorted):
            worksheet.write(ROW_OFFSET-1, column+COL_OFFSET, excelReport.getColumnName(key), bold)
            
    for row, item in enumerate(data[1:]):
        for column, key in enumerate(columns_sorted):
            worksheet.write(row+ROW_OFFSET, column+COL_OFFSET, item[key])
        
    workbook.close()
    strIO.seek(0)
    now = datetime.datetime.now()

    report_name = excelReport.filename + "(" + \
                  now.strftime("%Y-%m-%dT%H:%M") +\
                  ")" + ".xlsx"
    
    return send_file(strIO, as_attachment = True, attachment_filename = report_name, mimetype="'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
