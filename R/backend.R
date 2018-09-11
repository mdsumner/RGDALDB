#' @export
setMethod("dbGetInfo", "GDALDBConnection", function(dbObj, ...) {
  ## NONSENSE for now
  list(host = dbObj@dsn, serverVersion = "momoi",
       user = "dooda", port = "8765", dbname = "GDALFY")
} )



#' @export
db_desc.GDALDBConnection <- function(x) {
  info <- dbGetInfo(x)
  ## NONSENSE for now
  host <- if (info$host == "") "localhost" else info$host

  paste0("postgres ", info$serverVersion, " [", info$user, "@",
         host, ":", info$port, "/", info$dbname, "]")
}

