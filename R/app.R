#' Launch Shiny App
#'
#' A function to launch the Shiny app.
#'
#' @export
launch_shiny_app <- function() {
  app_dir <- system.file("shiny_app", package = "ausrooftop")
  if (app_dir == "") {
    stop("Could not find Shiny app. Try re-installing `your_package_name`.", call. = FALSE)
  }
  shiny::runApp(app_dir, display.mode = "normal")
}
