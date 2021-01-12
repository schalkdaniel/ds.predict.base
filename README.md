
<!-- README.md is generated from README.Rmd. Please edit that file -->

    ## Loading ds.predict.base

# Base Predict Function for DataSHIELD

## Overview

## Installation

#### Developer version:

The package is currently hosted at a private GitLab repository. If
access is granted, the installation can be done via `devtools`:

``` r
cred = git2r::cred_user_pass(username = "username", password = "password")
devtools::install_git("https://gitlab.lrz.de/difuture_analysegruppe/ds.predict.base.git", credentials = cred)
```

Note that you have to supply your username and password from GitLab to
install the package.

#### Register assign methods

It is necessary to register the assign methods in the OPAL
administration to use them. The assign methods are (with namespaces):

  - `ds.predict.base::decodeModel`
  - `ds.predict.base::assignPredictModel`

## Usage

The following code shows the basic methods and how to use them. Note
that this package is intended for internal usage and base for the other
packages and does not really have any practical usage for the analyst.

``` r
library(DSI)
#> Loading required package: progress
#> Loading required package: R6
library(DSOpal)
#> Loading required package: opalr
#> Loading required package: httr
library(DSLite)
library(dsBaseClient)

# library(ds.predict.base)

builder = DSI::newDSLoginBuilder()

builder$append(
  server   = "ibe",
  url      = "https://dsibe.ibe.med.uni-muenchen.de",
  user     = "ibe",
  password = "123456",
  table    = "ProVal.KUM"
)

logindata = builder$build()
connections = DSI::datashield.login(logins = logindata, assign = TRUE, symbol = "D", opts = list(ssl_verifyhost = 0, ssl_verifypeer=0))
#> 
#> Logging into the collaborating servers
#>   Logged in all servers [================================================================] 100% / 1s
#> 
#>   No variables have been specified. 
#>   All the variables in the table 
#>   (the whole dataset) will be assigned to R!
#> 
#> Assigning table data...
#>   Assigned all tables [==================================================================] 100% / 2s

### Get available tables:
DSI::datashield.symbols(connections)

### Test data with same structure as data on test server:
dat   = cbind(age = sample(20:100, 100L, TRUE), height = runif(100L, 150, 220))
probs = 1 / (1 + exp(-as.numeric(dat %*% c(-3, 1))))
dat   = data.frame(gender = rbinom(100L, 1L, probs), dat)

### Model we want to upload:
mod = glm(gender ~ age + height, family = "binomial", data = dat)
#> Warning: glm.fit: algorithm did not converge
#> Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

### Upload model to DataSHIELD server
pushModel(connections, mod)
#>   Assigned expr. (mod <- decodeModel("58-0a-00-00-00-03-00-04-00-00-00-03-05-00-00-00-00-05-55-54...

# Check if model "mod" is now available:
DSI::datashield.symbols(connections)

# Check class of uploaded "mod"
ds.class("mod")
#>   Aggregated (exists("mod")) [===========================================================] 100% / 0s
#>   Aggregated (classDS("mod")) [==========================================================] 100% / 0s

# Now predict on uploaded model and data set D:
predictModel(connections, mod, "pred", dat_name = "D")
#>   Assigned expr. (pred <- assignPredictModel("58-0a-00-00-00-03-00-04-00-00-00-03-05-00-00-00-00-...

# Check if prediction "pred" is now available:
DSI::datashield.symbols(connections)

# Summary of "pred":
ds.summary("pred")
#>   Aggregated (exists("pred")) [==========================================================] 100% / 0s
#>   Aggregated (classDS("pred")) [=========================================================] 100% / 0s
#>   Aggregated (isValidDS(pred)) [=========================================================] 100% / 0s
#>   Aggregated (lengthDS("pred")) [========================================================] 100% / 0s
#>   Aggregated (quantileMeanDS(pred)) [====================================================] 100% / 0s

# Now assign values with response type "response":
predictModel(connections, mod, "pred", "D", predict_fun = "predict(mod, newdata = D, type = 'response')")
#>   Assigned expr. (pred <- assignPredictModel("58-0a-00-00-00-03-00-04-00-00-00-03-05-00-00-00-00-...

ds.summary("pred")
#>   Aggregated (exists("pred")) [==========================================================] 100% / 0s
#>   Aggregated (classDS("pred")) [=========================================================] 100% / 0s
#>   Aggregated (isValidDS(pred)) [=========================================================] 100% / 0s
#>   Aggregated (lengthDS("pred")) [========================================================] 100% / 0s
#>   Aggregated (quantileMeanDS(pred)) [====================================================] 100% / 0s
```
