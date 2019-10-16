## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(message = FALSE, cache = FALSE,eval=FALSE)

## ---- eval=FALSE---------------------------------------------------------
#  # not in CRAN yet (need to test it further)
#  #install.packages('GetQuandlData')
#  
#  # from github
#  devtools::install_github('msperlin/GetQuandlData')

## ---- eval=FALSE---------------------------------------------------------
#  library(GetQuandlData)
#  library(tidyverse)
#  
#  my_id <- c('Inflation USA' = 'RATEINF/INFLATION_USA')
#  my_api <- readLines('YOURAPIHERE') # you need your own API (get it at https://www.quandl.com/sign-up-modal?defaultModal=showSignUp>)
#  first_date <- '2000-01-01'
#  last_date <- Sys.Date()
#  
#  df <- get_Quandl_series(id_in = my_id,
#                          api_key = my_api,
#                          first_date = first_date,
#                          last_date = last_date,
#                          cache_folder = tempdir())
#  
#  glimpse(df)

## ----eval=FALSE----------------------------------------------------------
#  p <- ggplot(df, aes(x = ref_date, y = value/100)) +
#    geom_col() +
#    labs(y = 'Inflation (%)',
#         x = '',
#         title = 'Inflation in the US') +
#    scale_y_continuous(labels = scales::percent)
#  
#  p

## ---- message=TRUE, eval=FALSE-------------------------------------------
#  library(GetQuandlData)
#  library(tidyverse)
#  
#  db_id <- 'RATEINF'
#  my_api <- readLines('YOURAPIHERE') # you need your own API
#  
#  df <- get_database_info(db_id, my_api)
#  
#  head(df)

## ------------------------------------------------------------------------
#  idx <- stringr::str_detect(df$name, 'Inflation YOY')
#  
#  df_series <- df[idx, ]

## ------------------------------------------------------------------------
#  my_id <- df_series$quandl_code
#  names(my_id) <- df_series$name
#  first_date <- '2010-01-01'
#  last_date <- Sys.Date()
#  
#  df_inflation <- get_Quandl_series(id_in = my_id,
#                                    api_key = my_api,
#                                    first_date = first_date,
#                                    last_date = last_date,
#                                    cache_folder = tempdir())
#  
#  glimpse(df_inflation)

## ------------------------------------------------------------------------
#  p <- ggplot(df_inflation, aes(x = ref_date, y = value/100)) +
#    geom_col() +
#    labs(y = 'Inflation (%)',
#         x = '',
#         title = 'Inflation in the World',
#         subtitle = paste0(first_date, ' to ', last_date)) +
#    scale_y_continuous(labels = scales::percent) +
#    facet_wrap(~series_name)
#  
#  p

