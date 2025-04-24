library(shiny)
library(dplyr)
library(readr)
library(leaflet)
library(purrr)
library(jsonlite)
library(sf)
##################################################################################################################################################
#Question 1 

#1. Évolution des retards dans le temps

#Question : Comment la ponctualité évolue-t-elle au fil des mois ?

#Réponse : bon, ici on va regarder ca pour au fil des années car si je devais stocker les mois, ca ferait trop de données à stocker et à traiter.
#donc on va faire ca par année
#ce graphe est juste un "test" prcq imcomplet et recuperer les données ferroviaires : trop fastidieux...

##################################################################################################################################################

# Chargement du GeoJSON enrichi avec les années
trajets_retards <- st_read("data/trajets_retards.geojson", quiet = TRUE)

# UI
ui <- fluidPage(
  titlePanel("Carte interactive des retards SNCF (2015–2020)"),
  sliderInput("annee", "Choisir l'année :", min = 2015, max = 2020, value = 2019, step = 1, sep = ""),
  leafletOutput("map", height = 700)
)

# Serveur
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    trajets_affiches <- trajets_retards %>%
      filter(year == input$annee) %>%
      mutate(
        color = colorNumeric("YlOrRd", domain = NULL)(retard_total),
        popup_text = paste0(
          "<b>", from, " → ", to, "</b><br>",
          "Année : ", year, "<br>",
          "Total trains en retard : ", retard_total, "<br>",
          "➤ 15 min+ : ", retard_15min, "<br>",
          "➤ 30 min+ : ", retard_30min, "<br>",
          "➤ 60 min+ : ", retard_60min
        )
      )
    
    leaflet(trajets_affiches) %>%
      addProviderTiles("CartoDB.DarkMatter") %>%
      setView(lng = 2.5, lat = 46.5, zoom = 6) %>%
      addPolylines(
        color = ~color,
        weight = 2.5,
        opacity = 0.85,
        popup = ~popup_text
      )
  })
}

# App
shinyApp(ui = ui, server = server)



# Extraire les gares de départ et d'arrivée
#comment on a construit le gares.csv :

#gares_uniques <- unique(c(data_trains$Departure_station, data_trains$Arrival_station))
# Mettre dans un data frame
#gares_df <- data.frame(station = sort(gares_uniques))
# Affichage pour vérification
#head(gares_df)
#write.csv(gares_df, "gares.csv", row.names = FALSE)

