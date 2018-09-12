#' @export
setMethod("dbGetInfo", "GDALDBConnection", function(dbObj, ...) {
  ## NONSENSE for now
  gdal <- sf::sf_extSoftVersion()["GDAL"]
  layers <- sf::st_layers(dbObj@dsn)

  list(dsn = dbObj@dsn, serverVersion = gdal,
       driver = gsub("\\s+", "_", layers$driver[1]), layers = layers$name)
} )



#' @export
db_desc.GDALDBConnection <- function(x) {
  info <- dbGetInfo(x)
  ## currently printing first layer, not the layer asked for in tbl(con, layer)
  ##sprintf("GDAL%s %s:%s:%s (of %i %s)", info$serverVersion, info$driver, info$dsn, info$layers[1], length(info$layers), ifelse(length(info$layers) > 1, "layers", "layer"))
  sprintf("GDAL%s %s:%s:<layer> (of %i %s)", info$serverVersion, info$driver, info$dsn,  length(info$layers), ifelse(length(info$layers) > 1, "layers", "layer"))
}

