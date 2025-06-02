# app.R
library(shiny)
library(dplyr)
library(readr)
library(plotly)
library(leaflet)   
library(sf)        

# 1) Charger scripts 
source("data_loader.R")

# ------------------------------------
source("rubrique_presentation/presentation_cards.R")
source("rubrique_presentation/ui_presentation.R")
source("rubrique_presentation/tableau_gares.R")
# ------------------------------------
source("rubrique_saison/plot_trains.R")      
source("rubrique_saison/plot_saisons.R")     
source("rubrique_saison/ui_helpers.R")      
source("rubrique_saison/summary_cards.R")   
source("rubrique_saison/carte_france.R")     
source("rubrique_saison/ui_analyse_saison.R")
#-------------------------------------

# 3) Définir l'UI principal
ui <- navbarPage(
  title = "Cypher - P25",
  # Onglet “Présentation”
  # ─── Onglet Présentation ───
  header = tags$head(
    includeCSS("www/style.css")
  ),
  # Onglet “Présentation”
  ui_presentation(data_trains, annees_disponibles),
  
  
  # Onglet “Analyse par Saison”
  ui_analyse_saison(data_trains, annees_disponibles)
)

# 4) Serveur
server <- function(input, output, session) {
  # Summary cards
  output$summaryCards <- renderUI({
    make_summary_cards(data_trains, input$annee)
  })
  # Titres dynamiques
  output$titre1_graph <- renderUI({
    div(class = "graph-title",
        paste0("Graphique 1 : Retards cumulés > 15/30/60 min – Année ", input$annee)
    )
  })
  output$titre2_graph <- renderUI({
    div(class = "graph-title",
        paste0("Graphique 2 : Répartition mensuelle & saisons – Année ", input$annee)
    )
  })
  output$titre3_graph <- renderUI({
    div(class = "graph-title",
        paste0("Graphique 3 : Carte SNCF des retards – Année ", input$annee)
    )
  })
  # Graphiques Plotly
  output$exemplePlot <- renderPlotly({
    make_retard_plot(data_trains, input$annee)
  })
  output$saisonPlot <- renderPlotly({
    make_saison_plot(data_trains, input$annee)
  })
  # Carte Leaflet
  output$map <- renderLeaflet({
    make_carte_france(input$annee)
  })
  # Tableau 
  output$table_gares <- renderTable({
    data_trains %>%
      transmute(Gare = Departure_station) %>%
      bind_rows(
        data_trains %>% transmute(Gare = Arrival_station)
      ) %>%
      distinct(Gare) %>%
      filter(
        !Gare %in% c(
          "LAUSANNE", "ZURICH", "STUTTGART", "ITALIE",
          "GENEVE", "MADRID", "FRANCFORT"
        )
      ) %>%
      arrange(Gare)
  })
  
}
# 5) Lancer l’application
shinyApp(ui = ui, server = server)

