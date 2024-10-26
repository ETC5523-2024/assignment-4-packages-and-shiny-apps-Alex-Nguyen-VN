## code to prepare `actual demand` and `estimate rooftop generation` dataset goes here

library(lubridate)

folder_path <- "data-raw/Public_Actual_Demand_2024_June"
file_list_1 <- list.files(path = folder_path, full.names = TRUE)

actual_demand_june <- do.call(rbind, lapply(file_list_1, function(file) {
  readr::read_csv(file, skip = 2, n_max = 240, col_select = -c(1,2,3,4), col_name = FALSE)
}))
actual_demand_june <- actual_demand_june |>
  dplyr::rename(
    REGIONID = X5,
    INTERVAL_DATETIME = X6,
    OPERATIONAL_DEMAND = X7,
    OPERATIONAL_DEMAND_ADJUSTMENT = X8,
    WDR_ESTIMATE = X9,
    LASTCHANGED = X10
  )
actual_demand_june <- actual_demand_june |>
  dplyr::mutate(
    DATE = as.Date(INTERVAL_DATETIME),
    TIME = stringr::str_extract(INTERVAL_DATETIME, pattern = "\\d{2}:\\d{2}:\\d{2}"),
    REGIONID = as.factor(REGIONID),
    OPERATIONAL_DEMAND = as.numeric(OPERATIONAL_DEMAND),
    OPERATIONAL_DEMAND_ADJUSTMENT = as.numeric(OPERATIONAL_DEMAND_ADJUSTMENT),
    WDR_ESTIMATE = as.numeric(WDR_ESTIMATE),
  )

actual_demand_june <- actual_demand_june |>
  dplyr::mutate(TIME = lubridate::hms(TIME))

# Step 2: List all the CSV files in the folder
folder_path_2 <- "data-raw/rooftop"
file_list_2 <- list.files(path = folder_path_2, pattern = "*.csv", full.names = TRUE)

# Step 3: Load and combine all CSV files into one dataset
actual_RV_gen <- do.call(rbind, lapply(file_list_2, function(file) {
  readr::read_csv(file, skip = 2, n_max = 10, col_select = -c(1,2,3,4), col_name = FALSE)
}))

actual_RV_gen <- actual_RV_gen |>
  dplyr::select(-X9,-X10) |>
  dplyr::rename(
    INTERVAL_DATETIME = X5,
    REGIONID = X6,
    POWER = X7,
    QI = X8)
actual_RV_gen <- actual_RV_gen |>
  dplyr::mutate(
    DATE = as.Date(INTERVAL_DATETIME),
    TIME = stringr::str_extract(INTERVAL_DATETIME, pattern = "\\d{2}:\\d{2}:\\d{2}"),
    REGIONID = as.factor(REGIONID),
    POWER = as.numeric(POWER)
  ) |>
  dplyr::select(-QI) |>
  dplyr::select(REGIONID, INTERVAL_DATETIME, DATE, TIME, POWER)

actual_RV_gen <- actual_RV_gen |>
  dplyr::filter(REGIONID %in% c("QLD1", "NSW1", "VIC1", "TAS1", "SA1"))

actual_RV_gen <- actual_RV_gen |>
  dplyr::mutate(TIME = lubridate::hms(TIME))

usethis::use_data(actual_RV_gen, overwrite = TRUE)
usethis::use_data(actual_demand_june, overwrite = TRUE)
