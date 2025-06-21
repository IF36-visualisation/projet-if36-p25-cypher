# === Librairies ===
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)

# === Données ===
data_trains <- read_csv("data/Train_dataset.csv") %>% 
  select(-`Comment (optional) delays at departure`, -`Comment (optional) delays on arrival`)
names(data_trains) <- gsub("\\s*\\([^)]*\\)", "", names(data_trains))
names(data_trains) <- gsub(" ", "_", names(data_trains))
names(data_trains) <- gsub("_$", "", names(data_trains))

# Exclure les gares étrangères
gares_etranger <- c("LAUSANNE", "ZURICH", "STUTTGART", "ITALIE", "GENEVE", "MADRID", "FRANCFORT")
data_trains <- data_trains %>%
  filter(!(Departure_station %in% gares_etranger | Arrival_station %in% gares_etranger))

# === Préparation : regrouper par mois ===
retards_mensuels <- data_trains %>%
  mutate(date = as.Date(sprintf("%d-%02d-01", Year, Month))) %>%
  filter(date >= as.Date("2015-01-01") & date <= as.Date("2020-12-31")) %>%
  group_by(date) %>%
  summarise(
    nb_total = sum(Number_of_expected_circulations, na.rm = TRUE),
    nb_annules = sum(Number_of_cancelled_trains, na.rm = TRUE),
    retard_15min = sum(`Number_of_late_trains_>_15min`, na.rm = TRUE),
    retard_30min = sum(`Number_of_late_trains_>_30min`, na.rm = TRUE),
    retard_60min = sum(`Number_of_late_trains_>_60min`, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    nb_circules = nb_total - nb_annules,
    pourcent_retard_15 = 100 * retard_15min / nb_circules,
    pourcent_retard_30 = 100 * retard_30min / nb_circules,
    pourcent_retard_60 = 100 * retard_60min / nb_circules,
    Mois_annee = format(date, "%m/%Y")
  )

# === Données en long pour ggplot ===
retards_long <- retards_mensuels %>%
  select(date, pourcent_retard_15, pourcent_retard_30, pourcent_retard_60, Mois_annee) %>%
  pivot_longer(cols = starts_with("pourcent_retard"),
               names_to = "Type_retard", values_to = "Pourcentage") %>%
  mutate(
    Type_retard = case_when(
      Type_retard == "pourcent_retard_15" ~ "> 15 min",
      Type_retard == "pourcent_retard_30" ~ "> 30 min",
      Type_retard == "pourcent_retard_60" ~ "> 60 min"
    ),
    Saison = case_when(
      month(date) %in% c(12, 1, 2) ~ "Hiver",
      month(date) %in% c(3, 4, 5) ~ "Printemps",
      month(date) %in% c(6, 7, 8) ~ "Été",
      month(date) %in% c(9, 10, 11) ~ "Automne"
    ),
    tooltip = paste0(
      "<b>", Mois_annee, "</b><br>",
      "Retards ", Type_retard, " : <b>", round(Pourcentage, 1), "%</b>"
    )
  )

# === Couleurs ===
couleurs_retard <- c(
  "> 15 min" = "#FFEE58",
  "> 30 min" = "#FFA726",
  "> 60 min" = "#EF5350"
)

# Générer les saisons pour tout 2015-2020
gen_saisons <- function(annee) {
  data.frame(
    Saison = c("Hiver", "Printemps", "Été", "Automne"),
    xmin = as.Date(c(
      paste0(annee, "-12-21"),
      paste0(annee, "-03-21"),
      paste0(annee, "-06-21"),
      paste0(annee, "-09-21")
    )),
    xmax = as.Date(c(
      paste0(annee + 1, "-03-20"),
      paste0(annee, "-06-20"),
      paste0(annee, "-09-20"),
      paste0(annee, "-12-20")
    )),
    label_pos = as.Date(c(
      paste0(annee + 1, "-02-05"),
      paste0(annee, "-05-05"),
      paste0(annee, "-08-05"),
      paste0(annee, "-11-05")
    ))
  )
}

saisons <- bind_rows(lapply(2015:2020, gen_saisons))

# Max pour placement du texte
hauteur_max <- max(rowSums(retards_mensuels[, c("pourcent_retard_15", "pourcent_retard_30", "pourcent_retard_60")]), na.rm = TRUE)

# === Graphique ===
p <- ggplot() +
  
  # Fond saison
  geom_rect(data = saisons,
            aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = Saison),
            alpha = 0.07,
            inherit.aes = FALSE) +
  
  # Barres empilées
  geom_col(data = retards_long,
           aes(x = date, y = Pourcentage, fill = Type_retard, text = tooltip),
           position = "stack", width = 25) +
  
  # Label de saison
  geom_text(data = saisons,
            aes(x = label_pos, y = hauteur_max * 1.02, label = Saison),
            inherit.aes = FALSE,
            color = "grey40",
            size = 3.5,
            fontface = "bold") +
  
  scale_fill_manual(values = c(couleurs_retard, 
                               "Hiver" = "lightblue", 
                               "Printemps" = "lightgreen", 
                               "Été" = "khaki", 
                               "Automne" = "sandybrown")) +
  
  labs(
    title = "Évolution mensuelle des retards ferroviaires en pourcentage (2015–2020)",
    x = "Mois",
    y = "% de trains en retard",
    fill = "Type de retard"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank()
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months")

# === Interactif ===
ggplotly(p, tooltip = "text")


