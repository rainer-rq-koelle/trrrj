% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nm.R
\name{export_model_trajectory}
\alias{export_model_trajectory}
\title{Export point profile from NM trajectories}
\usage{
export_model_trajectory(
  wef,
  til,
  model = "CTFM",
  bbox = NULL,
  lobt_buffer = c(before = 28, after = 24),
  timeover_buffer = NULL
)
}
\arguments{
\item{wef}{(UTC) timestamp of LOBT With Effect From (included).
Liberal format, i.e. "2019-07-14", "2019-07-14 10:21"
"2019-07-14T10:21:23Z"}

\item{til}{(UTC) timestamp of LOBT TILl instant (excluded)}

\item{model}{the model of the profile: one of "FTFM", "CTFM", "RTFM", "CPF".
[default: "CFTM"]}

\item{bbox}{(Optional) axis aligned bounding box
(xmin, ymin, xmax, ymax)}

\item{lobt_buffer}{(Optional) number of (portion of) hours buffer for LOBT before/after
`wef` and `til` (before, after). This is to cater for flights crossing `wef` and `til`.
For example `c(before = 24, after = 2.25)` allows to retrieve flights with LOBT
24H before `wef` and 1H15M after `til` and then potentially crossing the interval.}

\item{timeover_buffer}{(Optional) number of (portion of) hours buffer for `time_over`
before/after `wef` and `til` (before, after). This is to cater for flights crossing
`wef` and `til`. For example `c(before = 2, after = 0.25)` allows to retrieve
points 2H before `wef` and 15M after `til`.}
}
\value{
a dataframe with trajectory data
}
\description{
Extract NM point profile trajectories from PRISME database
}
\details{
You need to store your credentials to access the PRU tables in
the following environment variables:
\itemize{
  \item \code{PRU_DEV_USR} for the user id
  \item \code{PRU_DEV_PWD} for the password
  \item \code{PRU_DEV_DBNAME} for the database name
}
}
\examples{
\dontrun{
# export 1 day worth of NM (planned) trajectories
export_model_trajectory("2019-07-14", "2019-07-15", model = "FTFM")

# export 2 hours of NM (flown) trajectories
export_model_trajectory("2019-07-14 22:00", "2019-07-15")

# export 1 day of NM (flown) trajectories
export_model_trajectory("2019-07-14", "2019-07-15", lobt_buffer = c(before = 24, after = 1.25))

# export all CTFM trajectories within a bounding box 40 NM around EDDF
bb <- c(xmin = 7.536746, xmax = 9.604390, ymin = 49.36732, ymax = 50.69920)
export_model_trajectory("2019-01-01 00:00", "2019-01-02 00:00", bbox = bb)
}
}
\seealso{
Other read/export: 
\code{\link{export_allft_so6}()},
\code{\link{export_apds}()},
\code{\link{export_event_so6}()},
\code{\link{export_event_trajectory}()},
\code{\link{export_flight_info}()},
\code{\link{export_flights_at_airport_fr24}()},
\code{\link{export_flights_fr24}()},
\code{\link{export_hourly_adsb}()},
\code{\link{export_movements}()},
\code{\link{export_positions_at_airport_fr24}()},
\code{\link{export_positions_fr24}()},
\code{\link{fix_flights_csvs}()},
\code{\link{fix_nulls_in_callsign}()},
\code{\link{generate_so6}()},
\code{\link{import_flights_csvs}()},
\code{\link{parse_airspace_prisme}()},
\code{\link{read_cpr}()},
\code{\link{read_flights_fr24}()},
\code{\link{read_positions_fr24}()},
\code{\link{read_so6}()}
}
\concept{read/export}
