% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/correct.R
\name{correct}
\alias{correct}
\title{Correct strata by group}
\usage{
correct(strata = NULL, n_strata = NULL, assoc = NULL, group = FALSE,
  group_name = NULL, mode = "default")
}
\arguments{
\item{strata}{Strata}

\item{n_strata}{Number of strata}

\item{assoc}{Assoc file path}
}
\value{
A data frame of FDR and sFDR by grouping level.
}
\description{
Note that group name must be a factor
}

