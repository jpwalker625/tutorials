#!/usr/bin/env Rscript

#This R script builds tables for HTS events capture project
# Jabus Tyerman

source("/var/shiny-server/www/HTSevents/load_packages.R")
source("/var/shiny-server/www/HTSevents/hts_functions.R")

wd <- "/var/shiny-server/www/HTSevents/"
setwd(wd)

sql.build.tables.list = list(

  events="CREATE TABLE [easybake].[hts_et_meta_events]([event_id] [int] NOT NULL, [date_of_event] [datetime] NOT NULL, [date_of_event_end] [datetime], [date_of_record] [datetime] NOT NULL, [date_of_record_end] [datetime], [observer_name] [varchar](255) NOT NULL, [event_description] [varchar](1024) NOT NULL)",

  build="CREATE TABLE [easybake].[hts_et_build_info]([db_info_id] [int] NOT NULL, [build_date] [datetime] NOT NULL, [build_version] [varchar](255) NOT NULL, [author] [varchar](1024) NOT NULL)",

  failure_modes="CREATE TABLE [easybake].[hts_et_failure_modes]([failure_mode_id] [int] NOT NULL, [failure_mode_description] [varchar](1024) NOT NULL, [date_failure_mode_defined] [datetime] NOT NULL, [date_failure_mode_end] [datetime], [is_disabled] [int] NOT NULL)",

  fails="CREATE TABLE [easybake].[hts_et_fails]([fail_id] [int] NOT NULL, [event_id] [int] NOT NULL, [failure_mode_id] [int] NOT NULL, [failure_value] [varchar](1024), [is_disabled] [int] NOT NULL)"

)

#build tables
#x <- pull(unlist(sql.build.tables.list$build))

#x <- pull(unlist(sql.build.tables.list$events))

x <- pull(unlist(sql.build.tables.list$failure_modes))

#x <- pull(unlist(sql.build.tables.list$fails))


#populate tables

#source("hts_events_et_build_info.R")#populate build info table for this build
source("populate_failure_modes.R")#populate failure mode table

