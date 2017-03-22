install.packages("nycflights13")
library(nycflights13)
library(dplyr)

glimpse(flights)

daily <- flights %>% group_by(year,month,day) %>% summarise(flights = n())
groups(daily)
head(daily)

monthly <- daily %>% summarise(flights = sum(flights))
groups(monthly)
monthly

yearly <- monthly %>% summarise(flights = sum(flights))
groups(yearly)
yearly

flights_regrouped <- flights %>% group_by(day, year, month)
groups(flights_regrouped)

re_monthly <- flights_regrouped %>% summarise(flights = n())
groups(re_monthly)
head(re_monthly)


re_yearly <- re_monthly %>% summarise(flights = sum(flights))
groups(re_yearly)
re_yearly
#the sum of flights that occurred on day 1 of all months

re_daily <- re_yearly %>% summarise(flights = sum(flights)) 
groups(re_daily)
re_daily

