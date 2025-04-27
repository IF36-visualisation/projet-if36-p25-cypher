library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(plotly)

# Chargement des données
data_trains <- read_csv("data/Train_dataset.csv")

data_trains <- data_trains %>% 
  select(-`Comment (optional) delays at departure`, -`Comment (optional) delays on arrival`)

names(data_trains) <- gsub("\\s*\\([^)]*\\)", "", names(data_trains))
names(data_trains) <- gsub(" ", "_", names(data_trains))
names(data_trains) <- gsub("_$", "", names(data_trains))

# Exclure les gares étrangères
gares_etranger <- c("LAUSANNE", "ZURICH", "STUTTGART", "ITALIE", "GENEVE", "MADRID", "FRANCFORT")
data_trains <- data_trains %>%
  filter(!(Departure_station %in% gares_etranger | Arrival_station %in% gares_etranger))

# Agrégation mensuelle
retards_mensuels <- data_trains %>%
  group_by(Year, Month) %>%
  summarise(
    retard_15min = sum(`Number_of_late_trains_>_15min`, na.rm = TRUE),
    retard_30min = sum(`Number_of_late_trains_>_30min`, na.rm = TRUE),
    retard_60min = sum(`Number_of_late_trains_>_60min`, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    saison = case_when(
      Month %in% c(12, 1, 2) ~ "Hiver",
      Month %in% c(3, 4, 5) ~ "Printemps",
      Month %in% c(6, 7, 8) ~ "Été",
      Month %in% c(9, 10, 11) ~ "Automne"
    )
  )

# Sélection d'une année
annee_selectionnee <- 2015
retards_annee <- retards_mensuels %>% filter(Year == annee_selectionnee)

# Agrégation par saison
retards_saisons <- retards_annee %>%
  group_by(saison) %>%
  summarise(
    retard_15min = sum(retard_15min),
    retard_30min = sum(retard_30min),
    retard_60min = sum(retard_60min),
    .groups = "drop"
  )

# Passage au format long pour ggplot
retards_long <- retards_saisons %>%
  pivot_longer(cols = starts_with("retard_"),
               names_to = "Type_retard", values_to = "Nombre")

retards_long$saison <- factor(retards_long$saison, levels = c("Hiver", "Printemps", "Été", "Automne"))
retards_long$Type_retard <- factor(retards_long$Type_retard, levels = c("retard_15min", "retard_30min", "retard_60min"))

# Couleurs
couleurs_retard <- c(
  "retard_15min" = "#FFEE58",
  "retard_30min" = "#FFA726",
  "retard_60min" = "#EF5350"
)

# Barplot groupé
p <- ggplot(retards_long, aes(x = saison, y = Nombre, fill = Type_retard)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  scale_fill_manual(values = couleurs_retard) +
  theme_minimal(base_size = 15) +
  labs(
    title = paste("Retards de trains par saison en", annee_selectionnee),
    x = "Saison",
    y = "Nombre de trains en retard"
  ) +
  theme(
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold", hjust = 0.5)
  )

# Affichage interactif
ggplotly(p)

