test_df <- function(df) {

  expect_true(tibble::is_tibble(df))
  expect_true(nrow(df) > 1)
  expect_true(ncol(df) > 1)

  return(invisible(TRUE))

}


test_that("cache works?", {

  this_cache <- get_cache_folder()
  expect_true(is.character(this_cache))

})


test_that("json_to_tibble()", {

  skip_if_offline()
  skip_on_cran() # avoid api calls on CRAN

  my_id <- 'BCB/7832'
  my_api <- ''
  json_link <- sprintf(
                 paste0('https://www.quandl.com/api/v3/datasets/%s',
                        '.json?start_date=2010-01-01?end_date=2019-09-30?',
                        'order=asc?collapse=none?transform=none?api_key=%s'),
                        my_id, my_api)
  l_out <- jsonlite::fromJSON(json_link)
  df <- json_to_tibble(l_out, id_in = my_id, name_in = 'Ibov change')

  test_df(df)


})
