#add test events to database

#add testing events
event <- list(
  time_stamp <- as.character(Sys.time()), 
  person <- c("Jabus"),
  event_description <- c("build testing"),
  tags <- c("justatest"),
  is_disabled <- 0
)

sql <- paste("INSERT INTO easybake.hts_et_meta_events VALUES ('", paste(event, collapse="','"), "')", sep="")

x <- pull(sql)

