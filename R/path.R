#' Set the ghrsst data path
#'
#' @export
#' @param path the path that defines the location of copernicus data
#' @param filename the name the file to store the path as a single line of text
#' @return NULL invisibly
set_root_path <- function(path, filename = "~/.ghrsstdata"){
  cat(path, sep = "\n", file = filename)
  invisible(NULL)
}

#' Get the ghrsst data path from a user specified file
#'
#' @export
#' @param filename the name the file to store the path as a single line of text
#' @return character data path
root_path <- function(filename = "~/.ghrsstdata"){
  readLines(filename)
}



#' Retrieve the ghrsst path
#'
#' @export
#' @param ... further arguments for \code{file.path()}
#' @param root the root path
#' @return character path description
ghrsst_path <- function(..., root = root_path()) {
  file.path(root, ...)
}

#' Given a path - make it if it doesn't exist
#'
#' @export
#' @param path character, the path to check and/or create
#' @param recursive logical, create paths recursively?
#' @param ... other arguments for \code{dir.create}
#' @return logical, TRUE if the path exists or is created
make_path <- function(path, recursive = TRUE, ...){
  ok <- dir.exists(path[1])
  if (!ok){
    ok <- dir.create(path, recursive = recursive, ...)
  }
  ok
}