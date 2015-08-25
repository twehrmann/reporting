#!/usr/local/bin/python2.7
# encoding: utf-8
'''
reporting.tools.spatial_data -- Generate / update class histogram of raster data

reporting.tools.spatial_data is a program to calculate raster based class histogram for MADMEX products for product handling/actualization in report context.


@author:     twehrmann

@copyright:  2015 CONABIO. All rights reserved.

@license:    license

@contact:    thilo.wehrmann@conabio.gob.mx
@deffield    updated: Updated
'''

from argparse import ArgumentParser
from argparse import RawDescriptionHelpFormatter

import os, sys, time
from osgeo import gdal
from osgeo._gdalconst import GA_ReadOnly
import multiprocessing as mp
import struct

import numpy as np
from collections import Counter
from reporting.tools.database_storage import insertLCAreas

BLOCK_Y_MAX = 100


__all__ = []
__version__ = 0.1
__date__ = '2015-08-24'
__updated__ = '2015-08-24'

DEBUG = 1

class CLIError(Exception):
    '''Generic exception to raise and log different fatal errors.'''
    def __init__(self, msg):
        super(CLIError).__init__(type(self))
        self.msg = "E: %s" % msg
    def __str__(self):
        return self.msg
    def __unicode__(self):
        return self.msg


def getResolution(image):
    image = gdal.OpenShared(image, GA_ReadOnly)

    geotransform = image.GetGeoTransform()
    del image
    return geotransform[1]

def getExtent(image, BAND=1):
    image = gdal.OpenShared(image, GA_ReadOnly)

    geotransform = image.GetGeoTransform()
    if not geotransform is None:
        print 'Origin = (',geotransform[0], ',',geotransform[3],')'
        print 'Pixel Size = (',geotransform[1], ',',geotransform[5],')'

    print 'Driver: ', image.GetDriver().ShortName,'/', \
          image.GetDriver().LongName
    print 'Size is ',image.RasterXSize,'x',image.RasterYSize, \
          'x',image.RasterCount
    print 'Projection is ',image.GetProjection()
    
    try:
        band = image.GetRasterBand(BAND)
    except RuntimeError, e:
        print 'No band %i found' % BAND
        print e
        sys.exit(1)
        
        
    minimum = band.GetMinimum()
    maximum = band.GetMaximum()
    if minimum is None or maximum is None:
        (minimum,maximum) = band.ComputeRasterMinMax(1)
    print 'Stats: min=%d, max=%d' % (int(minimum), int(maximum))
        

    return (image.RasterXSize, image.RasterYSize, image.RasterCount)

def reduce_hist(hist, bins):
    labeled_hist = dict(zip(bins, hist))
    return labeled_hist

def spatial_histogram(x):
    start_total = time.time()
    name, extent, BAND= x
    x1,y1, x2,y2 = extent

    img = gdal.OpenShared(name, GA_ReadOnly)
    band = img.GetRasterBand(BAND)
    
    block = band.ReadRaster( x1,y1, x2,y2, buf_xsize=x2, buf_ysize=y2)
    values = [struct.unpack('B' * x2*y2, block)]    

    
    if block != None:
        bins = np.arange(0,255)
        hist=np.histogram(values, bins=bins)

        #print "\t %s: %s sec." % (str(extent), str(time.time()-start_total))
        return reduce_hist( hist[0], bins)
    else:
        print "%s sec." % str(time.time()-start_total)
        raise Exception ("out of range")
    

    
def merge_hist(hist_list):
    counter = Counter()
    for d in hist_list: 
        counter.update(d)
        
    return counter


def check_block(x, y, xmax, ymax, extent):
    bx=xmax

    if y + BLOCK_Y_MAX > extent[1]:
        by = extent[1] - y
    else:
        by = BLOCK_Y_MAX
    
    return bx, by


def single(image, extent, BAND=1):
    hist_x = list()
    job_list = list()
    BLOCK_X=extent[0]
    BLOCK_Y=BLOCK_Y_MAX

    x=0
    for y in range (0, extent[1], BLOCK_Y):        
        block_x, block_y = check_block(x, y, extent[0], extent[1], extent)
        job_list.append((image, (x, y, block_x, block_y), BAND))
            
    return job_list


def main(argv=None): # IGNORE:C0111
    '''Command line options.'''

    if argv is None:
        argv = sys.argv
    else:
        sys.argv.extend(argv)

    program_name = os.path.basename(sys.argv[0])
    program_version = "v%s" % __version__
    program_build_date = str(__updated__)
    program_version_message = '%%(prog)s %s (%s)' % (program_version, program_build_date)
    program_shortdesc = __import__('__main__').__doc__.split("\n")[1]
    program_license = '''%s

  Created by user_name on %s.
  Copyright 2015 organization_name. All rights reserved.

  Licensed under the Apache License 2.0
  http://www.apache.org/licenses/LICENSE-2.0

  Distributed on an "AS IS" basis without warranties
  or conditions of any kind, either express or implied.

USAGE
''' % (program_shortdesc, str(__date__))

    try:
        # Setup argument parser
        parser = ArgumentParser(description=program_license, formatter_class=RawDescriptionHelpFormatter)
        parser.add_argument('-V', '--version', action='version', version=program_version_message)
        parser.add_argument(dest="input_raster", help="Input raster file; should contain descrete values", metavar="input_raster")
        parser.add_argument("-b", "--band", dest="band", help="Band number containing the information", metavar="BAND" , default=1)
        parser.add_argument("-c", "--col_name", dest="col_name", help="Column name for attributes (_pix, _sqm)", metavar="col_name")
        parser.add_argument("-n", "--num_processes", dest="num_processes", help="Number of parallel processes.", metavar="num_processes", default=6)


        # Process arguments
        args = parser.parse_args()

        t1 = args.input_raster

        N=int(args.num_processes)
        BAND = int(args.band)
        
        start_total = time.time()
        col_name = args.col_name
        extent = getExtent(t1)
        resolution = getResolution(t1)
        
        pool = mp.Pool(processes=N)
        print "Start processing... "
    
        job_list = single(t1, extent, BAND)
        
        results = list()
        output = list()
        
        for x in job_list:
            results.append(pool.apply_async(spatial_histogram, args=(x,)))
        
        start = start_total
        for counter, x in enumerate(results):
            output.append(x.get() )

            if (counter % 100) == 0:
                print "JOB: %d (%d): Total time: %s sec."  % (counter, len(results),  str(time.time()-start))
                start = time.time()
        print "JOB: %d (%d): Total time: %s sec." % (len(results), len(results),  str(time.time()-start))
            
        result = merge_hist(output)
        keys = result.keys()
        keys.sort()

        print "* %s \t %s \t %s\t %s" % ("class", "pixels", "sqm area", "ha area")
    
        print "Result:"
        area_result = list()
        for i in keys:
            if result[i] > 0:
                print "* %d \t %d \t %f \t %d" % (i, result[i], result[i]*resolution*resolution/1., result[i]*resolution*resolution/10000.)
                area_result.append((i, result[i], result[i]*resolution*resolution/1.))
           
        if col_name != None:
            print "Writing table to database..."
            insertLCAreas(area_result, col_name)
        print "Total time: %s sec." % str(time.time()-start_total)
        
        return 0
    except KeyboardInterrupt:
        ### handle keyboard interrupt ###
        return 0
    except Exception, e:
        if DEBUG:
            raise(e)
        indent = len(program_name) * " "
        sys.stderr.write(program_name + ": " + repr(e) + "\n")
        sys.stderr.write(indent + "  for help use --help")
        return 2


if __name__ == '__main__':
    sys.exit(main())
