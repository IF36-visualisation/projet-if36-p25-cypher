#######################################################################
# Évolution des retards dans le temps (2015–2020) - Visualisation Plotly
#######################################################################

library(dplyr)
library(readr)
library(tidyr)
library(plotly)

# === Chargement des données ===
data_trains <- read_csv("data/Train_dataset.csv")

# Nettoyage des colonnes
data_trains <- data_trains %>% 
  select(-`Comment (optional) delays at departure`, -`Comment (optional) delays on arrival`)
names(data_trains) <- gsub("\\s*\\([^)]*\\)", "", names(data_trains))
names(data_trains) <- gsub(" ", "_", names(data_trains))
names(data_trains) <- gsub("_$", "", names(data_trains))

# Exclure les gares étrangères
gares_etranger <- c("LAUSANNE", "ZURICH", "STUTTGART", "ITALIE", "GENEVE", "MADRID", "FRANCFORT")
data_trains <- data_trains %>%
  filter(!(Departure_station %in% gares_etranger | Arrival_station %in% gares_etranger))

# Garder uniquement les années de 2015 à 2020
data_trains <- data_trains %>% filter(Year >= 2015 & Year <= 2020)

# Agrégation mensuelle
retards_mensuels <- data_trains %>%
  group_by(Year, Month) %>%
  summarise(
    nb_total     = sum(Number_of_expected_circulations, na.rm = TRUE),
    nb_annules   = sum(Number_of_cancelled_trains, na.rm = TRUE),
    retard_15min = sum(`Number_of_late_trains_>_15min`, na.rm = TRUE),
    retard_30min = sum(`Number_of_late_trains_>_30min`, na.rm = TRUE),
    retard_60min = sum(`Number_of_late_trains_>_60min`, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(sprintf("%d-%02d-01", Year, Month)),
    total_retards = retard_15min + retard_30min + retard_60min,
    total_trains = nb_total - nb_annules,
    a_lheure = total_trains - total_retards,
    pct_retards = round(100 * total_retards / total_trains, 1),
    tooltip_global = paste0(
      "<b>", format(date, "%d/%m/%Y"), "</b><br>",
      "<i>Trains à l’heure :</i> ", a_lheure, " trains<br>",
      "> 15 min : ", retard_15min, " trains<br>",
      "> 30 min : ", retard_30min, " trains<br>",
      "> 60 min : ", retard_60min, " trains<br>",
      "<b>Total retards :</b> ", total_retards, " trains<br>",
      "<b>Soit </b>", pct_retards, "% des trains"
    )
  ) %>%
  arrange(date)

# Calcul des couches empilées inversées
retards_mensuels <- retards_mensuels %>%
  mutate(
    cumul_60 = retard_60min,
    cumul_30 = cumul_60 + retard_30min,
    cumul_15 = cumul_30 + retard_15min
  )

# === Création du graphique Plotly ===
fig <- plot_ly()

# Rouge (retard > 60 min)
fig <- fig %>%
  add_trace(
    data = retards_mensuels,
    x = ~date,
    y = ~cumul_60,
    type = "scatter",
    mode = "lines",
    name = "Retards > 60 min",
    line = list(color = "#EF5350", width = 1),
    fill = "tozeroy",
    fillcolor = "rgba(239,83,80,0.6)",
    hoverinfo = "skip"
  )

# Orange (retard > 30 min)
fig <- fig %>%
  add_trace(
    data = retards_mensuels,
    x = ~date,
    y = ~cumul_30,
    type = "scatter",
    mode = "lines",
    name = "Retards > 30 min",
    line = list(color = "#FFA726", width = 1),
    fill = "tonexty",
    fillcolor = "rgba(255,167,38,0.6)",
    hoverinfo = "skip"
  )

# Jaune (retard > 15 min)
fig <- fig %>%
  add_trace(
    data = retards_mensuels,
    x = ~date,
    y = ~cumul_15,
    type = "scatter",
    mode = "lines",
    name = "Retards > 15 min",
    line = list(color = "#FFEE58", width = 1),
    fill = "tonexty",
    fillcolor = "rgba(255,238,88,0.6)",
    hoverinfo = "skip"
  )

# Courbe verte (trains à l’heure)
fig <- fig %>%
  add_trace(
    data = retards_mensuels,
    x = ~date,
    y = ~a_lheure,
    type = "scatter",
    mode = "lines",
    name = "Trains à l’heure",
    line = list(color = "green", width = 1),
    hoverinfo = "skip"
  )

# Trace transparente pour le tooltip global
fig <- fig %>%
  add_trace(
    data = retards_mensuels,
    x = ~date,
    y = ~retard_15min,
    type = "scatter",
    mode = "lines",
    line = list(color = "rgba(0,0,0,0)"),
    text = ~tooltip_global,
    hoverinfo = "text",
    showlegend = FALSE
  )

# Mise en page finale
fig <- fig %>%
  layout(
    title = list(
      text = "<b>ÉVOLUTION MENSUELLE DES RETARDS DE TRAINS EN FRANCE (2015-2020)</b>",
      x = 0.5,
      xanchor = "center",
      y = 0.95,
      yanchor = "top",
      font = list(size = 18)
    ),
    margin = list(t = 100),
    xaxis = list(title = "Date"),
    yaxis = list(title = "Nombre de trains"),
    legend = list(title = list(text = "Type de retard")),
    hovermode = "closest"
  )

fig


