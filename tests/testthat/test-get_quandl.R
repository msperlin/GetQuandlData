test_df <- function(df) {

  expect_true(tibble::is_tibble(df))
  expect_true(nrow(df) > 1)
  expect_true(ncol(df) > 1)

  return(invisible(TRUE))

}

test_that("get_quandl", {

  api_key <- ''
  id_in <- c('Inflation Canada' = 'RATEINF/INFLATION_CAN')

  df <- get_Quandl_series(id_in = id_in, api_key = api_key)

  test_df(df)

})
