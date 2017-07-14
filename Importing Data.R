## Connecting to Databases

#The RODBC package is useful for connecting to a database such as Microsoft SQL Server

library(RODBC)

con <- odbcDriverConnect(connection="DRIVER=SQL SERVER; SERVER=sqlwarehouse1.amyris.local; UID=dataout_reader; PWD=dataout_reader; DATABASE=dataout")


query <-  sqlQuery(channel = con, query = "SELECT TOP 100* FROM furnace.hts_st4_requests")
