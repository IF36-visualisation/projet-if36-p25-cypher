# Construction du dataset
retards_totaux <- data_trains %>%
  filter(Year == annee_selectionnee) %>%
  group_by(Departure_station) %>%
  summarise(
    retard_depart = sum(Number_of_late_trains_at_departure, na.rm = TRUE),
    retard_arrivee = sum(Number_of_trains_late_on_arrival, na.rm = TRUE),
    retards_totaux = retard_depart + retard_arrivee,
    .groups = "drop"
  ) %>%
  arrange(desc(retards_totaux))

# Top 3 gares
top3_gares <- retards_totaux %>% slice(1:3)

# Autres regroupés
reste_gares <- retards_totaux %>%
  filter(!(Departure_station %in% top3_gares$Departure_station)) %>%
  summarise(
    Departure_station = "Autres gares",
    retards_totaux = sum(retards_totaux, na.rm = TRUE)
  )

# Combinaison 
donnees_pie <- bind_rows(top3_gares, reste_gares)

# Ajout du pourcentage 
total_global <- sum(donnees_pie$retards_totaux)

donnees_pie <- donnees_pie %>%
  mutate(
    pourcentage = round((retards_totaux / total_global) * 100, 1),
    label_tooltip = paste0(
      "<b>Gare :</b> ", Departure_station, "<br>",
      "<b>Retards :</b> ", retards_totaux, " trains<br>",
      "Soit ", pourcentage, "% des retards"
    )
  )

# Piechart
library(plotly)

p_pie <- plot_ly(
  donnees_pie,
  labels = ~Departure_station,
  values = ~retards_totaux,
  type = 'pie',
  textinfo = 'label+percent',
  hoverinfo = 'text',
  text = ~label_tooltip,
  marker = list(colors = c("#EF5350", "#FFA726", "#FFEE58", "lightgrey"))  # Couleurs imposées
) %>%
  layout(
    title = list(
      text = paste0("<b>Répartition des retards par gare (", annee_selectionnee, ")</b>"),
      x = 0.5,
      xanchor = "center"
    ),
    showlegend = TRUE
  )

# Affichage
p_pie


