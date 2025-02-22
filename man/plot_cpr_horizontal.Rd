% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.R
\name{plot_cpr_horizontal}
\alias{plot_cpr_horizontal}
\title{Plot CPR trajectories on a map}
\usage{
plot_cpr_horizontal(cprs, bb = NULL)
}
\arguments{
\item{cprs}{a dataframe of CPR position reports}

\item{bb}{an optional bounding box (a vector of left, bottom, right, top).
If NULL, the default, it will be calculated from the data.}
}
\value{
a ggplot2 plot
}
\description{
Plot CPR trajectories on a map
}
\examples{
\dontrun{
# plot CPR tryjectories
europe <- c(left = 5, bottom = 35, right = 30, top = 52)
plot_cpr_horizontal(cprs, europe)
}
}
\seealso{
Other plot: 
\code{\link{plot_flight_horizontal}()},
\code{\link{plot_flight_vertical_distance}()},
\code{\link{plot_flight_vertical_time}()}
}
\concept{plot}
