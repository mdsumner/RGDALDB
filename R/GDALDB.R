#' Driver for GDALDB database.
#'
#' @keywords internal
#' @export
#' @import DBI
#' @import methods
setClass("GDALDBDriver", contains = "DBIDriver")

#' @export
#' @rdname GDALDB-class
setMethod("dbUnloadDriver", "GDALDBDriver", function(drv, ...) {
  TRUE
})


setMethod("show", "GDALDBDriver", function(object) {
  cat("<GDALDBDriver>\n")
})


#' @export
GDALDB <- function() {
  new("GDALDBDriver")
}





#' GDALDB connection class.
#'
#' @export
#' @keywords internal
setClass("GDALDBConnection",
         contains = "DBIConnection",
         slots = list(
           dsn = "character"
           #username = "character"#,
           # and so on
           #ptr = "externalptr"
         )
)



#' @param drv An object created by \code{GDALDB()}
#' @rdname GDALDB
#' @export
#' @examples
#' \dontrun{
#' db <- dbConnect(RGDALDB::GDALDB(), dsn = system.file("extdata/nc.gpkg", package= "RGDALDB"))
#' #dbWriteTable(db, "mtcars", mtcars)
#' dbGetQuery(db, "SELECT * FROM 'nc.gpkg' WHERE AREA < 0.07")
#' }
setMethod("dbConnect", "GDALDBDriver", function(drv, dsn = "", ...) {
  # ...

  new("GDALDBConnection", dsn = dsn, ...)
})

#' @rdname GDALDB
#' @export
setMethod("show", "GDALDBConnection", function(object) {
  cat("<GDALDBConnection>\n\n")
  cat(sprintf("DataSource: %s\n", object@dsn))
  ##cat(sprintf("Driver    : %s\n", unique(sf::st_layers(object@dsn)$driver)))
  cat(sprintf("Driver    : %s\n", vapour::vapour_driver(object@dsn)))
})
#' @rdname GDALDB
#' @export
setMethod("dbDisconnect", "GDALDBConnection", function(conn, ...) {
   TRUE
})


#' GDALDB results class.
#'
#' @keywords internal
#' @export
setClass("GDALDBResult",
         contains = "DBIResult",
         slots = list(data = "tbl_df")
)



#' Send a query to GDALDB
#'
#' @export
#' @examples
#' # This is another good place to put examples
setMethod("dbSendQuery", "GDALDBConnection", function(conn, statement, ...) {
  # some code
  #out <- sf::read_sf(conn@dsn, query = statement, ...)
  #class(out) <- setdiff(class(out), "sf")
 # out <- tibble::as_tibble(out)
  print(statement)
  geom <- try(tibble::tibble(geometry = as.character(vapour::vapour_read_geometry_text(conn@dsn, sql = statement, textformat = "json"))),
              silent = TRUE)

  att <- tibble::as_tibble(vapour::vapour_read_attributes(conn@dsn, sql = statement))
  ## a dummy join still won't work with this
  if (inherits(geom, "try-error")) geom <- rep(NA_character_, nrow(att))
  out <- dplyr::bind_cols(att, geom)
  new("GDALDBResult", data = out, ...)
})


#' @export
setMethod("dbClearResult", "GDALDBResult", function(res, ...) {
  # free resources
  TRUE
})


#' Retrieve records from GDALDB query
#' @export
setMethod("dbFetch", "GDALDBResult", function(res, n = -1, ...) {

  if (n > 0) dplyr::slice(res@data, 1:n) else res@data
})


#' @export
setMethod("dbHasCompleted", "GDALDBResult", function(res, ...) {
  TRUE
})


#' @export
setMethod("dbListTables", "GDALDBConnection", function (conn, ...) {
  sf::st_layers(conn@dsn)$name
}
)

#' @export
setMethod("dbExistsTable", "GDALDBConnection", function (conn, name, ...) {
  name %in% sf::st_layers(conn@dsn)$name
}
)

#' @export
setMethod("dbListFields", "GDALDBConnection", function (conn, name, ...)
{
  names(dbGetQuery(conn, sprintf("SELECT * FROM %s LIMIT 1", name)))
  })
