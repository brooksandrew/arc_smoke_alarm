## This script generates the weighted indicator of "risk" to plot for each census tract that will be used for the map visualization.
## This data will be stored in /data/risk_tract.csv.


## libraries
library('data.table')

# dt1a <- fread('models/model_1a_RC_homevisit/results/') # still working creating this scores
dt1c <- fread('models/model_1c_enigma_ahs_smokealarm/results/smoke-alarm-risk-scores.csv')

#######################################
## Processing results from Model 1.C ##
#######################################

## separating out geographies. block from census tract
dt1c[,bg_geoid:=as.character(bg_geoid)]
dt1c[,block:=substr(bg_geoid, nchar(bg_geoid)-3, nchar(bg_geoid))]
dt1c[,census_tract:=gsub('.{4}$', '', bg_geoid)]
dt1c[,state:=gsub('.{6}$', '', census_tract)]
dt1c[,tract:=substr(census_tract, nchar(census_tract)-2L, nchar(census_tract))]
dt1c[,county:={tmp=gsub('.{3}$', '', census_tract); county=substr(tmp, nchar(tmp)-2, nchar(tmp))}]

## calculating census tract-level risk.
## TO DO: need to figoure out why census tract is only returning 9549 obs.  Should be ~70,000.
dt1c_tract <- dt1c[,.(
  smoke_alarm_risk=mean(smoke_alarm_risk),
  tract_pop=sum(bg_pop),
  blocks_per_tract=.N
), by=.(census_tract)]

write.table(dt1c_tract, file='visualization/data/risk_tract.csv', sep=',', row.names=F)

