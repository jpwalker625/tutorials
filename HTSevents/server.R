## SERVER

##### version 1.2.2 notes
#2/20/2014
# Added and tested new tags for HTS CORE process activities.
# Added plate-group to top of tag list, will see if there is more use of this tag.

# 2/12/2014
# modified PI new 20 mM batch tags, to have no generic text entry and to have dropdown for components already selected.

# 2/10/2014
# added new tags to ui.R and server.R (these were input using the 'tag maker' web app)
# added small horizontal lines as dividers to main inputs, helps with visualizing the UI

# 2/8/2014 
# Used direct odbcConnect function rather than amyRis (Maxime suggested that amyRis is slow...)
# called DB connection within functioins, and closed out connection with each function (to help manage open connections)
# Changed some of the language to include Tags in addition to Failure Modes

#version 1.2.1
#version 1.1
#version 1.0
#version 0
#######################################

version <- c("1.2.2")

library(shiny)
library(RODBC) #for DB connections

source("hts_functions.R")

########### 

trim <- function (x) gsub("^\\s+|\\s+$", "", x) #cleans leading and trailing whitespace from a string

get_names<- function() { 
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")

  sql.names<- "SELECT [first] FROM [dataout].[easybake].[hts_et_peeps] WHERE [is_disabled] =0 ORDER BY [score] DESC, [last], [first]"
  hts_names<- sqlQuery(db, sql.names) 
  odbcClose(db)
  return(hts_names)
}

get_plate_groups <- function() { 
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  sql.plate_gr <- "SELECT [uid] FROM [dataout].[dbo].[d_plate_group] WHERE created_on_date_key > 20140101 ORDER BY [uid] DESC"
  plate_groups <- sqlQuery(db, sql.plate_gr) 
  odbcClose(db)
  return(plate_groups)
}

get_fails<- function() { 
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  sql.fails<- "SELECT [failure_mode_description] FROM [dataout].[easybake].[hts_et_failure_modes] WHERE [is_disabled] = 0"
  fail_groups <- sqlQuery(db, sql.fails) 
  odbcClose(db)
  return(fail_groups)
}

get_fail_modes_as_dataframe<- function() { 
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  sql.fails<- "SELECT [failure_mode_id], [failure_mode_description] FROM [dataout].[easybake].[hts_et_failure_modes] WHERE [is_disabled] = 0 order by [failure_mode_id]"
  fail_groups <- sqlQuery(db, sql.fails) 
  odbcClose(db)
  return(fail_groups)
}

datasetInput <- function() {#NB. Don't want this to be a reactive function, but to be executed each time it's called
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")

  sql <- c("SELECT TOP 500 a.[event_id], a.[date_of_event], a.[date_of_event_end], a.[date_of_record], a.[observer_name], a.[event_description] from [dataout].[easybake].[hts_et_meta_events] AS a, [dataout].[easybake].[hts_et_fails] AS b WHERE a.event_id = b.event_id AND b.failure_mode_id = 0 AND b.is_disabled = 0 ORDER BY a.[date_of_record] DESC")
  x <- sqlQuery(db, sql)   
  odbcClose(db)
  x$status <- unlist(Map(function(x){if (x==get_end_times()) {"open"} else {"closed"}}, x$date_of_event_end)) 
  x <- x[,c(1,2,7,4,5,6)] 
  names(x) <- c("id", "event-date", "status", "record-date", "observer", "description")
  return(x)
}

