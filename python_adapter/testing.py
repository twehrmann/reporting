from rpy2.robjects import r
robjects.r('source("tools.R")')
r.r('source("tools.R")')
import rpy2.robjects as robjects
robjects.r('source("tools.R")')
r_getname = robjects.globalenv['ResultSet']
robjects.r('source("db_access.R")')
r_getname = robjects.globalenv['getBaseData']
a=r_getname()
a
a.isclass
a.isclass()
a.typeof()
a.typeof
a.validobject
a.validobject()
a.slotnames
a.slotnames()
robjects.r('source("calc_pot_carbono_db.R")')
srobjects.r('source("db_access.R"[A)')
r_getname = robjects.globalenv['runModule']
r_getname()
srobjects.r('source("db_access.R"[A)')
robjects.r('source("db_access.R"')
robjects.r('source("db_access.R"')
robjects.r('source("db_access.R[H")')
robjects.r('source("calc_pot_carbono_db.R")')
r_getname = robjects.globalenv['runModule']
r_getname("carbono_arboles", "bur")
r_getname("carbono_arboles", "BUR")
r_getname("carbono_arboles", "MADMEX")
r_getname("biomasa_arboles", "MADMEX")
r_getname("carbono_tocones", "MADMEX")
robjects.r('source("calc_pot_carbono_db.R")')
r_getname = robjects.globalenv['runModule']