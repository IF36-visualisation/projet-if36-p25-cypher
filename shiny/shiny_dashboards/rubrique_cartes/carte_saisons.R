make_cartes_saisons <- function(data, annee, gare_coords) {
  # 1. Filtrer et préparer
  retards_saison <- data %>%
    filter(Year == annee, Month %in% c(12, 1, 2, 3, 6, 7, 8, 9)) %>%
    mutate(Saison = case_when(
      Month %in% c(6, 7, 8, 9) ~ "Été",
      Month %in% c(12, 1, 2, 3) ~ "Hiver"
    )) %>%
    group_by(Saison, Departure_station) %>%
    summarise(
      avg_delay_depart = mean(Average_delay_of_all_departing_trains, na.rm = TRUE),
      avg_delay_arrivee = mean(Average_delay_of_all_arriving_trains, na.rm = TRUE),
      avg_delay = (avg_delay_depart + avg_delay_arrivee) / 2,
      .groups = "drop"
    ) %>%
    left_join(gare_coords, by = c("Departure_station" = "station")) %>%
    filter(!is.na(latitude) & !is.na(longitude))
  
  # 2. Palette commune basée sur toutes les valeurs
  max_delay <- max(retards_saison$avg_delay, na.rm = TRUE)
  pal <- colorNumeric(
    palette = colorRampPalette(c("green", "yellow", "red"))(100),
    domain = c(0, max_delay)
  )
  
  # 3. Cartes
  make_leaflet <- function(df) {
    leaflet(df) %>%
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
      addLegend("bottomleft", pal = pal, values = df$avg_delay,
                title = "Retard moyen", labFormat = labelFormat(suffix = " min"))
  }
  
  list(
    ete = make_leaflet(retards_saison %>% filter(Saison == "Été")),
    hiver = make_leaflet(retards_saison %>% filter(Saison == "Hiver"))
  )
}
