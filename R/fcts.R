#' Import data from Quandl API
#'
#' Uses the json api from Quandl (<https://www.quandl.com/tools/api>) to import data into an R session.
#' The great benefit from the original Quandl::Quandl is the use of package memoise to cache
#' results, organization of the output dataframe in the tidy/long format and passing different multiple parameters to manipulate series.
#'
#' ATTENTION: You'll need a api key in order to use this function. Get one at <https://www.quandl.com/sign-up-modal?defaultModal=showSignUp>.
#'
#' @param id_in Character vector of ids to grab data. When using a named vector, the name is used to
#' register the time series. Example: id_in <- c('US GDP' = 'FRED/GDP')
#' @param api_key YOUR api key (get your own at <https://www.quandl.com/sign-up-modal?defaultModal=showSignUp>)
#' @param first_date First date of all requested series as YYYY-MM-DD (default = Sys.date() - 365)
#' @param last_date Last date of all requested series as YYYY-MM-DD (default = Sys.date() - 365)
#' @param do_cache Do cache? TRUE (default) or FALSE. Sets the use of package memoise to cache results from the api
#' @param order How to order the time series data: 'desc' (descending dates, default) or 'asc' (ascending)
#' @param collapse Frequency of time series: 'none' (default), 'daily', 'weekly', 'monthly', 'quarterly', 'annual'
#' @param transform Quandl transformation: 'none', 'diff', 'rdiff', 'rdiff_from', 'cumul', 'normalize'.
#' Details at <https://docs.quandl.com/docs/parameters-2>
#' @param cache_folder Folder where to save memoise cache files
#'
#' @return A dataframe in the long format
#' @export
#'
#' @examples
#'
#' api_key <- 'YOUR_API_KEY_HERE'
#' id_in <- c('Inflation argentina' = 'RATEINF/INFLATION_ARG')
#' \dontrun{
#'  df <- get_Quandl_series(id_in = id_in, api_key = api_key)
#'  }
get_Quandl_series <- function(id_in,
                              api_key = NULL,
                              first_date = Sys.Date() - 365,
                              last_date = Sys.Date(),
                              do_cache = TRUE,
                              order = 'asc',
                              collapse = 'none',
                              transform = 'none',
                              cache_folder = 'quandl_cache') {

  # check inputs
  if (is.null(api_key)) {
    stop(paste0('You need an api key for using get_Quandl_series.\n',
                'Get yours at <https://www.quandl.com/sign-up-modal?defaultModal=showSignUp>.'))
  }

  len_id <- length(id_in)

  if ( (!(length(order) %in% c(1, len_id)))|
       (!length(collapse) %in% c(1, len_id))|
       (!length(transform) %in% c(1, len_id)) ) {
    stop(paste0('Lenghts of inputs order, collapse and transform should be either ',
                '1 or ', length(id_in), ' (length of id_in).\n',
                'Got lengths:\n',
                'length(order) = ' , length(order), '\n',
                'length(collapse) = ', length(collapse), '\n',
                'length(transform) = ', length(transform)))
  }

  if (first_date > last_date) {
    stop(paste0('Input first_date is higher than last_date. Did you mix them up?'))
  }

  if (!(do_cache %in% c(TRUE, FALSE))) {
    stop('Input do_cache must be either TRUE or FALSE')
  }

  possible_cases <- c('desc', 'asc')
  if (any(!(order %in% possible_cases))) {
    stop(paste0('Input order must be one of: ',
                paste0(possible_cases, collapse = ', '), '.\n\n',
                'You set order = c(', paste0(order, collapse = ', '), ')'))
  }

  possible_cases <- c('none', 'daily', 'weekly', 'monthly',
                      'quarterly', 'annual')
  if (any(!(collapse %in% possible_cases))) {
    stop(paste0('Input collapse must be one of: ',
                paste0(possible_cases, collapse = ', '), '.\n\n',
                'You set collapse = c(', paste0(collapse, collapse = ', '), ')'))
  }

  possible_cases <- c('none', 'diff', 'rdiff', 'rdiff_from',
                      'cumul', 'normalize')
  if (any(!(transform %in% possible_cases))) {
    stop(paste0('Input transform must be one of: ',
                paste0(possible_cases, collapse = ', '), '.\n\n',
                'You set transform = c(', paste0(transform, collapse = ', '), ')\n',
                'More details at <https://docs.quandl.com/docs/parameters-2>'))
  }

  # fix names, if not informed
  if (is.null(names(id_in))) names(id_in) = id_in

  # set cache
  if (do_cache) {
    my_cachesystem <- memoise::cache_filesystem(path = cache_folder)
    fct_get_single_Quandl <- memoise::memoise(get_single_Quandl,
                                              cache = my_cachesystem)
  } else {
    fct_get_single_Quandl <- get_single_Quandl
  }

  l_purrr <- purrr::pmap(.l = list(id_in = id_in,
                                   name_in = names(id_in),
                                   api_key = api_key,
                                   first_date = first_date,
                                   last_date = last_date,
                                   do_cache = do_cache,
                                   order = order,
                                   collapse = collapse,
                                   transform = transform),
                         fct_get_single_Quandl)

  df_out <- dplyr::bind_rows(l_purrr)
  return(df_out)

}

