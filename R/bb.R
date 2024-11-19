#' Retrieve a coordinates to define offshore Namibia
#' 
#' @export
#' @param form chr, one of 'table', 'sf' or 'bbox' to define output form
#' @return tibble, sf or bbox class object
get_namibia = function(form = c("table", "sf", "bbox")[2]){
  x = dplyr::tribble(
    ~lat, ~lon, 
    -29,  17, 
    -16,  17, 
    -16,  0 , 
    -29,  0,  
    -29,  17)
 
  if (tolower(form[1]) %in% c('sf', "bbox")){
    x = sf::st_as_sf(x, coords = c("lon", "lat"), crs = 4326) |>
      sf::st_union() |> sf::st_cast("POLYGON")
    if (tolower(form[1]) == "bbox") x = sf::st_bbox(x)
  }
  x
}


#' Retrieve a coordinates to define offshore Gulf of Maine
#' 
#' @export
#' @param form chr, one of 'table', 'sf' or 'bbox' to define output form
#' @return tibble, sf or bbox class object
get_gom = function(form = c("table", "sf", "bbox")[2]){
  x = dplyr::tribble(
    ~lat, ~lon, 
    39,  -63, 
    46,  -63, 
    46,  -72 , 
    39,  -72,  
    39,  -63)
  
  if (tolower(form[1]) %in% c('sf', "bbox")){
    x = sf::st_as_sf(x, coords = c("lon", "lat"), crs = 4326) |>
      sf::st_union() |> sf::st_cast("POLYGON")
    if (tolower(form[1]) == "bbox") x = sf::st_bbox(x)
  }
  x
}