failureID_key_input <- function() {#NB. Don't want this to be a reactive function, but to be executed each time it's called
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  sql <- c("SELECT TOP 1000 [failure_mode_id] as [tag_mode_id], [failure_mode_description] as [tag_mode_description]
  FROM [dataout].[easybake].[hts_et_failure_modes] WHERE [is_disabled] = 0 order by [tag_mode_id]")
  fail.keys <- sqlQuery(db, sql)  
  odbcClose(db)
  return(fail.keys)
}

tag_hierarchy_model <- function() {#NB. Don't want this to be a reactive function, but to be executed each time it's called
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  sql <- c("SELECT a.[hier_id]
      ,a.[focal_id] as [child]
      ,a.[to_id] as [parent]
  FROM [dataout].[easybake].[hts_et_tag_hierarchy] as a
  order by a.hier_id")
  relations<- sqlQuery(db, sql)  
  odbcClose(db)
  return(relations)
}

failInput<- function() {#NB. Don't want this to be a reactive function, but to be executed each time it's called
 db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  sql <- c("Select TOP 1000 a.fail_id as [tag_id], a.event_id, a.failure_mode_id as [tag_mode_id], b.failure_mode_description as [tag_mode_description], a.failure_value as [tag_attribute] from [dataout].[easybake].[hts_et_fails] as a, [dataout].[easybake].[hts_et_failure_modes] as b WHERE a.failure_mode_id = b.failure_mode_id AND a.is_disabled = 0 ORDER BY fail_id DESC")
  f.input <- sqlQuery(db, sql)  
  odbcClose(db)
  return(f.input)
}

get_next_id<- function() {
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  sql3 <- c("select max(event_id) from [dataout].[easybake].[hts_et_meta_events]")
  res<- sqlQuery(db, sql3) 
  odbcClose(db)
  return(as.numeric(res)+1)
}

get_next_fail_id<- function() {
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  sql4 <- c("select max(fail_id) from [dataout].[easybake].[hts_et_fails]")
  res<- sqlQuery(db, sql4) 
  odbcClose(db)
  return(as.numeric(res)+1)
}

#shinyServer(function(input, output) {############################
shinyServer(function(input, output, session) {############################

values <- reactiveValues()

values$lastAction <- 'postTable' 

observe({
  if (input$submit !=0) {
    values$lastAction <-'pushToDB'
  }
})
observe({
  if (input$refresh !=0) {
    values$lastAction <-'postTable'
  }
})

dataToPush <- reactive({

this.event.id <- get_next_id()

end_times <- function(time_flag, event_time_stamp) {
  if (time_flag == "Open-ended") {
    return(get_end_times())
  }
  else {
    return(event_time_stamp)
  }
}


  sql <- paste("INSERT INTO easybake.hts_et_meta_events VALUES (", this.event.id, ", '", input$time_stamp, "','", end_times(input$time_setting, input$time_stamp), "','", Sys.time(), "','", get_end_times(), "','", input$name, "','", input$event_desc, "')", sep="")

db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
x <- sqlQuery(db, sql)#push event to DB
odbcClose(db)

active_fail_modes <- get_fail_modes_as_dataframe()

push_fail <- function(fail_id_in,event_id_in,failure_mode_id_in, failure_value_in) {

  sql.fail <- paste("INSERT INTO easybake.hts_et_fails VALUES (", fail_id_in, ", ", event_id_in,",", failure_mode_id_in,",'", failure_value_in, "',", 0, ")", sep="")
  db<- odbcConnect("sqlwarehouse1","hts_qc","htsqc")
  y <- sqlQuery(db, sql.fail)#push fail to DB
  odbcClose(db)
}

for (this.fail in 1:nrow(active_fail_modes)) {

  if (active_fail_modes$failure_mode_id[this.fail]==0) {push_fail(get_next_fail_id(), this.event.id, 0, "Fail")} 
  if (active_fail_modes$failure_mode_id[this.fail]==1 & input$is_testing) {push_fail(get_next_fail_id(), this.event.id, 1, "Fail - testing mode, ignore event and failures")}#if 

  if (active_fail_modes$failure_mode_id[this.fail]==2 & input$is_illdefined) {push_fail(get_next_fail_id(), this.event.id, 2, input$illdefined_label)}
  if (active_fail_modes$failure_mode_id[this.fail]==13 & input$is_pg2) {push_fail(get_next_fail_id(), this.event.id, 13, input$plate_group2)}#if 

  if (active_fail_modes$failure_mode_id[this.fail]==6 & input$is_material) {push_fail(get_next_fail_id(), this.event.id, 6, input$is_material_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==7 & input$is_mat_raw) {push_fail(get_next_fail_id(), this.event.id, 7, input$is_mat_raw_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==8 & input$is_mat_raw_media) {push_fail(get_next_fail_id(), this.event.id, 8, input$is_mat_raw_media_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==9 & input$is_mat_raw_media_contam) {push_fail(get_next_fail_id(), this.event.id, 9, input$is_mat_raw_media_contam_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==10 & input$is_mat_raw_media_vol) {push_fail(get_next_fail_id(), this.event.id, 10, input$is_mat_raw_media_vol_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==11 & input$is_mat_raw_media_comp) {push_fail(get_next_fail_id(), this.event.id, 11, input$is_mat_raw_media_comp_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==12 & input$is_mat_exp) {push_fail(get_next_fail_id(), this.event.id, 12, input$is_mat_exp_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==13 & input$is_mat_exp_plate_group) {push_fail(get_next_fail_id(), this.event.id, 13, input$plate_group)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==14 & input$is_mat_exp_plate) {push_fail(get_next_fail_id(), this.event.id, 14, input$is_mat_exp_plate_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==4 & input$is_equipment) {push_fail(get_next_fail_id(), this.event.id, 4, input$is_equipment_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==29 & input$is_equipment_biocell_cassette) {push_fail(get_next_fail_id(), this.event.id, 29, input$is_equipment_biocell_cassette_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==18 & input$is_information) {push_fail(get_next_fail_id(), this.event.id, 18, input$is_information_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==23 & input$is_not_captured_bio) {push_fail(get_next_fail_id(), this.event.id, 23, "")}#if
 

  if (active_fail_modes$failure_mode_id[this.fail]==30 & input$is_not_captured_bio_fuv_vol & input$is_not_captured_bio) {push_fail(get_next_fail_id(), this.event.id, 30, input$fuv_vol_value)} 
  if (active_fail_modes$failure_mode_id[this.fail]==31 & input$is_not_captured_bio_fuv_cv & input$is_not_captured_bio) {push_fail(get_next_fail_id(), this.event.id, 31, input$fuv_cv_value)}
  if (active_fail_modes$failure_mode_id[this.fail]==32 & input$is_not_captured_bio_fuv_mass & input$is_not_captured_bio) {push_fail(get_next_fail_id(), this.event.id, 32, input$fuv_mass_value)}
   if (active_fail_modes$failure_mode_id[this.fail]==33 & input$is_not_captured_bio_ssod_cv & input$is_not_captured_bio) {push_fail(get_next_fail_id(), this.event.id, 33, input$ssod_cv_value)}
   if (active_fail_modes$failure_mode_id[this.fail]==34 & input$is_not_captured_bio_ssod_mass & input$is_not_captured_bio) {push_fail(get_next_fail_id(), this.event.id, 34, input$ssod_mass_value)}
 
  if (active_fail_modes$failure_mode_id[this.fail]==19 & input$is_meas) {push_fail(get_next_fail_id(), this.event.id, 19, input$is_measurement_label)}#if 
   if (active_fail_modes$failure_mode_id[this.fail]==28 & input$is_process) {push_fail(get_next_fail_id(), this.event.id, 28, input$process_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==24 & input$is_pers) {push_fail(get_next_fail_id(), this.event.id, 24, input$personnel_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==26 & input$is_pers_sched) {push_fail(get_next_fail_id(), this.event.id, 26, input$pers_sched_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==27 & input$is_safety) {push_fail(get_next_fail_id(), this.event.id, 27, input$safety_label)}#if 
##
  if (active_fail_modes$failure_mode_id[this.fail]==35 & input$is_35) {push_fail(get_next_fail_id(), this.event.id, 35, input$is_35_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==36 & input$is_36) {push_fail(get_next_fail_id(), this.event.id, 36, input$is_36_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==37 & input$is_37) {push_fail(get_next_fail_id(), this.event.id, 37, input$is_37_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==38 & input$is_38) {push_fail(get_next_fail_id(), this.event.id, 38, input$is_38_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==39 & input$is_39) {push_fail(get_next_fail_id(), this.event.id, 39, input$is_39_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==40 & input$is_40) {push_fail(get_next_fail_id(), this.event.id, 40, input$is_40_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==41 & input$is_41) {push_fail(get_next_fail_id(), this.event.id, 41, input$is_41_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==42 & input$is_42) {push_fail(get_next_fail_id(), this.event.id, 42, input$is_42_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==44 & input$is_44) {push_fail(get_next_fail_id(), this.event.id, 44, input$is_44_label)}#if 
#  if (active_fail_modes$failure_mode_id[this.fail]==45 & input$is_45) {push_fail(get_next_fail_id(), this.event.id, 45, input$is_45_label)}#if ###occurs below in order
  if (active_fail_modes$failure_mode_id[this.fail]==46 & input$is_46) {push_fail(get_next_fail_id(), this.event.id, 46, input$is_46_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==47 & input$is_47) {push_fail(get_next_fail_id(), this.event.id, 47, input$is_47_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==48 & input$is_48) {push_fail(get_next_fail_id(), this.event.id, 48, input$is_48_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==49 & input$is_49) {push_fail(get_next_fail_id(), this.event.id, 49, input$is_49_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==50 & input$is_50) {push_fail(get_next_fail_id(), this.event.id, 50, input$is_50_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==51 & input$is_51 & input$is_50) {push_fail(get_next_fail_id(), this.event.id, 51, input$is_51_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==52 & input$is_52 & input$is_50) {push_fail(get_next_fail_id(), this.event.id, 52, input$is_52_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==53 & input$is_53) {push_fail(get_next_fail_id(), this.event.id, 53, input$is_53_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==54 & input$is_54) {push_fail(get_next_fail_id(), this.event.id, 54, input$is_54_label)}#if 

### adding in CORE tags
  if (active_fail_modes$failure_mode_id[this.fail]==55 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 55, NULL)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==56 & input$is_56 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 56, NULL)}#if 

  if (active_fail_modes$failure_mode_id[this.fail]==57 & input$is_57 & input$is_56 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 57, input$is_57_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==58 & input$is_58 & input$is_56 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 58, input$is_58_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==59 & input$is_59 & input$is_56 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 59, input$is_59_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==2 & input$is_other2 & input$is_56 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 2, input$is_other2_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==61 & input$is_61 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 61, NULL)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==43 & input$is_43 & input$is_61 &  input$is_55) {push_fail(get_next_fail_id(), this.event.id, 43, input$is_43_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==63 & input$is_63 & input$is_61 &  input$is_55) {push_fail(get_next_fail_id(), this.event.id, 63, input$is_63_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==2 & input$is_other2_3 & input$is_61 &  input$is_55) {push_fail(get_next_fail_id(), this.event.id, 2, input$is_other2_3_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==62 & input$is_62 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 62, NULL)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==64 & input$is_64 & input$is_62 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 64, input$is_64_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==65 & input$is_65 & input$is_62 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 65, input$is_65_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==2 & input$is_other2_4 & input$is_62 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 2, input$is_other2_4_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==45 & input$is_45 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 45, input$is_45_label)}#if 
### for next item:
# Allow multiple items to be added, each with it's own row. In this case, it is plate_id.
  if (active_fail_modes$failure_mode_id[this.fail]==14 & input$is_14 & input$is_55) { 
    plates.in <- unlist(strsplit(input$is_14_core_label, ","))
    for (e in 1:length(plates.in)) {
      push_fail(get_next_fail_id(), this.event.id, 14, trim(plates.in[e]))
    } 
  }

  if (active_fail_modes$failure_mode_id[this.fail]==2 & input$is_other_2_5 & input$is_55) {push_fail(get_next_fail_id(), this.event.id, 2, input$is_other_2_5_label)}#if 

 
} #for 

values$lastAction <- NULL

})#dataToPush

output$get_the_date_and_time<- renderUI({
  textInput("time_stamp", "Date and time of event (refresh browser to update time and clear all fields):", Sys.time())
})

output$choose_observer_name <- renderUI({
  if (identical(values$lastAction, NULL)) {
    return(NULL)
  } 
  selectInput("name", "Observer name", choices = get_names()[,1])
})

output$choose_plate_group<- renderUI({
  selectInput("plate_group", "Select plate group", get_plate_groups()[,1])
})

output$choose_plate_group2<- renderUI({
  selectInput("plate_group2", "Select plate group", get_plate_groups()[,1])
})


output$choose_fails<- renderUI({
  selectInput("list_of_fails", "Failure modes/tags", choices = get_fails()[,1], multiple=TRUE)
})

output$showFailureID <- renderDataTable({ 
  failureID_key_input() 
})

output$showRelations <- renderDataTable({ 
  tag_hierarchy_model() 
})


output$showEvents <- renderDataTable({ 

  if (identical(values$lastAction, NULL)) {
    return(NULL)
  }
 
  if (identical(values$lastAction, 'pushToDB')){
    dataToPush()  
  }

  if (identical(values$lastAction, 'postTable')) { 
     return(datasetInput())
  }
})

output$showFails<- renderDataTable({ 
  if (identical(values$lastAction, NULL)) {
    return(NULL)
  }
 
  if (identical(values$lastAction, 'pushToDB')){
    dataToPush()
  }

  if (identical(values$lastAction, 'postTable')) { 
    failInput()
  }  
})

output$allAboutUs <- renderText({
  paste("HTS event capture is an R shiny app, connecting to 'dataout' (tables: easybake.hts_et_meta_events, easybake.hts_et_failure_modes, easybake.hts_et_fails), version: ", version, ". Send feedback to tyerman@amyris.com.", sep="")
})

})#shiny-server

