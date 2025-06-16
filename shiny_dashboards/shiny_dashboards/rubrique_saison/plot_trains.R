# plot_trains.R

library(dplyr)
library(plotly)

make_retard_plot <- function(data_trains, annee) {
  # Filtrer et agréger pour l'année sélectionnée
  df <- data_trains %>%
    filter(Year == annee) %>%
    group_by(Year, Month) %>%
    summarise(
      nb_total     = sum(Number_of_expected_circulations, na.rm = TRUE), #pour enlever l'aléatoire
      nb_annules   = sum(Number_of_cancelled_trains,      na.rm = TRUE), #pour enlever l'aléatoire
      retard_15min = sum(`Number_of_late_trains_>_15min`, na.rm = TRUE),
      retard_30min = sum(`Number_of_late_trains_>_30min`, na.rm = TRUE),
      retard_60min = sum(`Number_of_late_trains_>_60min`, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      date = as.Date(sprintf("%d-%02d-01", Year, Month)),
      total_retards = retard_15min + retard_30min + retard_60min,
      #total_trains = total_retards + sample(8000:12000, n(), replace = TRUE), #fonction aléatoire remove en commentaire
      total_trains = nb_total - nb_annules,
      a_lheure = total_trains - total_retards,
      pct_retards = round(100 * total_retards / total_trains, 1),
      tooltip_global = paste0(
        "<b>", format(date, "%d/%m/%Y"), "</b><br>",
        "<i>Trains à l’heure :</i> ", a_lheure, " trains<br>",
        "> 15 min : ", retard_15min, " trains<br>",
        "> 30 min : ", retard_30min, " trains<br>",
        "> 60 min : ", retard_60min, " trains<br>",
        "<b>Trains en retard :</b> ", total_retards, " trains<br>",
        "<b>Soit </b>", pct_retards, "% des trains"
      )
    ) %>%
    arrange(date) %>%
    mutate(
      cumul_60 = retard_60min,
      cumul_30 = cumul_60 + retard_30min,
      cumul_15 = cumul_30 + retard_15min
    )
  
  # Construction du graphique Plotly
  fig <- plot_ly()
  
  # Zone rouge (retard > 60 min)
  fig <- fig %>%
    add_trace(
      data = df,
      x = ~date,
      y = ~cumul_60,
      type = "scatter",
      mode = "lines",
      name = "retard_>_60min",
      line = list(color = "#EF5350", width = 1),
      fill = "tozeroy",
      fillcolor = "rgba(239,83,80,0.6)",
      hoverinfo = "skip"
    )
  
  # Zone orange (retard > 30 min)
  fig <- fig %>%
    add_trace(
      data = df,
      x = ~date,
      y = ~cumul_30,
      type = "scatter",
      mode = "lines",
      name = "retard_>_30min",
      line = list(color = "#FFA726", width = 1),
      fill = "tonexty",
      fillcolor = "rgba(255,167,38,0.6)",
      hoverinfo = "skip"
    )
  
  # Zone jaune (retard > 15 min)
  fig <- fig %>%
    add_trace(
      data = df,
      x = ~date,
      y = ~cumul_15,
      type = "scatter",
      mode = "lines",
      name = "retard_>_15min",
      line = list(color = "#FFEE58", width = 1),
      fill = "tonexty",
      fillcolor = "rgba(255,238,88,0.6)",
      hoverinfo = "skip"
    )
  
  # Courbe « trains à l’heure »
  fig <- fig %>%
    add_trace(
      data = df,
      x = ~date, 
      y = ~a_lheure,
      type = "scatter",
      mode = "lines",
      name = "Trains à l’heure",
      line = list(color = "green", width = 1),
      hoverinfo = "skip"
    )
  
  # Trace transparente pour afficher le tooltip global au survol
  fig <- fig %>%
    add_trace(
      data = df,
      x = ~date, 
      y = ~retard_15min,
      type = "scatter",
      mode = "lines",
      line = list(color = "rgba(0,0,0,0)"),
      text = ~tooltip_global,
      hoverinfo = "text",
      showlegend = FALSE
    )
  
  # Mise en page avec titre dynamique
  fig <- fig %>%
    layout(
      margin = list(t = 100),
      xaxis = list(title = "Date"),
      yaxis = list(title = "Nombre de trains"),
      legend = list(title = list(text = "Type de retard")),
      hovermode = "closest",
      showlegend = FALSE  
    )
  
  return(fig)
}
