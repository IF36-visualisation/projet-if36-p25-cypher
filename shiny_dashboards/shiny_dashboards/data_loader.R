# data_loader.R

library(dplyr)
library(readr)

data_trains <- read_csv("../../data/Train_dataset.csv") %>%
  select(
    -`Comment (optional) delays at departure`,
    -`Comment (optional) delays on arrival`
  ) %>%
  {
    # Renommage automatique des colonnes :
    names(.) <- gsub("\\s*\\([^)]*\\)", "", names(.))
    names(.) <- gsub(" ", "_", names(.))
    names(.) <- gsub("_$", "", names(.))
    .
  } %>%
  filter(
    !(Departure_station %in% c("LAUSANNE","ZURICH","STUTTGART","ITALIE",
                               "GENEVE","MADRID","FRANCFORT") |
        Arrival_station   %in% c("LAUSANNE","ZURICH","STUTTGART","ITALIE",
                                 "GENEVE","MADRID","FRANCFORT"))
  ) %>%
  mutate(
    date = as.Date(sprintf("%d-%02d-01", Year, Month))
  )

# Extraire la liste d’années disponibles (unique + triée)
annees_disponibles <- sort(unique(data_trains$Year))

write_csv(data_trains, "data_trains_tableau.csv")
