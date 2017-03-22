####   UI
#### see server.R for version notes

library(shiny)

shinyUI(pageWithSidebar(
  headerPanel("HTS Event Capture"),   # Application title

  sidebarPanel(

### start of event capure section

    helpText("Enter event information below:"),
    uiOutput("get_the_date_and_time"),
    #textInput("time_stamp", "Date and time of event (refresh browser to update time and clear all fields):", Sys.time()),
    helpText("Note: event date-time stamp can refer to the past."),
    radioButtons("time_setting", "Duration of event:", choices=c("One-off", "Open-ended"), selected=c("One-off")),

    uiOutput("choose_observer_name"),

    textInput("event_desc", "Event description", ""),
    helpText("____________________________"),

### start of fail mode capture ###
#	-- can this be automated using generator code?
    
    checkboxInput("is_testing", "Click if you're just testing out HTS Event Capture for fun", FALSE),

    helpText("____________________________")
 
    , helpText("Tags and failure modes (check all that apply) and provide labels/descriptions as needed")
    , checkboxInput("is_pg2", "Involves a plate-group/library?", FALSE),
    conditionalPanel(
      condition = "input.is_pg2 == true",	
      uiOutput("choose_plate_group2")
    )
    , checkboxInput("is_material", "Material?", FALSE),
    conditionalPanel(
      condition = "input.is_material == true",
      textInput("is_material_label", "Material (additional information)", ""),
      checkboxInput("is_mat_raw", "Material: raw or consumable?", FALSE),
      conditionalPanel(
        condition = "input.is_mat_raw== true", 
	textInput("is_mat_raw_label", "Material- raw (additional information)", "")
	, checkboxInput("is_53", "PI vial?", FALSE),
	conditionalPanel(
	  condition = "input.is_53 == true",
	  textInput("is_53_label", "Scan vial lot no.", ""),
	  checkboxInput("is_54", "PI killing agent (SDS)?",FALSE),
	  conditionalPanel(
	    condition = "input.is_54 == true"
	    , textInput("is_54_label", "Scan SDS chem inventory barcode", "")
	  )
        , helpText("__")
	)
	, checkboxInput("is_50", "New PI 20 mM batch?", FALSE),
	conditionalPanel(
	  condition = "input.is_50 == true",
	  #textInput("is_50_label", "Other comments or first vial barcode", ""),
	  checkboxInput("is_51", "PI lot no.", TRUE),
	  conditionalPanel(
	    condition = "input.is_51 == true",
	    textInput("is_51_label", "Scan PI lot barcode", "")
	  )
	  , checkboxInput("is_52", "DMSO lot no.", TRUE),
	  conditionalPanel(
	    condition = "input.is_52 == true"
	    , textInput("is_52_label", "Scan DMSO lot barcode", "")
	    , helpText("__")
	  )
	)

	, checkboxInput("is_mat_raw_media", "Raw: media?", FALSE),
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
    , helpText("__")
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
    , helpText("__")
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
	  #textInput("biocell_calibration_label", "Biocell calibration:",""),
          checkboxInput("is_not_captured_bio_fuv_vol", "Biocell calibration FUVMO vol", TRUE),
	  conditionalPanel(
	    condition = "input.is_not_captured_bio_fuv_vol == true",
	    textInput("fuv_vol_value", "Enter vol (ul)","")
	  ),
	  checkboxInput("is_not_captured_bio_fuv_cv", "Biocell calibration FUVMO CV", TRUE),
	  conditionalPanel(
	    condition = "input.is_not_captured_bio_fuv_cv == true",
	    textInput("fuv_cv_value", "Enter CV","")
	  ),
	  checkboxInput("is_not_captured_bio_fuv_mass", "Biocell calibration FUVMO mass", TRUE),
	  conditionalPanel(
	    condition = "input.is_not_captured_bio_fuv_mass == true",
	    textInput("fuv_mass_value", "Enter mass (g)","")
	  ),
	  checkboxInput("is_not_captured_bio_ssod_cv", "Biocell calibration ssOD CV", TRUE),
	  conditionalPanel(
	    condition = "input.is_not_captured_bio_ssod_cv == true",
	    textInput("ssod_cv_value", "Enter CV","")
	  ),
	  checkboxInput("is_not_captured_bio_ssod_mass", "Biocell calibration ssOD mass", TRUE),
	  conditionalPanel(
	    condition = "input.is_not_captured_bio_ssod_mass == true",
	    textInput("ssod_mass_value", "Enter mass (g)","")
	  )
	)	
      ),
      checkboxInput("is_meas", "Is info a measurement?", FALSE),
      conditionalPanel(
	condition = "input.is_meas == true",
	textInput("is_measurement_label", "Measurement detail:", "")
      )
    , helpText("__")
    ),

    checkboxInput("is_process", "Process (methods)?", FALSE),
    conditionalPanel(
      condition = "input.is_process == true"
      #textInput("process_label", "Process description:", "")
      , checkboxInput("is_35", "Plate filling or plate labeling?", FALSE)
      , conditionalPanel(
	condition = "input.is_35 == true"
	, textInput("is_35_label", "Other details:", "")
      )
      , checkboxInput("is_36", "Colony picking?", FALSE)
      , conditionalPanel(
	condition = "input.is_36 == true"
	, textInput("is_36_label", "Other details:", "")
      )
      , checkboxInput("is_37", "Mutagenesis and plating?", FALSE),
      conditionalPanel(
	condition = "input.is_37 == true",
	textInput("is_37_label", "Other details:", "")
      )
      , checkboxInput("is_38", "T1 dilutions?", FALSE),
      conditionalPanel(
	condition = "input.is_38 == true",
	textInput("is_38_label", "Other details:", "")
      )
      , checkboxInput("is_39", "Biocell FUVMO/SSOD/NR?", FALSE),
      conditionalPanel(
	condition = "input.is_39 == true",
	textInput("is_39_label", "Other details:", "")
      )
      , checkboxInput("is_40", "T1 hitpicking?", FALSE),
      conditionalPanel(
	condition = "input.is_40 == true",
	textInput("is_40_label", "Other details:", "")
      )
      , checkboxInput("is_41", "XT4 consolidation/dilution?", FALSE),
      conditionalPanel(
	condition = "input.is_41 == true",
	textInput("is_41_label", "Other details:", "")
      )
      , checkboxInput("is_42", "Surveillance?", FALSE),
      conditionalPanel(
	condition = "input.is_42 == true",
	textInput("is_42_label", "Other details:", "")
      )
### insert CORE tree here:
      , checkboxInput("is_55", "CORE?", FALSE),
      conditionalPanel(
	condition = "input.is_55 == true"
	#textInput("is_55_label", "Other details:", "")
        , checkboxInput("is_56", "CORE Biocell error?", FALSE)
	, conditionalPanel(
	  condition = "input.is_56 == true"
	  #, textInput("is_56_label", "Other details:", "") 
          , checkboxInput("is_57", "SSOD", FALSE)
          , conditionalPanel(
	    condition = "input.is_57 == true"
	    , textInput("is_57_label", "Additional details:", "")
	  )#57
           , checkboxInput("is_58", "FUVMO", FALSE)
          , conditionalPanel(
	    condition = "input.is_58 == true"
	    , textInput("is_58_label", "Additional details:", "")
	  )#58
            , checkboxInput("is_59", "PI Viability", FALSE)
          , conditionalPanel(
	    condition = "input.is_59 == true"
	    , textInput("is_59_label", "Additional details:", "")
	  )#59
          , checkboxInput("is_other2", "Other", FALSE)
          , conditionalPanel(
	    condition = "input.is_other2 == true"
	    , textInput("is_other2_label", "Details:", "")
	  )#other2 
	, helpText("__")
	) #56
        , checkboxInput("is_61", "CORE processing error?", FALSE)
        , conditionalPanel(
	  condition = "input.is_61 == true"
	  #, textInput("is_61_label", "Details:", "")
          , checkboxInput("is_43", "CORE dilutions", FALSE)
          , conditionalPanel(
	    condition = "input.is_43 == true"
	    , textInput("is_43_label", "Additional details:", "")
	  )#43
          , checkboxInput("is_63", "ATR shaking incubator", FALSE)
          , conditionalPanel(
	    condition = "input.is_63 == true"
	    , textInput("is_63_label", "Additional details:", "")
	  )#63
          , checkboxInput("is_other2_3", "Other (CORE processing error)?", FALSE)
          , conditionalPanel(
	    condition = "input.is_other2_3 == true"
	    , textInput("is_other2_3_label", "Details:", "")
	  )#other2_3
	, helpText("__")
	)#61 
        , checkboxInput("is_62", "CORE user error?", FALSE)
        , conditionalPanel(
	  condition = "input.is_62 == true"
	  #, textInput("is_62_label", "Details:", "")
          , checkboxInput("is_64", "Missing plate map?", FALSE)
          , conditionalPanel(
	    condition = "input.is_64 == true"
	    , textInput("is_64_label", "Additional details:", "")
	  )#64
          , checkboxInput("is_65", "Incorrect parameters?", FALSE)
          , conditionalPanel(
	    condition = "input.is_65 == true"
	    , textInput("is_65_label", "Additional details:", "")
	  )#65
          , checkboxInput("is_other2_4", "Other (CORE user error)?", FALSE)
          , conditionalPanel(
	    condition = "input.is_other2_4 == true"
	    , textInput("is_other2_4_label", "Details:", "")
	  )#other2_4
	, helpText("__")
	)#61  
      , checkboxInput("is_45", "CORE extractions?", FALSE),
      conditionalPanel(
	condition = "input.is_45 == true",
	textInput("is_45_label", "Other details:", "")
      )
      , checkboxInput("is_14", "CORE plates?", FALSE),
      conditionalPanel(
	condition = "input.is_14 == true",
	textInput("is_14_core_label", "Scan plate barcode(s) (separate multiple entries with a comma: ','):", "")
      )
      
      , checkboxInput("is_other_2_5", "CORE Other?", FALSE),
      conditionalPanel(
	condition = "input.is_other_2_5 == true",
	textInput("is_other_2_5_label", "Details:", "")
      )
      , helpText("__")
      ) #end CORE (55)

      , checkboxInput("is_44", "Seed Vialing?", FALSE),
      conditionalPanel(
	condition = "input.is_44 == true",
	textInput("is_44_label", "Other details:", "")
      )
      , checkboxInput("is_46", "ST4?", FALSE),
      conditionalPanel(
	condition = "input.is_46 == true",
	textInput("is_46_label", "Other details:", "")
      )
      , checkboxInput("is_47", "Tier 4 hitpicking?", FALSE),
      conditionalPanel(
	condition = "input.is_47 == true",
	textInput("is_47_label", "Other details:", "")
      )
      , checkboxInput("is_48", "Assay development?", FALSE),
      conditionalPanel(
	condition = "input.is_48 == true",
	textInput("is_48_label", "Other details:", "")
      )
      , checkboxInput("is_49", "Crimsen Red alert?", FALSE),
      conditionalPanel(
	condition = "input.is_49 == true",
	textInput("is_49_label", "Other details:", "")
	#, helpText("") 
      )
    , helpText("__")
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
    , helpText("__")
    ),

    checkboxInput("is_illdefined", "Failure mode not clearly defined?", FALSE),
    conditionalPanel(
      condition = "input.is_illdefined == true",
      textInput("illdefined_label", "Describe failure mode:", "")
    ),

#### end of failure mode section
     
    helpText("____________________________"),

     actionButton("submit", "Submit event (clears table if successful)"),

    helpText(""),

    actionButton("refresh", "Pull latest events ----------->")
),

  mainPanel(
   tabsetPanel(
    tabPanel("Recent events", dataTableOutput("showEvents")),
    tabPanel("Recent tags & failure modes", dataTableOutput("showFails")),
    tabPanel("Tag & Failure Mode ID key", dataTableOutput("showFailureID")),
    tabPanel("Tag hierarchy", dataTableOutput("showRelations")),
    tabPanel("About", textOutput("allAboutUs"))
   )
  )
)
)

