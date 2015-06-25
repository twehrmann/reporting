library(RJDBC)
JDBC_RESOURCE = "/Volumes/SSD2go_tw/conafor/reporting/ms sql connector/sqljdbc4.jar"
drv <- JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver",
            JDBC_RESOURCE, "`")
conn <- dbConnect(drv, "jdbc:sqlserver://sql2012.conabio.gob.mx:49354;databaseName=ypsilon", "twehrmann", "twehrmann2014")
dbListTables(conn)
dbGetQuery(conn, "select count(*) from biomasa.bio_autores")
d <- dbReadTable(conn, "biomasa.bio_autores")
