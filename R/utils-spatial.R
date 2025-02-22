
#' Return an axis-aligned bounding box delimiting a circle at distance \code{d}
#'
#' @description
#' \lifecycle{experimental}
#'
#' \code{bbox_at_distance} returns an \code{\link[sf:st_bbox]{st_bbox}} object representing
#' the extent of an axis-aligned bounding box containing the (polygonal approximation of a)
#' a circle at dithance \code{d}.
#'
#'  WARNING: current implementation relies on \code{polygon_at_distance} which is
#'  not robust to cope with circles containing the Poles or crossing the date line.
#'
#' @param geo a geographical position [lon, lat]
#' @param d   a distance in Nautical Miles
#' @param ... other params
#'
#' @return an \code{\link[sf:st_bbox]{st_bbox}} object
#' @export
#' @family spatial
#'
#' @examples
#' \dontrun{
#' fra <- c(8.570556, 50.03333) # Frankfurt Airport (longitude, latitude)
#' bbox_at_distance(fra, 40)
#' }
bbox_at_distance <- function(geo, d, ...) {
  polygon_at_distance(geo, d, ...) %>%
    sf::st_bbox()
}

#' Generate the polygon at distance d from a geographical location
#'
#' @description
#'
#' \lifecycle{experimental}
#'
#' \code{polygon_at_distance} returns a polygon approximating a circonference
#'  at distance \code{d}, in Nautical Miles, from the location \code{geo}.
#'  You can control how many points per quadrant will be used via the
#'  \code{nQuadSegs} parameter (the default of 30 from \link[sf:st_buffer]{st_buffer} should
#'  suffice for most of the needs.)
#'
#'  WARNING: this is not tested to work across the date line or for polygons
#'  containing the poles or for polygons spanning more than half an emisphere.
#'
#' @param geo a geographical location in lon/lat (WGS84)
#' @param d   a distance in Nautical Miles
#' @param ... other parameters, for example \code{nQuadSegs};
#'            see also \code{\link[sf:st_buffer]{st_buffer}}
#'
#' @return a polygon.
#' @export
#' @family spatial
#'
#' @examples
#' \dontrun{
#' fra <- c(8.570556, 50.03333) # Frankfurt Airport (longitude, latitude)
#' polygon_at_distance(fra, 40)
#' }
polygon_at_distance <- function(geo, d, ...) {
  ref <- geo %>%
    sf::st_point() %>%
    sf::st_sfc(crs = 4326)

  # define radius of interest
  r <- d * 1852

  # change to Irish grid, which uses meters
  ref <- sf::st_transform(ref, 29902)
  ref_poly <-  sf::st_buffer(ref, r, ...) %>%
    sf::st_transform(crs = 4326)
  ref_poly
}


# from http://rstudio-pubs-static.s3.amazonaws.com/19324_dd865f50a2304595b45d86f3022f4681.html
#' Calculate the coordinates of the axis-aligned bounding box
#'
#' @description
#' \lifecycle{experimental}
#'
#' Calculate a bounding box for a center point given a set of coordinates.
#'
#' @param lat latitude of the center point  [decimal degrees].
#' @param lon longitude of the center point [decimal degrees].
#' @param d   distance from the center point in Nautical Miles.
#'
#' @return Returns a matrix with max/min latitude/longitude values.
#'
#' @references \url{http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates}
#' @keywords bounding_box, coordinates
#' @export
#' @family spatial
#' @examples
#' \dontrun{
#' bounding_box(38.8977, 77.0366, 1)
#' }
bounding_box <- function(lat, lon, d) {

  ## Helper functions
  `%+/-%` <- function(x, margin) {x + c(-1, +1) * margin}
  deg2rad <- function(x) {x / (180 / pi)}
  rad2deg <- function(x) {x * (180 / pi)}
  coord_range <- function(ll, r) rad2deg(ll %+/-% r)

  r   <- d * 1.852 / 6371
  lat <- deg2rad(lat)
  lon <- deg2rad(lon)

  latT      <- asin(sin(lat) / cos(r))
  delta_lon <- asin(sin(r)   / cos(lat))

  m <- matrix(c(coord_range(ll = lon,  r = delta_lon),
                coord_range(ll = latT, r = r)),
              nrow = 2,
              byrow = TRUE)

  dimnames(m) <- list(c("lon", "lat"), c("min", "max"))
  rad2deg(m)
}

