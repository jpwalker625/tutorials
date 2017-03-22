
library(shiny)
library(amyRis)
source("/var/shiny-server/www/HTSevents/hts_functions.R")

########### 

con <- sql_getDataoutConnection() #linus connection, uses amyRis

sql.plate_gr <- "SELECT [uid] FROM [dataout].[dbo].[d_plate_group] WHERE
  created_on_date_key > 20140101 ORDER BY [uid] DESC"

plate_groups <- sqlQuery(con, sql.plate_gr)

odbcDisconnectAll()

