#  Libraries 
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)

#  Chargement des données 
data_trains <- read_csv("data/Train_dataset.csv") %>% 
  select(-`Comment (optional) delays at departure`, -`Comment (optional) delays on arrival`)

# Nettoyage des noms de colonnes
names(data_trains) <- gsub("\\s*\\([^)]*\\)", "", names(data_trains))
names(data_trains) <- gsub(" ", "_", names(data_trains))
names(data_trains) <- gsub("_$", "", names(data_trains))

#  Exclure les gares étrangères 
gares_etranger <- c("LAUSANNE", "ZURICH", "STUTTGART", "ITALIE", "GENEVE", "MADRID", "FRANCFORT")
data_trains <- data_trains %>%
  filter(!(Departure_station %in% gares_etranger | Arrival_station %in% gares_etranger))

#  Paramètre : année sélectionnée 
annee_selectionnee <- 2019

#  Préparer données 
data_filtered <- data_trains %>%
  filter(Year == annee_selectionnee) %>%
  mutate(
    date = as.Date(sprintf("%d-%02d-01", Year, Month)),
    Mois_annee = format(date, "%m/%Y")
  )

#  Regrouper retards d'arrivée par gare de départ et par mois 
retards_gares <- data_filtered %>%
  group_by(Departure_station, Mois_annee) %>%
  summarise(
    total_retards_arrivee = sum(Number_of_trains_late_on_arrival, na.rm = TRUE),
    .groups = "drop"
  )

#  Top 20 gares en retard à l'arrivée 
top_gares <- retards_gares %>%
  group_by(Departure_station) %>%
  summarise(total = sum(total_retards_arrivee, na.rm = TRUE)) %>%
  arrange(desc(total)) %>%
  slice(1:20) %>%
  pull(Departure_station)

#  Garder uniquement le Top 20 
retards_top20 <- retards_gares %>%
  filter(Departure_station %in% top_gares)

#  Reordonner les gares 
retards_top20 <- retards_top20 %>%
  mutate(Departure_station = factor(Departure_station, levels = rev(top_gares)))

#  Créer la heatmap 
p <- ggplot(retards_top20, aes(
  x = Mois_annee,
  y = Departure_station,
  fill = total_retards_arrivee,
  text = paste0(
    "<b>Gare :</b> ", Departure_station, "<br>",
    "<b>Mois :</b> ", Mois_annee, "<br>",
    "<b>Retards à l'arrivée :</b> ", total_retards_arrivee
  )
)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "white", high = "red") +
  labs(
    title = paste0("Heatmap des retards à l'arrivée par gare - ", annee_selectionnee),
    x = "Mois",
    y = "Gare",
    fill = "Trains en retard"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    axis.text.y = element_text(size = 10),
    plot.title = element_text(face = "bold", hjust = 0.5),
    panel.grid.major = element_blank()
  )

#  Passer en interactif 
p <- ggplotly(p, tooltip = "text")

#  Affichage 
p
