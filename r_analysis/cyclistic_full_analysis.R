# cyclistic_full_analysis.R
# Cyclistic Bike-Share Case Study – R Cleaning & Summary
# April–May 2025 • David Martinez

# ---------------------------------------------------------
# 0. Load Required Libraries
# ---------------------------------------------------------
# tidyverse: core functions like dplyr, ggplot2, readr
# lubridate: date/time parsing and manipulation
# readxl: import Excel files (.xlsx)
library(tidyverse)
library(lubridate)
library(readxl)

# ---------------------------------------------------------
# 1. Import the Raw Excel Files
# ---------------------------------------------------------
# These are the two quarters provided: Q1 2019 and Q1 2020
# Q1 2019 includes complete data; Q1 2020 has fewer fields

q1_2019 <- read_excel("Divvy_Trips_2019_Q1.xlsx")
q1_2020 <- read_excel("Divvy_Trips_2020_Q1.xlsx")

# ---------------------------------------------------------
# 2. Standardize Column Names for Schema Alignment
# ---------------------------------------------------------
# Q1 2020 is missing several columns, so we create them with NA
# and re-order to match Q1 2019's schema for merging

q1_2019_clean <- q1_2019 %>%
  rename(
    trip_id            = trip_id,
    start_time         = start_time,
    end_time           = end_time,
    bikeid             = bikeid,
    tripduration       = tripduration,
    from_station_id    = from_station_id,
    from_station_name  = from_station_name,
    to_station_id      = to_station_id,
    to_station_name    = to_station_name,
    usertype           = usertype,
    gender             = gender,
    birthyear          = birthyear
  )

q1_2020_clean <- q1_2020 %>%
  rename(
    trip_id            = trip_id,
    start_time         = start_time,
    end_time           = end_time,
    from_station_name  = from_station_name,
    to_station_name    = to_station_name,
    usertype           = usertype
  ) %>%
  mutate(
    bikeid            = NA_integer_,
    tripduration      = NA_integer_,
    from_station_id   = NA_integer_,
    to_station_id     = NA_integer_,
    gender            = NA_character_,
    birthyear         = NA_integer_
  ) %>%
  select(names(q1_2019_clean))  # ensure column order matches Q1 2019

# ---------------------------------------------------------
# 3. Merge Both Quarters into a Single DataFrame
# ---------------------------------------------------------
all_trips <- bind_rows(q1_2019_clean, q1_2020_clean)

# ---------------------------------------------------------
# 4. Clean & Enrich the Data
# ---------------------------------------------------------
# - Convert date columns to proper datetime
# - Create ride length in seconds
# - Add day of week as a numeric value (1 = Monday, 7 = Sunday)

all_trips <- all_trips %>%
  mutate(
    start_time     = ymd_hms(start_time),
    end_time       = ymd_hms(end_time),
    ride_length_s  = as.numeric(difftime(end_time, start_time, units = "secs")),
    day_of_week    = wday(start_time, week_start = 1)
  ) %>%
  filter(!is.na(ride_length_s))  # remove rows with invalid durations

# ---------------------------------------------------------
# 5. Descriptive Analysis & Summary Statistics
# ---------------------------------------------------------

# Overview of ride length distribution
summary(all_trips$ride_length_s)

# Core summary metrics
mean_len <- mean(all_trips$ride_length_s)
max_len  <- max(all_trips$ride_length_s)
min_len  <- min(all_trips$ride_length_s)

# Calculate mode of day_of_week (most frequent day)
mode_dow <- all_trips %>%
  count(day_of_week) %>%
  slice_max(n, n = 1) %>%
  pull(day_of_week)

# Trends by day of week: average ride length and volume
trends_by_weekday <- all_trips %>%
  group_by(day_of_week) %>%
  summarise(
    avg_length_s = mean(ride_length_s, na.rm = TRUE),
    ride_count   = n()
  ) %>%
  arrange(day_of_week)

# ---------------------------------------------------------
# 6. Export Results for Tableau or Reporting
# ---------------------------------------------------------
# Save summary metrics and trends as CSVs for visualization

write_csv(trends_by_weekday, "r_analysis/trends_by_weekday.csv")

write_csv(
  tibble(
    total_rides         = nrow(all_trips),
    distinct_rides      = n_distinct(all_trips$trip_id),
    mean_ride_length_s  = mean_len,
    max_ride_length_s   = max_len,
    min_ride_length_s   = min_len,
    mode_day_of_week    = mode_dow
  ),
  "r_analysis/trips_overall_summary.csv"
)
