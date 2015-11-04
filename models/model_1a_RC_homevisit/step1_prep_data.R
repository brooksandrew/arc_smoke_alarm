#' ---
#' title: "Prep data for model 1a: RC smoke alarm presence from home visit"
#' author: Andrew Brooks
#' date: October 19, 2015
#' output:
#'    html_document:
#'      toc: true
#'      highlight: zenburn
#' ---


#' #### Getting setup
# set directory for project
# setwd('/Users/ajb/Google Drive/Red Cross/smokealarm')

# load libraries
library('data.table')
library('plyr')
library('stringr')
library('Rsenal') # install_github('brooksandrew/Rsenal')
library('tigris'); library('rgdal'); library('leaflet')
library('glmnet'); library('randomForest')

###################################
# TARGET VARIABLE: 
###################################

# load RC data 
rc <- data.table(read.csv('/Users/ajb/Google Drive/Red Cross/smokealarm/data/RedCross/HomeFire_SmokeAlarmInstalls.csv', stringsAsFactors=F))
rc[,fips:=str_pad(fips, 5, side='left', pad='0')]

#rc <- data.table(read.csv('data/RedCross/HFC_Oct2014_Sept2015.csv'))

# ### calculating share of home visits in county that led to smoke alarm install
# Note each county should belong to just one state, but the same city might be assigned to multiple counties
# and the the same county might be assigned multiple cities.
Mode <- function(x) unique(x)[which.max(table(x))] 
rcC <- rc[,.(N=.N, alarm_ins_pct=sum(alarms_ins>0)/.N, state=Mode(state), city=Mode(city)), by='fips']
rcC <- rcC[N>25,] #keeping just counties w stable data for ratio

###################################
# PREDICTORS:
###################################

# This is the data used with Enigma's 
acs <- fread('/Users/ajb/Google Drive/Red Cross/smokealarm/data/Census/acs.csv', stringsAsFactors=F)

# removing duplicate columns
acs <- acs[,duplicated(names(acs))==F, with=F]

# the acs tables have a full geoid, 
# but we need a simplified version to just 
# get the block-group summary level.
parse_id <- function(x) strsplit(x, 'US')[[1]][2]
parse_sum_level <- function(x) strsplit(x, 'US')[[1]][1]

acs$geoid2 <- as.character(unlist(llply(acs$geoid, parse_id)))
acs$sum_level <- as.character(unlist(llply(acs$geoid, parse_sum_level)))

# understanding census coding: https://www.census.gov/geo/reference/geoidentifiers.html
# sumlevel == 15000 is block group
# sumlevel == 14000 is census tract
# sumlevel == 05000 is county

# pulling out state and county for ease of use
acs$state <- substr(acs$geoid2, 0, 2)
acs$cnty <- substr(acs$geoid2, 3, 5)

acsC <- acs[sum_level=='05000',]
acsCT <- acs[sum_level=='14000',]

########################################
# MERGING PREDICTORS & TARGET VARIABLE:
########################################

setnames(acsC, 'geoid2', 'fips')
setkey(acsC, fips)
setkey(rcC, fips)
abtm <- merge(acsC, rcC, by='fips')

# removing variables that are missing more than a little bit
abtm[, `:=`(plumb_no=NULL, plumb_yes=NULL)]
abtm <- abtm[complete.cases(abtm)]

########################################
# MODELING
########################################

yvar <- 'alarm_ins_pct'
xvars <- names(abtm)[which(names(abtm)=='tenure_renter_occupied'):which(names(abtm)=='hdsb_yes')]

## RANDOM FOREST
xdf <- data.frame(abtm[,xvars, with=F])
y <- abtm[[yvar]]

rf <- randomForest(x=xdf, y=y, ntree=100)
rfImp(rf)

## GLM
form <- makeForm(yvar,xvars)
fitlm <- lm(form, data=abtm)

## LASSO
lasso <- glmnet(x=as.matrix(xdf), y=as.matrix(y), nlambda=20, alpha=1)
plot(lasso)

cv_lasso <- cv.glmnet(x=as.matrix(xdf), y=as.matrix(y), alpha=1, type.measure='deviance')
plot(cv_lasso)
bestlam <- cv_lasso$lambda.min
coef(lasso, s=bestlam)



########################################
# PREDICTING 
########################################

## Predicting on unvisited census tracts

## keeping just counties with no missing data
acsC_c <- acsC[complete.cases(acsC),]

acsC_c$pred_rf <- predict(rf, newdata=acsC_c, type='response')
acsC_c$pred_lasso <- predict(lasso, s=bestlam, newx=as.matrix(acsC_c[,xvars, with=F]))



########################################
# MAPPING
########################################

# getting base map from tigris
l48states <- str_pad(setdiff(1:56, c(2, 15, 60, 66, 72, 78)), 2, 'left', '0')
cntymap <- tigris::counties(state=l48states)
#plot(cntymap) # this works but it's slow

pred_df <- data.frame(acsC_c[,.(fips, pred_rf, pred_lasso)])

plotind <- 'pred_rf'
cntymap_merged <- geo_join(cntymap, pred_df, "GEOID", "fips")
pal <- colorQuantile("Greens", NULL, n = 10)
popup <- paste0("Probability of home needing smoke alarm in county: ", as.character(cntymap_merged[[plotind]]))

if(1==0) {
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = cntymap_merged, 
              fillColor = ~pal(cntymap_merged[[plotind]]), 
              fillOpacity = 0.7, 
              weight = 0.2, 
              popup = popup) %>%
  addLegend(pal = pal, 
            values = cntymap_merged[[plotind]], 
            position = "bottomright", 
            title = "Predictions")
}

# TO DO: create target variable at county level for red cross visits
# TO DO: download relevant NGHIS data at county level for model training
# TO DO: download same NGHIS data indicators at census tract level for model scoring


# rmarkdown::render('code/model_1a_RC_homevisit/step1_prep_data.R', output_file = 'step1_prep_data2.html')




