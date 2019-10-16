#' Transforms and organize json output to a tibble
#'
#' @param l_in Output of get_single_Quandl
#' @param id_in Value of id
#' @param name_in Name of id
#'
#' @return A beautiful dataframe
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' my_id <- 'BCB/7832'
#' my_api <- 'YOURAPIHERE'
#' json_link <- sprintf(
#'                 paste0('https://www.quandl.com/api/v3/datasets/%s',
#'                        '.json?start_date=2010-01-01?end_date=2019-09-30?',
#'                        'order=asc?collapse=none?transform=none?api_key=%s'),
#'                      my_id, my_api)
#' l_out <- jsonlite::fromJSON(json_link)
#' df <- json_to_tibble(l_out, id_in = my_id, name_in = 'Ibov change')
#' }
json_to_tibble <- function(l_in, id_in, name_in) {

  if (length(l_in$dataset$data) == 0) {
    message('\tWarning: found no table for ', id_in)
    return(dplyr::tibble())
  }

  colnames(l_in$dataset$data) <- l_in$dataset$column_names
  df_out <- dplyr::as_tibble(l_in$dataset$data)

  if (is.null(name_in)) {
    df_out$series_name <- l_in$dataset$name
  } else {
    df_out$series_name <- name_in
  }

  # change columns names and classes
  if ('Date' %in% names(df_out)) {
    df_out$ref_date <- as.Date(df_out$Date)
    df_out$Date <- NULL
  }

  if ('Value' %in% names(df_out)) {
    df_out$value <- as.numeric(df_out$Value)
    df_out$Value <- NULL
  }

  df_out$id_quandl <- id_in

  return(df_out)

}

