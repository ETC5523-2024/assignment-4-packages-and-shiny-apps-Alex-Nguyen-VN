#' Actual Demand for June
#'
#' A dataset containing operation demand information across regions for June 2024.
#'
#' @format A data frame with 7200 rows and 9 variables:
#' \describe{
#'   \item{REGIONID}{character, region identifier}
#'   \item{INTERVAL_DATETIME}{character, datetime of each demand interval}
#'   \item{OPERATIONAL_DEMAND}{integer, recorded operational demand}
#'   \item{OPERATIONAL_DEMAND_ADJUSTMENT}{integer, adjustment to the operational demand}
#'   \item{WDR_ESTIMATE}{integer, wholesale demand response estimate}
#'   \item{LASTCHANGED}{character, timestamp of the last update}
#'   \item{DATE}{character, date of the demand record}
#'   \item{TIME}{character, time of the demand record}
#' }
"actual_demand_june"
