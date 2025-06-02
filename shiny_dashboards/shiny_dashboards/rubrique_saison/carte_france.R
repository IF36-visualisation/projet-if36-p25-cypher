#carte_france.R

library(leaflet)
library(sf)
library(dplyr)


trajets_retards <- st_read("../../data/trajets_retards.geojson", quiet = TRUE)


make_carte_france <- function(annee) {
  # 2.1) Filtrer les données spatiales pour l’année spécifiée
  trajets_affiches <- trajets_retards %>%
    filter(year == annee) %>%
    mutate(
      color = colorNumeric(palette = "YlOrRd", domain = NULL)(retard_total),
      popup_text = paste0(
        "<b>", from, " → ", to, "</b><br/>",
        "Année : ", year, "<br/>",
        "Total trains en retard : ", retard_total, "<br/>",
        "➤ Retard ≥ 15 min : ", retard_15min, "<br/>",
        "➤ Retard ≥ 30 min : ", retard_30min, "<br/>",
        "➤ Retard ≥ 60 min : ", retard_60min
      )
    )
  
  # 2.2) Construire et retourner la carte Leaflet
  leaflet(trajets_affiches) %>%
    # Choisissez le fond de carte souhaité : ici “CartoDB.DarkMatter”
    addProviderTiles(provider = "CartoDB.DarkMatter") %>%
    # Centrer la vue sur la France métropolitaine
    setView(lng = 2.5, lat = 46.5, zoom = 6) %>%
    # Ajouter les polylignes, colorées selon “color” et avec popup
    addPolylines(
      color   = ~color,
      weight  = 2.5,
      opacity = 0.85,
      popup   = ~popup_text
    )
}
