# Libraries
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(plotly)

# Chargement des données 
data_trains <- read_csv("data/Train_dataset.csv") %>% 
  select(-`Comment (optional) delays at departure`, -`Comment (optional) delays on arrival`)
names(data_trains) <- gsub("\\s*\\([^)]*\\)", "", names(data_trains))
names(data_trains) <- gsub(" ", "_", names(data_trains))
names(data_trains) <- gsub("_$", "", names(data_trains))

# Exclure les gares étrangères
gares_etranger <- c("LAUSANNE", "ZURICH", "STUTTGART", "ITALIE", "GENEVE", "MADRID", "FRANCFORT")
data_trains <- data_trains %>%
  filter(!(Departure_station %in% gares_etranger | Arrival_station %in% gares_etranger))

# Préparation
data_trains <- data_trains %>%
  mutate(date = as.Date(sprintf("%d-%02d-01", Year, Month)))

# Aggréger les retards par gare
retards_gares <- data_trains %>%
  group_by(Departure_station) %>%
  summarise(
    retard_15min = sum(`Number_of_late_trains_>_15min`, na.rm = TRUE),
    retard_30min = sum(`Number_of_late_trains_>_30min`, na.rm = TRUE),
    retard_60min = sum(`Number_of_late_trains_>_60min`, na.rm = TRUE),
    total_retards = sum(Number_of_trains_late_on_arrival, na.rm = TRUE),
    .groups = "drop"
  )

# --- Top 20 ---
top_gares <- retards_gares %>%
  arrange(desc(total_retards)) %>%
  slice(1:20)

# Format long
top_gares_long <- top_gares %>%
  pivot_longer(cols = c(retard_15min, retard_30min, retard_60min),
               names_to = "Type_retard", values_to = "Nombre") %>%
  mutate(
    Pourcentage_local = round((Nombre / total_retards) * 100, 1),
    Type_retard = factor(Type_retard, levels = c("retard_15min", "retard_30min", "retard_60min"))
  )

# Part des retards totaux
retard_total_france <- sum(retards_gares$total_retards, na.rm = TRUE)
top_gares_long <- top_gares_long %>%
  mutate(
    Pourcentage_global = round((total_retards / retard_total_france) * 100, 1)
  )

# Couleurs 
couleurs_retard <- c(
  "retard_15min" = "#FFEE58",
  "retard_30min" = "#FFA726",
  "retard_60min" = "#EF5350"
)

# Graphique
p <- ggplot(top_gares_long, aes(x = reorder(Departure_station, total_retards), y = Nombre, fill = Type_retard,
                                text = paste0(
                                  "<b>Gare :</b> ", Departure_station, "<br>",
                                  "Trains en retards : ", Nombre, " trains<br>",
                                  "Proportion locale : ", Pourcentage_local, "%<br>",
                                  "Part nationale : <b>", Pourcentage_global, "</b>%"
                                ))) +
  geom_col(position = "stack") +
  coord_flip() +
  scale_fill_manual(values = couleurs_retard,
                    labels = c("> 15 min", "> 30 min", "> 60 min")) +
  labs(
    title = "Top 20 gares par retards cumulés",
    x = "Gare de départ",
    y = "Nombre de trains en retard",
    fill = "Type de retard"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.text.y = element_text(size = 10)
  )

# Interaction
p <- ggplotly(p, tooltip = "text")

# Affichage
p

