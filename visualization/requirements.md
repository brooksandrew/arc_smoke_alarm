### Visualization Requirements

--- 

This is a working list of the requirements for the smoke alarm tool to visualize risk scores geographically.

### Intended Use

This visualization is intended to be used by regional managers of the [Home Fire Preparedness Campaign] to prioritize neighborhoods to canvas with volunteers installing smoke alarms.  There are ~62 regions within the U.S. and each regional manager will want to view the most at-risk neighborhoods just within his/her region.  See this [regional map] and the wiki of this repo for more details on Red Cross regions.

### Content

* Choropleth/heatmap of risk score by census tract.  Risk score incorporates risk of not having a smoke alarm already, fire risk and injury/death risk.  It is still being fine-tuned, but assume it will be a score between 0 and 100.  Currently stored in `/visualization/data/risk_tract.csv`

### Presentation

We have received feedback that volunteers and regional managers are overwhelmed with multiple layers from existing ESRI applications.  While we have several risk indicators contributing to our overall "risk  score," we'd like to start visualizing just the aggregated risk score. 

### Features

* **Export to csv.**  Risk scores + geographic information (Census tract ID, county name/code, state, Red Cross region and any name to quickly identify the tract).
* **Print to pdf.**  We've received feedback that regional managers like print large maps to hang on walls in the office
* **List view.**  Whichever census tracts are shown on map (with current zoom) should be rendered in a rank-ordered list (table-view). 
* **Zoom in/out.**  Census tracts within small urban areas should be visible.  It would be nice to see national view as well.  Could aggregate (average across tracts) to county level if necessary for this view.
* **Red Cross region subset.**  Users should be able specify their Red Cross region and see a map of their region with the list view showing just that risk scores for that region's tract codes ranked from high to low.  Much like [Enigma's smoke signals project] does with MSA.  

### Benchmarking

This likely won't be included in first version of visualization tool, but we ultimately want to benchmark the performance of each region.  That is 

### Technical 

* Available publicly on the web 
* Free open source tools
* Fast rendering (feedback that slow rendering of ESRI maps has discouraged its adoption)
* AWS (EC2/S3) resources available (ask us)

<!-- LINKS --> 

[Home Fire Preparedness Campaign]: http://www.redcross.org/ca/victorville/home-fire-preparedness
[regional map]: http://maps.redcross.org/website/maps/images/NationalLevel/USREG.pdf
[Enigma's smoke signals project]: http://labs.enigma.io/smoke-signals/