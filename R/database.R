#' Get inform about quandl database
#'
#' Uses metadata link to download information about available series and dates for a given database id.
#'
#' @param db_in Database id (e.g. "RATEINF")
#' @param api_key YOUR api key
#'
#' @return A dataframe
#' @export
#'
#' @examples
#'
#' db_in <- 'RATEINF'
#' api_key <- 'YOUR_API_HERE'
#'
#' \dontrun{
#' df_db <- get_database_info(db_in, api_key)
#' }
#'
get_database_info <- function(db_in, api_key) {

  my_url <- sprintf('https://www.quandl.com/api/v3/databases/%s/metadata?api_key=%s',
                    db_in, api_key)

  local_file <- tempfile(fileext = '.zip')
  utils::download.file(my_url, destfile = local_file)

  df_db <- readr::read_csv(local_file, col_types = readr::cols())

  df_db$quandl_code <- paste0(db_in, '/', df_db$code)
  df_db$quandl_db <- db_in

  return(df_db)
}
