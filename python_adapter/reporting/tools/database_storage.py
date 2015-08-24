'''
Created on Aug 24, 2015

@author: thilo
'''

import psycopg2
from reporting.config import getConfig

config=getConfig()

def insertLCAreas(areas, col_name):
    TABLE = config["DB_MADMEX_AREA_TABLE"]
    conn_string = config["BASE"]["DB_STRING"]
    conn = psycopg2.connect(conn_string)
    cursor = conn.cursor()
    columExists=False
    
    try:
        for sql in ["SELECT %s FROM %s;" % (col_name+"_pix", TABLE),
                    "SELECT %s FROM %s; " % (col_name+"_sqm", TABLE)]:
            cursor.execute(sql)
            columExists=True
    except psycopg2.ProgrammingError:
        conn.rollback()
        
    if not columExists:
        for sql in ["ALTER TABLE %s ADD COLUMN %s bigint ;" % (TABLE, col_name+"_pix"),
                    "ALTER TABLE %s ADD COLUMN %s float8; " % (TABLE, col_name+"_sqm")]:
            cursor.execute(sql)
        conn.commit()
    
    for item in areas:
        sql = "UPDATE %s set %s = %d where rastercode = %d ;" % (TABLE, col_name+"_pix", item[1], item[0])

        cursor.execute(sql)

        sql = "UPDATE %s set %s = %d where rastercode = %f; " % (TABLE, col_name+"_sqm", item[2], item[0])

        cursor.execute(sql)
    conn.commit()
    conn.close()
    
    return True

def main():
    a = list()
    print insertLCAreas(a)

if __name__ == '__main__':
    main()