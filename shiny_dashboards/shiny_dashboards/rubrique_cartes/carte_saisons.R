make_carte_saison <- function(data, saison, annee, gare_coords) {
  mois_saison <- if (saison == "Été") c(6, 7, 8, 9) else c(12, 1, 2, 3)
  
  retards <- data %>%
    filter(Year == annee, Month %in% mois_saison) %>%
    mutate(Saison = saison) %>%
    group_by(Departure_station) %>%
    summarise(
      avg_delay_depart = mean(Average_delay_of_all_departing_trains, na.rm = TRUE),
      avg_delay_arrivee = mean(Average_delay_of_all_arriving_trains, na.rm = TRUE),
      avg_delay = (avg_delay_depart + avg_delay_arrivee) / 2,
      .groups = "drop"
    ) %>%
    left_join(gare_coords, by = c("Departure_station" = "station")) %>%
    filter(!is.na(latitude) & !is.na(longitude))
  
  max_delay <- max(retards$avg_delay, na.rm = TRUE)
  pal <- colorNumeric(palette = colorRampPalette(c("green", "yellow", "red"))(100), domain = c(0, max_delay))
  
  leaflet(retards) %>%
    addProviderTiles("CartoDB.PositronNoLabels") %>%
    addCircleMarkers(
      lng = ~longitude, lat = ~latitude,
      radius = ~avg_delay,
      fillColor = ~pal(avg_delay),
      fillOpacity = 0.8,
      color = ~pal(avg_delay),
      weight = 1,
      label = ~paste(Departure_station, ": ", round(avg_delay, 2), "min")
    ) %>%
    addLegend("bottomleft", pal = pal, values = ~avg_delay, title = "Retard moyen", labFormat = labelFormat(suffix = " min"))
}
