

### PLEASE PRESS ALT-O TO COLLAPSE ALL SECTIONS ###

# 0. READ ME ----

# What follows is a typical workflow for pulling data, slicking and dicing it, analyzing it, and plotting it.
# [Write more here.]

# 1. INSTALLING REQUIRED PACKAGES ----

# 1.0 Check your working directory and change it if needed:
# getwd()
# setwd("C:/Users/CHANGENAME.Amyris/Documents/CHANGEFILEPATH")

# 1.1 Check if required packages are installed and, if not, download and install them:
packages <- c("ggplot2","RODBC","gridExtra","plyr","MASS", "reshape2")
func <- function(x) {
  if (x %in% rownames(installed.packages()) == FALSE) {
    install.packages(x, dep = TRUE)
  }
  return("INSTALLED")
}
sapply(packages, func)

# 1.2 After installing a package you still have to load.  Use the 'library' function to do this:
  require("RODBC")      # This allows for database connectivity
  require("ggplot2")    # This is a great plotting package
  require("gridExtra")  # This allows you to plot multiple plots side-by-side easily
  require("plyr")       # This is great for manipulating data
  require("MASS")       # This allows one to build robust linear models
  require("reshape2")   # This is also great for manipulating data (stacking, splitting)

# 1.3 Install the 'amyRis' package

# You can't just use 'require' because this package is publicly available, so you have to tell R where to get it.
# The if statement below first checks if

if ("amyRis" %in% rownames(installed.packages()) == FALSE) {
  install.packages("amyRis", repos="http://hts-etl-01.amyris.local/R/", type="source")
}
require("amyRis")   # Requires RODBC to be installed!

# 2. PULLING YOUR DATA FROM DATAOUT ----

# 2.1 Open a database connection
db.wh <- sql_getDataoutConnection()

# 2.2 Define your database query:
query <- " SELECT DISTINCT *
            FROM [dataout].[furnace].[vw_po_plate_tank_data_asinh]
            WHERE Max_Yield > 11
            AND feed_type = 'Cane Syrup'
            AND temperature <> 30.34
            AND tank_alpha_reps > 1 
            AND xt4_reps > 1
            AND Max_Yield IS NOT NULL 
            AND Prod_Day_3_8 IS NOT NULL
            AND Yield_Day_3_8 IS NOT NULL
            AND FUVMO_maltrin IS NOT NULL"

# 2.3 Actually query the database
df <- sqlQuery(db.wh, query)

# 2.4 In case the DB breaks suddenly save a backup
if (nrow(df)>0) {
  df.backup <- df
}

# 2.5 Close the connection to the DB
odbcCloseAll()


# 2.4 Check if you pulled the right data
# head(df)      # This shows you the first 5 rows
# summary(df)   # This shows you a summary of the data by column
# names(df)     # This gives you a list of all the columns you pulled

# 3. CLEANING UP YOUR DATA ----

  # 3.1 Set data type to CATEGORICAL if so desired:
  df$has_switch   <- as.factor(df$has_switch)
  df$temperature  <- as.factor(df$temperature)
  df$overlay      <- as.factor(df$overlay)
  df$gen          <- as.factor(df$gen)
  
  # 3.2 Set data type to NUMERIC if so desired:
  df$FUVMO_maltrin <- as.numeric(as.character(df$FUVMO_maltrin))
  df$Max_Yield <- as.numeric(as.character(df$Max_Yield))
  
  # 3.3 Set data type to DATE if so desired:
  df$created_on_date <- as.Date(df$created_on_date)
  

  
  # 3.3 Subset your data.frame (in tis case to only keep non-switch strains):
  df              <- subset(df, has_switch == 0)

  

# 4. ADDING CALCULATED COLUMNS ----

# Create a new column with background subtraction:
df$FUVMO_maltrin_bsub   <- df$FUVMO_maltrin - 0.35

# 5. PERFORMING A (ROBUST) LINEAR MODEL ----

  # Before starting define the linear model:
  lm.formula           <- formula('Max_Yield ~ FUVMO_maltrin_bsub + temperature + overlay')
  
  # First an example of a normal linear model:
  df.lm             <- lm(lm.formula, data=df)    # Make the linear model object
  df.mean           <- mean(df$Max_Yield)         # Calculate the mean
  df.rmse           <- summary(df.lm)$sigma                 # Calculate the RMSE
  df.rmse_cv        <- 100*df.rmse/df.mean                  # Calculate the RMSE-CV
  df.rsq            <- summary(df.lm)$r.squared             # Calculate the R squared
  
  # Next an example of a robust linear model:
  df.rlm            <- rlm(lm.formula, data=df)   # Make the robust linear model object
  df.lm.weighted    <- lm(lm.formula, data=df, weight=df.rlm$w)   # Make a normal linear model but WEIGHT IT using the robust model
  df.median         <- median(df$Max_Yield)       # Calculate the median
  df.rmse_robust    <- summary(df.lm.weighted)$sigma        # Calculate the robust RMSE
  df.rmse_cv_robust <- 100*df.rmse_robust/df.median         # Calculate the robust RMSE-CV
  
  

  

# 6. PLOTTING YOUR DATA ----

# Plot #1: Yield vs Maltrin with a fit line:
my.plot.1 <- ggplot(df, aes(x=FUVMO_maltrin_bsub, y=Max_Yield)) +
  geom_point(aes(colour=temperature)) +
 
  geom_smooth(method='lm',formula=y~x, size=2, color="black") +
  geom_point(data=subset(df, tank_reps>3), aes(fill=temperature), size=4, shape=21, color="black") +
  theme_bw() +
  annotate("text", 
           x=min(df$FUVMO_maltrin_bsub), 
           y=max(df$Max_Yield)-1, 
           label=paste("RMSE-CV: ", toString(signif(df.rmse_cv,3)), "%", sep=""), hjust=0) +
  ylab("Tank Max Yield") +
  xlab("FUVMO_Maltrin (Background Subtracted)") 
my.plot.1

# Plot #2: Plot yield vs productivity and fit a polynomial to it
my.plot.2 <- ggplot(df, aes(x=Yield_Day_3_8, y=Prod_Day_0_8)) +
  theme_bw() +
  ylab("Date") +
  xlab("Yield") +
  stat_smooth(method = "lm", formula = y ~ poly(x, 2), size = 1) +
  geom_point(aes(color=lineage))
  
my.plot.2

# Plot both graphs together
grid.arrange(my.plot.1, my.plot.2, ncol=2)

# 7. SAVING YOUR DATA ----

# 7.1 Tell R that you want to make a png file:
png("TEST-my_figure.png", width = 12, height = 7, units = 'in', res=600)

# 7.2 Call your ggplot object that you made in the 'Plotting your data' section.
# Note: You won't see the output becaue it's being printed to a file.
grid.arrange(my.plot.1, my.plot.2, ncol=2)

# 7.3 Tell R that you're done and it should go ahead and make the file.
dev.off()

# 7.4 Save the data table:
write.table(df, 
            file=paste("TEST-dataout.csv", sep=""),
            sep=",", row.names=FALSE)
