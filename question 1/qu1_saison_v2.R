# Libraries
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)

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

# Choix de l'année
annee_selectionnee <- 2019

# Filtrer l'année
data_annee <- data_trains %>%
  filter(Year == annee_selectionnee) %>%
  mutate(date = as.Date(sprintf("%d-%02d-01", Year, Month)))

# Agréger
retards_mensuels <- data_annee %>%
  group_by(date) %>%
  summarise(
    nb_total = sum(Number_of_expected_circulations, na.rm = TRUE),
    nb_annules = sum(Number_of_cancelled_trains, na.rm = TRUE),
    retard_15min = sum(`Number_of_late_trains_>_15min`, na.rm = TRUE),
    retard_30min = sum(`Number_of_late_trains_>_30min`, na.rm = TRUE),
    retard_60min = sum(`Number_of_late_trains_>_60min`, na.rm = TRUE),
    retard_depart = sum(Number_of_late_trains_at_departure, na.rm = TRUE),
    retard_arrivee = sum(Number_of_trains_late_on_arrival, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    nb_circules = nb_total - nb_annules,
    total_retards = retard_arrivee,
    trains_a_lheure = nb_circules - total_retards,
    pourcentage_a_lheure = round((trains_a_lheure / nb_circules) * 100, 1),
    Mois_annee = format(date, "%m/%Y"),
    tooltip_text = paste0(
      "<b>", Mois_annee, "</b><br>",
      "Trains à l'heure : ", trains_a_lheure, " trains<br>",
      "Soit ", "<b>",pourcentage_a_lheure, "</b>% des trains"
    )
  )

# Préparer les retards en long
# Préparer les retards en long
retards_long <- retards_mensuels %>%
  pivot_longer(cols = c(`retard_15min`, `retard_30min`, `retard_60min`),
               names_to = "Type_retard",
               values_to = "Nombre") %>%
  mutate(
    Saison = case_when(
      month(date) %in% c(12, 1, 2) ~ "Hiver",
      month(date) %in% c(3, 4, 5) ~ "Printemps",
      month(date) %in% c(6, 7, 8) ~ "Été",
      month(date) %in% c(9, 10, 11) ~ "Automne"
    ),
    Mois_annee = format(date, "%m/%Y"),
    pourcentage = round((Nombre / (Nombre + trains_a_lheure)) * 100, 1),
    tooltip_text = paste0(
      "<b>", Mois_annee, "</b><br>",
      case_when(
        Type_retard == "retard_15min" ~ "> 15 min : ",
        Type_retard == "retard_30min" ~ "> 30 min : ",
        Type_retard == "retard_60min" ~ "> 60 min : ",
        TRUE ~ ""
      ),
      Nombre, " trains<br>",
      "Soit <b>", pourcentage, "</b>% des trains"
    )
  )


# Saison pour les lignes et texte
saisons <- data.frame(
  Saison = c("Hiver", "Printemps", "Été", "Automne"),
  
  # Début de chaque saison
  xmin = as.Date(c(
    paste0(annee_selectionnee, "-12-12"),   # Hiver débute le 21 décembre (de l'année précédente mais pour simplifier on le met là)
    paste0(annee_selectionnee, "-03-21"),   # Printemps 21 mars
    paste0(annee_selectionnee, "-06-21"),   # Été 21 juin
    paste0(annee_selectionnee, "-09-21")    # Automne 21 septembre
  )),
  
  # Fin de chaque saison
  xmax = as.Date(c(
    paste0(annee_selectionnee, "-03-20"),   # Fin hiver (20 mars)
    paste0(annee_selectionnee, "-06-20"),   # Fin printemps (20 juin)
    paste0(annee_selectionnee, "-09-20"),   # Fin été (20 septembre)
    paste0(annee_selectionnee, "-12-20")    # Fin automne (20 décembre)
  )),
  
  # Position des labels (au centre de chaque saison)
  label_pos = as.Date(c(
    paste0(annee_selectionnee, "-02-05"),  
    paste0(annee_selectionnee, "-05-05"),   
    paste0(annee_selectionnee, "-08-05"),  
    paste0(annee_selectionnee, "-11-05")    
  ))
)




# Hauteur maximum
hauteur_max <- max(retards_mensuels$nb_circules, na.rm = TRUE)

# Couleurs
couleurs_retard <- c(
  "retard_15min" = "#FFEE58",
  "retard_30min" = "#FFA726",
  "retard_60min" = "#EF5350"
)

# --- Graphique ---
p <- ggplot() +
  
  # 1. Trains à l'heure en fond
  geom_col(
    data = retards_mensuels,
    aes(x = date, y = trains_a_lheure, fill = "trains_a_lheure", text = tooltip_text),
    width = 25,
    alpha = 0.5
  ) +
  
  # 2. Retards en empilé
  geom_col(
    data = retards_long,
    aes(x = date, y = Nombre, fill = Type_retard, text = tooltip_text),
    position = "stack",
    width = 25
  ) +
  
  # 3. Traits saisons
  geom_vline(
    data = saisons,
    aes(xintercept = as.numeric(xmin)),
    linetype = "dashed",
    color = "grey50",
    size = 0.5
  ) +
  
  # 4. Labels saisons
  geom_text(
    data = saisons,
    aes(x = label_pos, y = hauteur_max * 1.02, label = Saison),
    inherit.aes = FALSE,
    color = "grey40",
    size = 4,
    fontface = "bold"
  ) +
  
  scale_fill_manual(
    values = c(couleurs_retard, "trains_a_lheure" = "grey80"),
    breaks = c("retard_>_15min", "retard_30min", "retard_60min", "trains_a_lheure"),
    labels = c("> 15 min", "> 30 min", "> 60 min", "Trains à l'heure")
  ) +
  
  labs(
    title = paste0("Répartition mensuelle des retards ferroviaires (", annee_selectionnee,")"),
    x = "Mois",
    y = "Nombre de trains",
    fill = "Type"
  ) +
  theme_minimal(base_size = 15) +
  theme(
    plot.title = element_text(size = 12, face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank(),
    plot.margin = margin(t = 30, r = 10, b = 10, l = 10) 
    
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "2 months")

# --- Rendu interactif ---
p_interactif <- ggplotly(p, tooltip = "text")

# --- Affichage ---
p_interactif

