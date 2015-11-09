# American Red Cross Smoke Alarm Project

**Purpose:** Help Red Cross Home Fire Preparedness Campaign target areas for smoke alarm installs.  Check out the repo [wiki](https://github.com/brooksandrew/arc_smoke_alarm/wiki) for more background information.

### Sketch of requirements for visualization (working doc)
* [Visualization requirements](visualization/requirements.md)

### Modeling ideas (working doc)
* https://docs.google.com/document/d/1oJN-QwLVqFHOvrRNtW2KEAkNZ-PuFiqTwa8y3iXx1Sg

### What's here

#### 1. `/models` 
Contains exploration and modeling code to produce risk scores for census tracts.  Each model or indicator has it's own folder.  The suffix of each folder name (_1a, _1c, _3a, etc) correspond to this [model scoping working doc]... which is subject to change.   Each folder should have the code necessary to generate the predictions/risk scores and a .csv of the risk scores themselves for each census tract.  Most model input data is too large to store on Github.  It lives on Google Drive or should be pointed to with a README.md if it's publicly available on the web.  This entire folder   

#### 2. `/visualization` 
  * **aggregate_models.R**: aggregates risk scores produced and stored in `\models` and stores in `visualization\data\risk_tract.csv`
  * 




[model scoping working doc]: https://docs.google.com/document/d/1oJN-QwLVqFHOvrRNtW2KEAkNZ-PuFiqTwa8y3iXx1Sg/edit


