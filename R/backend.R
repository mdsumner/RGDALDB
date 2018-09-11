#' @export
setMethod("dbGetInfo", "GDALDBConnection", function(dbObj, ...) {
  ## NONSENSE for now
  gdal <- sf::sf_extSoftVersion()["GDAL"]
  layers <- sf::st_layers(dbObj@dsn)

  list(host = dbObj@dsn, serverVersion = gdal,
       user = gsub("\\s+", "_", layers$driver[1]), layers = length(layers$name))
} )



#' @export
db_desc.GDALDBConnection <- function(x) {
  info <- dbGetInfo(x)
  ## NONSENSE for now
  host <- if (info$host == "") "localhost" else info$host

  paste0("GDAL", info$serverVersion, " [", info$user, "@",
         host, ":(", info$layers, ")")
}

