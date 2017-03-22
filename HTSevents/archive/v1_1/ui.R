####   UI
#### see server.R for version notes

library(shiny)


shinyUI(pageWithSidebar(
  headerPanel("HTS Event Capture"),   # Application title

  sidebarPanel(
    helpText("Enter event information below:"),
    textInput("time_stamp", "Date and time of event (refresh browser to update time and clear all fields):", Sys.time()),
    helpText("Note: event date-time stamp can refer to the past."),
#
    uiOutput("choose_observer_name"),
#
    textInput("event_desc", "Event description", ""),

    helpText("Failure modes (check all that apply) and provide labels/descriptions as needed"),
 
    checkboxInput("is_material", "Material?", FALSE),
    conditionalPanel(
      condition = "input.is_material == true",
      textInput("is_material_label", "Material (additional information)", ""),
      checkboxInput("is_mat_raw", "Material: raw or consumable?", FALSE),
      conditionalPanel(
        condition = "input.is_mat_raw== true", 
	textInput("is_mat_raw_label", "Material- raw (additional information)", ""),

	checkboxInput("is_mat_raw_media", "Raw: media?", FALSE),
	conditionalPanel(
	  condition = "input.is_mat_raw_media== true",
	  textInput("is_mat_raw_media_label", "Media (additional information)", ""),
	  checkboxInput("is_mat_raw_media_contam", "Media Contaminated?",FALSE),
	  conditionalPanel(
	    condition = "input.is_mat_raw_media_contam == true",
	    textInput("is_mat_raw_media_contam_label", "Contamination (additional information)", "")
	  ),
	  checkboxInput("is_mat_raw_media_vol", "Media: Incorrect volume?", FALSE),
	  conditionalPanel(
	    condition = "input.is_mat_raw_media_vol == true",
	    textInput("is_mat_raw_media_vol_label", "Volume (additional information)", "")
	  ),
	  checkboxInput("is_mat_raw_media_comp", "Media incorrect components?", FALSE),
	  conditionalPanel(
	    condition = "input.is_mat_raw_media_comp == true",
	    textInput("is_mat_raw_media_comp_label", "Components (additional information)", "")
	  )
	)
      ),
      checkboxInput("is_mat_exp", "Material: experimental?", FALSE),
      conditionalPanel(
        condition = "input.is_mat_exp== true",
	textInput("is_mat_exp_label", "Experimental (additional information)", ""),
	checkboxInput("is_mat_exp_plate_group", "Is experimental material a plate-group?", FALSE),
	conditionalPanel(
	  condition = "input.is_mat_exp_plate_group == true",	
	  uiOutput("choose_plate_group")
	), 
	checkboxInput("is_mat_exp_plate", "Is experimental material a plate?", FALSE),
	conditionalPanel(
	  condition = "input.is_mat_exp_plate==true",
	  textInput("is_mat_exp_plate_label", "Plate ID?", "")
	),
	checkboxInput("is_mat_exp_well", "Is experimental material a well?", FALSE),
	conditionalPanel(
	  condition = "input.is_mat_exp_well==true",
	  textInput("is_mat_exp_well_label", "Well ID?", "")
	)
      )  
    ), 

    checkboxInput("is_equipment", "Equipment?", FALSE),
    conditionalPanel(
      condition = "input.is_equipment== true",
      textInput("is_equipment_label", "Equipment description (additional information)", ""),
      checkboxInput("is_equipment_biocell_cassette", "Is equipment a new biocell cassette?", FALSE),
      conditionalPanel(
	condition = "input.is_equipment_biocell_cassette == true",
	textInput("is_equipment_biocell_cassette_label", "Biocell cassette information", "replaced")
      ) 
    ), 

    checkboxInput("is_information", "Information?", FALSE),
    conditionalPanel(
      condition = "input.is_information == true", 
      textInput("is_information_label", "Information (details)", ""),

      checkboxInput("is_info_not_captured", "Info not otherwise captured?", FALSE),
      conditionalPanel(
	condition = "input.is_info_not_captured == true",
	textInput("is_info_not_captured_label", "Missing info description:", ""),

        checkboxInput("is_not_captured_bio", "Missing info Biocell calibration?", FALSE),
	conditionalPanel(
	  condition = "input.is_not_captured_bio == true",
	  textInput("biocell_calibration_label", "Biocell calibration:","")
	)	
      ),
      checkboxInput("is_meas", "Is info a measurement?", FALSE),
      conditionalPanel(
	condition = "input.is_meas == true",
	textInput("is_measurement_label", "Measurement detail:", "")
      )
    ),

    checkboxInput("is_process", "Process (methods)?", FALSE),
    conditionalPanel(
      condition = "input.is_process == true",
      textInput("process_label", "Process description:", "")
    ),

    checkboxInput("is_pers", "Personnel?", FALSE),
    conditionalPanel(
      condition = "input.is_pers == true",
      textInput("personnel_label", "Describe", ""),
      checkboxInput("is_pers_sched", "Is scheduling issue?", FALSE),
      conditionalPanel(
	condition = "input.is_pers_sched == true",
	textInput("pers_sched_label", "Describe scheduling issue", "")
      ),
      checkboxInput("is_safety", "Is safety involved?", FALSE),
      conditionalPanel(
	condition = "input.is_safety == true",
	textInput("safety_label", "Describe safety issue", "")
      )
    ),

    checkboxInput("is_illdefined", "Failure mode not clearly defined?", FALSE),
    conditionalPanel(
      condition = "input.is_illdefined == true",
      textInput("illdefined_label", "Describe failure mode:", "")
    ),

     
    helpText(""),

    actionButton("submit", "Submit"),

    helpText(""),

    actionButton("refresh", "Pull latest events ----------->")
),

  mainPanel(
   tabsetPanel(
    tabPanel("Recent events", dataTableOutput("showEvents")),
    tabPanel("Recent failure modes", dataTableOutput("showFails")),
    tabPanel("Failure mode ID key", dataTableOutput("showFailureID")),
    tabPanel("About", textOutput("allAboutUs"))
   )
  )
)
)

