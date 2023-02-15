test_df <- function(df) {

  expect_true(tibble::is_tibble(df))
  expect_true(nrow(df) > 1)
  expect_true(ncol(df) > 1)

  return(invisible(TRUE))

}

test_that("database functions", {

  skip_if_offline()
  skip_on_cran() # avoid api calls on CRAN

  db_in <- 'RATEINF'
  api_key <- ''

  df_db <- get_database_info(db_in, api_key)

  test_df(df_db)


})
