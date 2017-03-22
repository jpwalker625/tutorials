## SERVER

version <- c("1.1")
library(shiny)
library(amyRis)
source("/var/shiny-server/www/HTSevents/hts_functions.R")

end_times <- get_end_times() #HTSfunctions 

########### 

con <- sql_getDataoutConnection() #linex connection, uses amyRis

get_names<- function() { 
  sql.names<- "SELECT * FROM [dataout].[easybake].[hts_et_peeps] WHERE [is_disabled] =0 ORDER BY [score] DESC, [last], [first]"
  hts_names<- sqlQuery(con, sql.names) 
  return(hts_names$first)
}

get_plate_groups <- function() { 
  sql.plate_gr <- "SELECT [uid] FROM [dataout].[dbo].[d_plate_group] WHERE created_on_date_key > 20140101 ORDER BY [uid] DESC"
  plate_groups <- sqlQuery(con, sql.plate_gr) 
  return(plate_groups$uid)
}

get_fails<- function() { 
  sql.fails<- "SELECT [failure_mode_id], [failure_mode_description] FROM [dataout].[easybake].[hts_et_failure_modes] WHERE [is_disabled] = 0"
  fail_groups <- sqlQuery(con, sql.fails) 
  return(fail_groups$failure_mode_description)
}

get_fail_modes_as_dataframe<- function() { 
  sql.fails<- "SELECT [failure_mode_id], [failure_mode_description] FROM [dataout].[easybake].[hts_et_failure_modes] WHERE [is_disabled] = 0 order by failure_mode_id"
  fail_groups <- sqlQuery(con, sql.fails) 
  return(fail_groups)
}

datasetInput <- function() {#NB. Don't want this to be a reactive function, but to be executed each time it's called

  sql <- c("select TOP 100 event_id, date_of_record, observer_name, event_description from [dataout].[easybake].[hts_et_meta_events] order by date_of_record DESC")
  sqlQuery(con, sql)  
}

