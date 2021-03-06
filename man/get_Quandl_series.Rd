% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fcts.R
\name{get_Quandl_series}
\alias{get_Quandl_series}
\title{Import data from Quandl API}
\usage{
get_Quandl_series(id_in, api_key = NULL, first_date = Sys.Date() - 365,
  last_date = Sys.Date(), do_cache = TRUE, order = "asc",
  collapse = "none", transform = "none",
  cache_folder = "quandl_cache")
}
\arguments{
\item{id_in}{Character vector of ids to grab data. When using a named vector, the name is used to
register the time series. Example: id_in <- c('US GDP' = 'FRED/GDP')}

\item{api_key}{YOUR api key (get your own at <https://www.quandl.com/sign-up-modal?defaultModal=showSignUp>)}

\item{first_date}{First date of all requested series as YYYY-MM-DD (default = Sys.date() - 365)}

\item{last_date}{Last date of all requested series as YYYY-MM-DD (default = Sys.date() - 365)}

\item{do_cache}{Do cache? TRUE (default) or FALSE. Sets the use of package memoise to cache results from the api}

\item{order}{How to order the time series data: 'desc' (descending dates, default) or 'asc' (ascending)}

\item{collapse}{Frequency of time series: 'none' (default), 'daily', 'weekly', 'monthly', 'quarterly', 'annual'}

\item{transform}{Quandl transformation: 'none', 'diff', 'rdiff', 'rdiff_from', 'cumul', 'normalize'.
Details at <https://docs.quandl.com/docs/parameters-2>}

\item{cache_folder}{Folder where to save memoise cache files}
}
\value{
A dataframe in the long format
}
\description{
Uses the json api from Quandl (<https://www.quandl.com/tools/api>) to import data into an R session.
The great benefit from the original Quandl::Quandl is the use of package memoise to cache
results, organization of the output dataframe in the tidy/long format and passing different multiple parameters to manipulate series.
}
\details{
ATTENTION: You'll need a api key in order to use this function. Get one at <https://www.quandl.com/sign-up-modal?defaultModal=showSignUp>.
}
\examples{

api_key <- 'YOUR_API_KEY_HERE'
id_in <- c('Inflation argentina' = 'RATEINF/INFLATION_ARG')
\dontrun{
 df <- get_Quandl_series(id_in = id_in, api_key = api_key)
 }
}
