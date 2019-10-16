## Introduction

[Quandl](https://www.quandl.com/search) is one of the best platforms for finding and downloading financial and economic time series. The collection of free databases is comprehensive and I've used it intensively in my research and class material.

But, a couple of things from the native package `Quandl` always bothered me:

- Multiple data is always returned in the wide (column oriented) format (why??);
- No local caching of data;
- No control for importing error and status.

As you suspect, I decided to tackle the problem over the weekend. The result is package `GetQuandlData`. This is what it does differently:

- It uses the json api (and not the Quandl native function);
- The data always returns in the long format, even for multiple series;
- Users can set custom names for series. This is very useful when using along `ggplot` or making tables;
- Uses package `memoise` to set a local caching system. This means that the second time you ask for a particular time series, it will grab it from your hard drive (and not the internet);
- Always compares the requested dates against dates available in the platform.


## Installation

```
# not in CRAN yet (need to test it further)
#install.packages('GetQuandlData')

# from github
devtools::install_github('msperlin/GetQuandlData')
```


### Example 01 - Inflation in the US

Let's download information about inflation in the US:

```
library(GetQuandlData)
library(tidyverse)

my_id <- c('Inflation USA' = 'RATEINF/INFLATION_USA')
my_api <- readLines('~/Dropbox/.quandl_api.txt') # you need your own API (get it at https://www.quandl.com/sign-up-modal?defaultModal=showSignUp>)
first_date <- '2000-01-01'
last_date <- Sys.Date()

df <- get_Quandl_series(id_in = my_id, 
                        api_key = my_api, 
                        first_date = first_date,
                        last_date = last_date, 
                        cache_folder = tempdir())

glimpse(df)
```

### Example 02 - Inflation for many countries

Next, lets have a look into a more realistic case, where we need inflation data for several countries:

First, we need to see what are the available datasets from database `RATEINF`:

```
library(GetQuandlData)
library(tidyverse)

db_id <- 'RATEINF'
my_api <- readLines('~/Dropbox/.quandl_api.txt') # you need your own API

df <- get_database_info(db_id, my_api)

knitr::kable(df)
```

Nice. Now we only need to filter the series with YOY inflation:

```
idx <- stringr::str_detect(df$name, 'Inflation YOY')

df_series <- df[idx, ]
```

and grab the data:

```
my_id <- df_series$quandl_code
names(my_id) <- df_series$name
first_date <- '2010-01-01'
last_date <- Sys.Date()

df_inflation <- get_Quandl_series(id_in = my_id, 
                                  api_key = my_api,
                                  first_date = first_date,
                                  last_date = last_date)

glimpse(df_inflation)
```

And, an elegant plot:

```
p <- ggplot(df_inflation, aes(x = ref_date, y = value/100)) + 
  geom_col() + 
  labs(y = 'Inflation (%)', 
       x = '',
       title = 'Inflation in the World',
       subtitle = paste0(first_date, ' to ', last_date)) + 
  scale_y_continuous(labels = scales::percent) + 
  facet_wrap(~series_name)

p
```