failureID_key_input <- function() {#NB. Don't want this to be a reactive function, but to be executed each time it's called
  sql <- c("SELECT TOP 1000 [failure_mode_id], [failure_mode_description]
  FROM [dataout].[easybake].[hts_et_failure_modes] WHERE is_disabled = 0 order by [failure_mode_id]")
  sqlQuery(con, sql)  
}

failInput<- function() {#NB. Don't want this to be a reactive function, but to be executed each time it's called

#  sql <- c("select TOP 100 fail_id, event_id, failure_mode_id, failure_value from [dataout].[easybake].[hts_et_fails] order by fail_id DESC")
sql <- c("Select TOP 100 a.fail_id, a.event_id, a.failure_mode_id, b.failure_mode_description, a.failure_value from [dataout].[easybake].[hts_et_fails] as a, [dataout].[easybake].[hts_et_failure_modes] as b WHERE a.failure_mode_id = b.failure_mode_id order by fail_id DESC")
  sqlQuery(con, sql)  
}

get_next_id<- function() {
 # con <- sql_getDataoutConnection() #linex connection, uses amyRis
  sql3 <- c("select max(event_id) from [dataout].[easybake].[hts_et_meta_events]")
  res<- sqlQuery(con, sql3) 

  return(as.numeric(res)+1)
}

get_next_fail_id<- function() {
 # con <- sql_getDataoutConnection() #linex connection, uses amyRis
  sql4 <- c("select max(fail_id) from [dataout].[easybake].[hts_et_fails]")
  res<- sqlQuery(con, sql4) 
  return(as.numeric(res)+1)
}

shinyServer(function(input, output,session) {############################

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

event <- list(
  event_id = this.event.id,
  date_of_event = input$time_stamp,
  date_of_event_end =end_times,
  date_of_record = Sys.time(), 
  date_of_record_end = end_times,
  observer_name = input$name, 
  event_description = input$event_desc
)

sql <- paste("INSERT INTO easybake.hts_et_meta_events VALUES (", unlist(event$event_id), ", '", event$date_of_event,"','", event$date_of_event_end,"','", event$date_of_record, "','", event$date_of_record_end,"','", event$observer_name, "','", event$event_description,"')", sep="")
x <- sqlQuery(con, sql)#push event to DB

active_fail_modes <- get_fail_modes_as_dataframe()

push_fail <- function(fail_id_in,event_id_in,failure_mode_id_in, failure_value_in) {
  fail <- list(
    fail_id= fail_id_in, 
    event_id = event_id_in, 
    failure_mode_id = failure_mode_id_in,
    failure_value = failure_value_in,
    is_disabled = 0
  )
  sql.fail <- paste("INSERT INTO easybake.hts_et_fails VALUES (", unlist(fail$fail_id), ", ", unlist(fail$event_id),",", unlist(fail$failure_mode_id),",'", unlist(fail$failure_value), "',", unlist(fail$is_disabled), ")", sep="")

  y <- sqlQuery(con, sql.fail)#push fail to DB
}

for (this.fail in 1:nrow(active_fail_modes)) {
  #get_next_fail_id()
  if (active_fail_modes$failure_mode_id[this.fail]==0) {push_fail(get_next_fail_id(), event$event_id, 0, "Fail")} 
  if (active_fail_modes$failure_mode_id[this.fail]==1) {push_fail(get_next_fail_id(), event$event_id, 1, "Fail - testing")}#if 

  if (active_fail_modes$failure_mode_id[this.fail]==2 & input$is_illdefined) {push_fail(get_next_fail_id(), event$event_id, 2, input$illdefined_label)}

  if (active_fail_modes$failure_mode_id[this.fail]==3 & input$is_illdefined==0) {push_fail(get_next_fail_id(), event$event_id, 3, "Defined")}


  if (active_fail_modes$failure_mode_id[this.fail]==6 & input$is_material) {push_fail(get_next_fail_id(), event$event_id, 6, input$is_material_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==7 & input$is_mat_raw) {push_fail(get_next_fail_id(), event$event_id, 7, input$is_mat_raw_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==8 & input$is_mat_raw_media) {push_fail(get_next_fail_id(), event$event_id, 8, input$is_mat_raw_media_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==9 & input$is_mat_raw_media_contam) {push_fail(get_next_fail_id(), event$event_id, 9, input$is_mat_raw_media_contam_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==10 & input$is_mat_raw_media_vol) {push_fail(get_next_fail_id(), event$event_id, 10, input$is_mat_raw_media_vol_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==11 & input$is_mat_raw_media_comp) {push_fail(get_next_fail_id(), event$event_id, 11, input$is_mat_raw_media_comp_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==12 & input$is_mat_exp) {push_fail(get_next_fail_id(), event$event_id, 12, input$is_mat_exp_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==13 & input$is_mat_exp_plate_group) {push_fail(get_next_fail_id(), event$event_id, 13, input$plate_group)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==14 & input$is_mat_exp_plate) {push_fail(get_next_fail_id(), event$event_id, 14, input$is_mat_exp_plate_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==4 & input$is_equipment) {push_fail(get_next_fail_id(), event$event_id, 4, input$is_equipment_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==29 & input$is_equipment_biocell_cassette) {push_fail(get_next_fail_id(), event$event_id, 29, input$is_equipment_biocell_cassette_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==18 & input$is_information) {push_fail(get_next_fail_id(), event$event_id, 18, input$is_information_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==23 & input$is_not_captured_bio) {push_fail(get_next_fail_id(), event$event_id, 23, input$biocell_calibration_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==19 & input$is_meas) {push_fail(get_next_fail_id(), event$event_id, 19, input$is_measurement_label)}#if 
   if (active_fail_modes$failure_mode_id[this.fail]==28 & input$is_process) {push_fail(get_next_fail_id(), event$event_id, 28, input$process_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==24 & input$is_pers) {push_fail(get_next_fail_id(), event$event_id, 24, input$personnel_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==26 & input$is_pers_sched) {push_fail(get_next_fail_id(), event$event_id, 26, input$pers_sched_label)}#if 
  if (active_fail_modes$failure_mode_id[this.fail]==27 & input$is_safety) {push_fail(get_next_fail_id(), event$event_id, 27, input$safety_label)}#if 

} #for 

})#dataToPush

output$choose_observer_name <- renderUI({
  selectInput("name", "Observer name", choices = get_names())
})


output$choose_plate_group<- renderUI({
  selectInput("plate_group", "Select plate group", get_plate_groups())
})

output$choose_fails<- renderUI({
  selectInput("list_of_fails", "Failure modes/tags", choices = get_fails(), multiple=TRUE)
})

output$showFailureID <- renderDataTable({ 
  failureID_key_input() 
})


output$showEvents <- renderDataTable({ 

  if (identical(values$lastAction, NULL)) {
    return(NULL)
  }
 
  if (identical(values$lastAction, 'pushToDB')){
    dataToPush()  
  }

  if (identical(values$lastAction, 'postTable')) { 
  x <- datasetInput()
  x$date_of_record<-as.character(x$date_of_record)
  x
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

