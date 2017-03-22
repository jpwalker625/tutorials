# File Name: TUTORIAL_linear_models_BK.R
# Purpose: Brief tutorial on how to make linear models in R
# Author: Ben Kaufmann-Malaga
# Date: 2015-11-09

################    SETUP: Installing the required packages    ################

#install.packages("amyRis", repos="http://hts-etl-01.amyris.local/R/", type="source")

# Import some packages:
require("ggplot2")    # This is a great plotting package
require("gridExtra")  # This allows you to plot multiple plots side-by-side easily
require("plyr")       # This is great for manipulating data
require("MASS")       # This allows one to build robust linear models
require("reshape2")   # This is also great for manipulating data (stacking, splitting)
require("magrittr")
require("amyRis")

################    SETUP: Getting a data set with which to play    ################

# Query the DB to get a fun data set to play with:
db.wh <- sql_getDataoutConnection()
query <- " SELECT DISTINCT * FROM [dataout].[furnace].[vw_po_plate_tank_data_asinh]
            WHERE Max_Yield > 11
            AND feed_type = 'Cane Syrup'
            AND tank_alpha_reps > 1 
            AND xt4_reps > 1
            AND Max_Yield IS NOT NULL 
            AND Prod_Day_3_8 IS NOT NULL
            AND Yield_Day_3_8 IS NOT NULL
            AND FUVMO_maltrin IS NOT NULL
            AND FUVMO_sucrose IS NOT NULL"
df  <- sqlQuery(db.wh, query)
odbcCloseAll()

# Make a cache of the data in case the connection later fails:
if (nrow(df)>0) {
  df.cache <- df
}

# Ensure the data types are as desired:
df$has_switch     <- as.factor(df$has_switch)
df$temperature    <- as.factor(df$temperature)
df$overlay        <- as.factor(df$overlay)
df$gen            <- as.factor(df$gen)
df$feed_type      <- as.factor(df$feed_type)
df$FUVMO_maltrin  <- as.numeric(as.character(df$FUVMO_maltrin))
df$FUVMO_sucrose  <- as.numeric(as.character(df$FUVMO_sucrose))
df$Max_Yield      <- as.numeric(as.character(df$Max_Yield))

################    MODEL FORMULAS: Specifying your linear model    ###############

# The model formula defines:
# - Your response variable (i.e., the thing you are trying to predict)
# - Your factors (i.e., the things that you are using to build your prediction)
# - The possible relationships between your factors (e.g., interactions, main effects, etc.)

# Here is an example of a linear models with no interactions:
lm.formula    <- formula('Max_Yield ~ FUVMO_sucrose + temperature + overlay') 

# Here is the same linear model as the first example, but adding an interaction term.
# Note that there are two ways to write this:
# - Using the ":" operator to add it separately
# - Using the "*" operator to combine the main effects and interactions
lm.formula    <- formula('Max_Yield ~ FUVMO_sucrose + temperature + overlay + temperature:overlay')
lm.formula    <- formula('Max_Yield ~ FUVMO_sucrose + temperature * overlay')

# Here is a way of getting all crossed interactions for a few variable, removing the cubic highest order
lm.formula    <- formula('Max_Yield ~ FUVMO_sucrose*temperature*overlay - FUVMO_sucrose:temperature:overlay')

################    RUNNING YOUR LINEAR MODELS AND GETTING BASIC RESULTS    ################

# Running the model itself is simple as pie:
df.lm             <- lm(lm.formula, data=df)

# You can get a summary of the model using (unsurprisingly) the summary function:
summary(df.lm)
df.lm.summary <- summary(df.lm)

# From this you can extract all kinds of useful parameters like:
df.rmse           <- df.lm.summary$sigma          # The root mean squared error (RMSE)
df.coeff.complex  <- df.lm.summary$coefficients   # The coefficients of the model WITH error and p-vals
df.coefficients   <- coef(df.lm)                  # Just the coefficients
df.residuals      <- df.lm.summary$residuals      # The residuals (error) for each data point
df.rsq            <- df.lm.summary$r.squared      # The R squared
df.adj.rsq        <- df.lm.summary$adj.r.squared  

# Get the fitted values:
df.fitted         <- fitted(df.lm)

# If you want to calculate your model's RMSE_CV you can do it this way:
df.mean           <- mean(df$Max_Yield) 
df.rmse_cv        <- 100*df.rmse/df.mean                  # Calculate the RMSE-CV

# You might want to know about the statistical significance of your factors.  For that, use an anova:
anova(df.lm)
#summary(aov(df.lm))


################    LOOKING AT YOUR DATA    ################

# First let's look at actual vs. predicted (fitted):
plot(df$Max_Yield, fitted(df.lm))

# You could compare that to what you'd get if you just used FUVMO_sucrose:
par(mfrow=c(1,2))
plot(df$Max_Yield, df$FUVMO_sucrose)
plot(df$Max_Yield, fitted(df.lm))
par(mfrow=c(1,1))

# Here is a nice way to look at how well the linear model did:
par(mfrow=c(2,2))
plot(df.lm)
par(mfrow=c(1,1))

# The Residuals vs Fitted plot show if the errors in the model tend to clump on one end.  You'd like to see no horizontal trend (i.e., the red line flat and at 0) with equal numbers of points above and below the abscissa.

# The Normal Q-Q plot shows if the errors (in aggregate) are normally distributed.  You want to see the points lie across the diagonal line.  If the tails on the left or right fall off the dashed diagonal line then you know the assumption of normality is being violated.  If there is a violation then you might want to consider a "GLM" - a Generalized Linear Model.  They act in exactly the same way as regular LMs but require one additional parameter that specifies the expected structure of the noise (Gaussian, Poisson, Binomial, etc.)
# Learn more about GLMs here: http://data.princeton.edu/R/glms.html


# Add something here about predict: predict(df.lm, data.frame(*******), level = 0.9, interval = "confidence")

################    ROBUST LINEAR MODELS    ################

# Sometimes a few data points are outliers and they can wreak havoc on your linear model
# To avoid that becoming disasterious use a robust linear model like the following. 
# N.B.: Interaction terms tend to be problematic here, preventing the model from converging
# on an answer:
df.rlm            <- rlm(lm.formula, data=df)

# One problem is that RLM objects have fewer bells and whistles than ordinary LMs.
# If you want to be able to use all the same features normal LMs with an RLM object
# you can use this clever trick: Make a new LM object and pass to that object the 
# "weights" of your RLM object:

df.lm.weighted    <- lm(lm.formula, data=df, weight=df.rlm$w)

# You can then calcualte robust means (i.e., medians) and robust RMSE-CVs:
df.median         <- median(df$Max_Yield)       # Calculate the median
df.rmse_robust    <- summary(df.lm.weighted)$sigma        # Calculate the robust RMSE
df.rmse_cv_robust <- 100*df.rmse_robust/df.median         # Calculate the robust RMSE-CV


