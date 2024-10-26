#' Actual Solar Generation Data
#'
#' A dataset containing solar generation power data across regions.
#'
#' @format A data frame with 6720 rows and 6 variables:
#' \describe{
#'   \item{REGIONID}{character, region identifier}
#'   \item{INTERVAL_DATETIME}{character, datetime of each power generation interval}
#'   \item{DATE}{character, date of the power generation record}
#'   \item{TIME}{character, time of the power generation record}
#'   \item{POWER}{numeric, recorded power generation in megawatts}
#' }
"actual_RV_gen"
