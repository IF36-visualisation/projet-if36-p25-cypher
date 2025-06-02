# ui_analyse_saison.R

library(shiny)
library(plotly)

ui_analyse_saison <- function(data_trains, annees_disponibles) {
  tabPanel(
    title = "Analyse par Saison",
    fluidPage(
      tags$head(
        includeCSS("www/style.css")
      ),
      # 2.3) Encadré de la question 
      div(class = "outer-wrapper",
          div(class = "question-panel",
              "Y a-t-il des saisons où les retards sont plus fréquents ?"
          )
      ),
      
      # ─── Conteneur principal en deux colonnes ────────────────────────────────
      div(class = "outer-wrapper",
          div(class = "flex-container",
              
              # ─── COLONNE GAUCHE (48%) ─────────────────────────────────────────
              div(class = "left-column",
                  
                  div(class = "panel-style",
                      div(style = "
                  display: flex;
                  flex-direction: row;
                  align-items: center;
                  gap: 1rem;
                ",
                          
                          div(style = "flex: 0 0 auto;",
                              legendPlotlyUI()
                          ),
                          
                          div(style = "
                  flex: 1 1 auto;
                  padding-left: 0.5rem;
                  padding-right: 0.5rem;
                ",
                              sliderInput(
                                inputId = "annee",
                                label   = div(
                                  "Sélectionnez une année :",
                                  style = "margin-bottom: 0.5rem; font-weight: bold; color: #212121;"
                                ),
                                min   = min(annees_disponibles),
                                max   = max(annees_disponibles),
                                value = max(annees_disponibles),
                                step  = 1,
                                sep   = "",
                                width = "100%"
                              )
                          )
                      )  
                  ), 
                  # 2) Graphique 1 
                  div(class = "panel-style",
                      div(class = "graph-container",
                          uiOutput("titre1_graph"),
                          div(class = "graph-plot",
                              plotlyOutput("exemplePlot", width = "100%", height = "40vh")
                          )
                      )
                  ),
                  # 3) Graphique 2 
                  div(class = "panel-style",
                      div(class = "graph-container",
                          uiOutput("titre2_graph"),
                          div(class = "graph-plot",
                              plotlyOutput("saisonPlot", width = "100%", height = "40vh")
                          )
                      )
                  )
                  
              ),
              # ─── COLONNE DROITE (48%) ────────────────────────────────────────
              div(class = "right-column",
                  
                  # 1) Summary Cards (prend toute la largeur)
                  div(class = "panel-style",
                      uiOutput("summaryCards")
                  ),
                  
                  # 2) Carte Leaflet SNCF (occupe le reste de la hauteur)
                  div(class = "panel-style map-container",
                      uiOutput("titre3_graph"),
                      leafletOutput("map", width = "100%", height = "96%")
                  )
              ) 
          )
      ) 
    ) 
  )
}
