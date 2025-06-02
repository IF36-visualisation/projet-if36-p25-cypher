# ui_analyse_saison.R

library(shiny)
library(plotly)

# (Vous pouvez également y importer d'autres dépendances CSS/JS si nécessaire.)

# Cette fonction renvoie un objet tabPanel qui contient tout l’UI 
# de l’onglet "Analyse par Saison".
ui_analyse_saison <- function(data_trains, annees_disponibles) {
  tabPanel(
    title = "Analyse par Saison",
    fluidPage(
      # 2.1) Fond rouge général
      tags$style(HTML("
        body { background-color: #991509 !important; }
      ")),
      
      # 2.2) CSS global
      tags$head(
        tags$style(HTML("
          .question-panel {
            background-color: #ffffff;
            color: #000000;
            border: 2px solid #ebdd1c;
            border-radius: 12px;
            padding: 1rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            box-sizing: border-box;
            margin: 1rem 0;
            text-align: center;
            font-weight: bold;
            font-size: 2rem;
          }
          .irs--shiny .irs-bar,
          .irs--shiny .irs-bar-edge {
            background-color: #ed9734 !important;
            border-top-color: #e65100 !important;
            border-bottom-color: #e65100 !important;
          }
          .irs--shiny .irs-handle.single {
            background-color: #e65100 !important;
            border: 2px solid #e65100 !important;
          }
          .irs--shiny .irs-single {
            background-color: #e65100 !important;
            color: #ffffff !important;
          }
          .outer-wrapper {
            padding-left: 1.1rem;
            padding-right: 1.1rem;
            box-sizing: border-box;
            margin-bottom: 1.1rem;
          }
          .flex-container {
            display: flex;
            flex-wrap: nowrap;
            gap: 2.5rem;
            margin-bottom: 1.1rem;
            align-items: stretch;
          }
          .flex-item {
            flex: 1;
            min-width: 300px;
          }
          .panel-style {
            border: 1px solid #ddd;
            border-radius: 10px;
            padding: 1rem;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            box-sizing: border-box;
            margin: 1rem 0;
          }
          .flex-half-left {
            flex: 0 0 48% !important;
            box-sizing: border-box;
          }
          .graph-container {
            display: flex;
            flex-direction: column;
            height: 100%;
          }
          .graph-title {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 8px;
            text-align: center;
          }
          .graph-plot {
            flex: 1;
            margin-top: 10px;
          }
          .left-column {
            display: flex;
            flex-direction: column;
            gap: 2.5rem;
            flex: 0 0 48%;
          }
          .right-column {
            flex: 0 0 48%;
            display: flex;
            flex-direction: column;
          }
          .map-container {
            height: 100%;
            padding: 0.5rem;
            box-sizing: border-box;
          }
        "))
      ),
      
      # 2.3) Encadré de la question
      div(class = "outer-wrapper",
          div(class = "question-panel",
              "Y a-t-il des saisons où les retards sont plus fréquents ?"
          )
      ),
      
      # ─── Bloc “Légende + Slider” / “Summary Cards” (50% / 50%) ───
      div(class = "outer-wrapper",
          div(class = "flex-container",
              
              # Colonne gauche (50 %) : légende + slider
              div(class = "flex-item flex-half-left panel-style",
                  div(style = "
                    display: flex;
                    flex-direction: row;
                    align-items: center;
                    gap: 1rem;
                  ",
                      # Bloc légende
                      div(style = "flex: 0 0 auto;",
                          legendPlotlyUI()
                      ),
                      # Bloc slider
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
              
              # Colonne droite (50 %) : summary cards
              div(class = "flex-item flex-half-left panel-style",
                  uiOutput("summaryCards")
              )
          )
      ),
      
      # ─── Bloc “Graphiques à gauche + Carte à droite” ─────────────────────────
      div(class = "outer-wrapper",
          div(class = "flex-container",
              
              # COLONNE GAUCHE (48 %) : Graphique 1 + Graphique 2
              div(class = "left-column",
                  # Graphique 1
                  div(class = "panel-style",
                      div(class = "graph-container",
                          uiOutput("titre1_graph"),
                          div(class = "graph-plot",
                              plotlyOutput("exemplePlot", width = "100%", height = "40vh")
                          )
                      )
                  ),
                  # Graphique 2
                  div(class = "panel-style",
                      div(class = "graph-container",
                          uiOutput("titre2_graph"),
                          div(class = "graph-plot",
                              plotlyOutput("saisonPlot", width = "100%", height = "40vh")
                          )
                      )
                  )
              ),
              
              # COLONNE DROITE (48 %) : Carte Leaflet occupant la même hauteur
              div(class = "right-column panel-style map-container",
                  uiOutput("titre3_graph"),
                  leafletOutput("map", width = "100%", height = "100%")
              )
          )
      )
    )  # fin fluidPage
  )    # fin tabPanel “Analyse par Saison”
}