#' Fetches a single time series from Quandl
#'
#' @inheritParams get_Quandl_series
#' @param name_in Name of series to fetch
#'
#' @return A single dataframe
#' @export
#'
#' @examples
#'
#' api_key <- 'YOUR_API_KEY_HERE'
#' id_in <- c('Inflation argentina' = 'RATEINF/INFLATION_ARG')
#' \dontrun{
#'  df <- get_single_Quandl(id_in = id_in, name_in = '',
#'                          api_key = api_key,
#'                          first_date = '2010-01-01',
#'                          last_date = Sys.Date())
#'  }
#'
get_single_Quandl <- function(id_in,
                              name_in,
                              api_key,
                              first_date, last_date,
                              do_cache = TRUE,
                              order = 'asc',
                              collapse = 'none',
                              transform = 'none') {

  # waits 0.25*1 sec before making a call
  # see limits at: https://docs.quandl.com/docs/getting-started#section-free-and-premium-data
  Sys.sleep(0.25)

  if (name_in == id_in) {
    message('Fetching data for ', id_in)
  } else {
    message('Fetching data for ', id_in, ' (', name_in, ')')
  }

  # build json url
  json_link <- sprintf(paste0('https://www.quandl.com/api/v3/datasets/%s.json?',
                              'start_date=%s?end_date=%s?', # dates
                              'order=%s?', # order of data (from time)
                              'collapse=%s?', # collapse frequency
                              'transform=%s?',
                              'api_key=%s'),
                       id_in,
                       first_date,
                       last_date,
                       order,
                       collapse,
                       transform,
                       api_key)

  # try fetching the data (if not, return tibble())
  l_out <- list()
  try(expr = {
    l_out <- jsonlite::fromJSON(json_link)
    }, silent = TRUE)

  if (length(l_out) == 0) {
    message('\tPROBLEM: no table found for ', id_in,
            '. Check your Quandl code at <https://www.quandl.com/search>')
    message('\tReturning 0 rows')
    return(dplyr::tibble())

  }

  # organize the data
  df_out <- json_to_tibble(l_out, id_in, name_in)

  # sort by order (api doesnt work for this parameter)
  if ( ('Date' %in% names(df_out))&(order == 'asc') ) {

    idx <- order(df_out$Date)
    df_out <- df_out[idx, ]

  }

  # check if dates match with args
  first_available_date <- l_out$dataset$oldest_available_date
  last_available_date <- l_out$dataset$newest_available_date

  message('\tSeries available from ', first_available_date, ' to ', last_available_date)

  if (first_date < first_available_date) {
    message('\tWarning: first_date (', first_date, ')',
            'is lower than first_available_date (', first_available_date, ')')
  }

  if (first_date > last_available_date) {
    message('\tWarning: first_date (', first_date, ') ',
            'is greater than last_available_date (', last_available_date, ')')
  }

  if (last_date > last_available_date) {
    message('\tWarning: last_date (', last_date, ') ',
            'is greater than last_available_date (', last_available_date, ')')
  }

  if (last_date < first_available_date) {
    message('\tWarning: last_date (', last_date, ') ',
            'is lower than first_available_date (', last_available_date, ')')
  }

  if (order != 'asc' ) {
    message('\tUsing order = "', order, '" for this series')
  }

  if (collapse != 'none' ) {
    message('\tUsing collapse = "', collapse, '" for this series')
  }

  if (transform != 'none' ) {
    message('\tUsing transform = "', transform, '" for this series')
  }

  message('\tReturning ', nrow(df_out), ' rows')

  return(df_out)

}