#' Retain only positions within a range from a location.
#'
#' The points whose distance, \code{.distance}, satisfies
#' \deqn{dm <= .distance < dM}
#' are kept (\code{.exclude = FALSE}) or excluded (\code{.exclude = TRUE})
#'
#' @param df  a (trajectory) data frame
#' @param geo a geographical location in lon/lat (WGS84)
#' @param dm  a distance in Nautical Miles
#' @param dM  a distance in Nautical Miles
#' @param lon the column for longitude in \code{df}
#' @param lat the column for latitude in \code{df}
#' @param .keep keep the calculated distance (in Nautical Miles)
#'              in the \code{.distance} column [default is FALSE]
#' @param .exclude exclude the point in the [\code{dm}, \code{dM}) [default is FALSE]
#'
#' @return a subset of \code{df}
#' @export
#' @family spatial
#'
#' @examples
#' \dontrun{
#' fra <- c(8.570556, 50.03333) # Frankfurt Airport (longitude, latitude)
#'
#' # keep the points 40 NM from FRA
#' poss %>% filter_positions_at_range(fra, 0, 40, longitude, latitude)
#' # keep the points from 10 to 40 NM from FRA
#' poss %>% filter_positions_at_range(fra, 10, 40, longitude, latitude)
#' # exclude the points from 10 to 40 NM from FRA
#' poss %>% filter_positions_at_range(fra, 10, 40, longitude, latitude, .exclude = TRUE)
#' # keep the points further away of 40 NM from FRA
#' poss %>% filter_positions_at_range(fra, 0, 40, longitude, latitude, .exclude = TRUE)
#' }
filter_positions_at_range <- function(df, geo, dm, dM, lon, lat, .exclude = FALSE, .keep = FALSE) {
  if (.exclude == TRUE) {
    predicate <- magrittr::or
    # swap the values of the minimum and maximum distances
    temp <- dm
    dm <- dM
    dM <- temp
  } else {
    predicate <- magrittr::and
  }
  ddff <- df %>%
    dplyr::mutate(.distance = geosphere::distGeo(geo, cbind({{ lon }}, {{ lat }})) / 1852.0) %>%
    dplyr::filter(predicate((dm <= .data$.distance), (.data$.distance < dM)))
  if (.keep != TRUE) {
    ddff <- ddff %>% dplyr::select(-.data$.distance)
  }
  ddff
}

#' PROJ4 CRS string used in Traffic Complexity
#'
#' Traffic Complexity score computation uses a custom Albers Equal Area projection.
#'
#' @return the PROJ4 string for the map projection
#' @export
#' @family spatial
#'
#' @seealso \code{\link{parse_airspace_prisme}} for an example.
#'
crs_tc <- function() {
  # From TatukCppWrapper.cpp in PRU Complexity code base
  # define albersProjectionStandardWKT
  # "PROJCS[
  #   "Custom_Abers_to_meters",
  #   GEOGCS["Unknown_datum_based_upon_the_WGS_84_ellipsoid",
  #     DATUM["Not_specified_based_on_WGS_84_ellipsoid",
  #           SPHEROID["WGS_1984",6378137,298.257223563],
  #           TOWGS84[0,0,0,0,0,0,0]],
  #     PRIMEM["Greenwich",0],
  #     UNIT["Degree",0.0174532925199433]],
  #   PROJECTION["Albers",
  #             AUTHORITY["EPSG","9822"]],
  #   PARAMETER["Central_Meridian",0],
  #   PARAMETER["Latitude_Of_Origin",45],
  #   PARAMETER["False_Easting",0],
  #   PARAMETER["False_Northing",0],
  #   PARAMETER["Standard_Parallel_1",40],
  #   PARAMETER["Standard_Parallel_2",50],
  #   UNIT["Meter",1,AUTHORITY["EPSG","9001"]]
  # ]"
  "+proj=aea +lat_1=40.0 +lat_2=50.0 +lat_0=45.0 +lon_0=0.0 +datum=WGS84 +ellps=WGS84 +units=kmi +x_0=0.0 +y_0=0.0 +no_defs"
}


#' Return a polygon from (WGS84) coordinates
#'
#' @param coords coordinates defining a polygon
#' @inheritParams sf::st_segmentize
#'
#' @return an sf polygon
#' @export
#' @family spatial
#'
#' @examples
#' \dontrun{
#' coords <- list(rbind(c(0, 0), c(1, 0), c(1, 1), c(0.5, 1.5), c(0, 1), c(0, 0)))
#' polygon_from_coords(coords)
#' }
polygon_from_coords <- function(coords, dfMaxLength = units::set_units(1, "km")) {
  coords %>%
    sf::st_polygon() %>%
    sf::st_sfc() %>%
    sf::st_sf(a=1, geom = ., crs = 4326) %>%
    sf::st_segmentize(dfMaxLength) %>%
    sf::st_geometry()
}
