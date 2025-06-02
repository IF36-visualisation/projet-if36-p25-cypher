# ui_presentation.R

# ui_presentation.R

library(shiny)

ui_presentation <- function(data_trains, annees_disponibles) {
  tabPanel(
    title = "Présentation",
    fluidPage(
      # 1) Chargement du CSS 
      tags$head(
        includeCSS("www/style.css")
      ),
      div(class = "outer-wrapper",
          div(class = "question-panel", style="font-size: 3rem;",
              "Analyse du Transport Ferroviaire en France"
          )
      ),
      div(class = "outer-wrapper",
          div(class = "question-panel",
              "Présentation du jeu de données"
          )
      ),
      div(class = "outer-wrapper",
          div(class = "panel-style",
              make_presentation_cards(data_trains)
          )
      ),
      
      #    - à gauche : Tableau des gares (40 %)
      #    - à droite : Source du dataset + Membres (chacune 100 % de cette colonne)
      div(class = "outer-wrapper",
          div(
            class = "flex-container",
            style = "flex-wrap: nowrap;",
            
            # ─── COLONNE GAUCHE (40 %) ─────────────────────────────────────────────
            div(
              style = "
                flex: 0 0 40%;
                box-sizing: border-box;
              ",
              div(class = "panel-style",
                  tags$h4("Liste des gares françaises", style = "margin-bottom: 0.5rem;"),
                  tags$div(
                    style = "height: 450px; overflow-y: auto; ",
                    tableOutput("table_gares")
                  )
              )
            ),
            
            # ─── COLONNE DROITE (60 %) ────────────────────────────────────────────
            div(
              style = "
                flex: 0 0 60%;
                box-sizing: border-box;
                display: flex;
                flex-direction: column;
                gap: 1rem;
              ",
              
              # Box “Source du dataset”
              div(class = "panel-style",
                  tags$strong("Dataset trouvé sur :"),
                  tags$br(),
                  tags$a(
                    href = "https://www.kaggle.com/datasets/gatandubuc/public-transport-traffic-data-in-france",
                    "https://www.kaggle.com/datasets/gatandubuc/public-transport-traffic-data-in-france",
                    target = "_blank"
                  )
              ),
              
              # Box “Membres”
              div(class = "panel-style", style ="padding: 2rem;",
                  tags$h4("Membres", style = "margin-bottom: 0.5rem; font-weight: bold;"),
                  tags$p("VIGNERON Marian"),
                  tags$p("BRANCHUT Corentin"),
                  tags$p("WILLIATTE Oscar"),
                  tags$p("VELIC Ajna"),
                  tags$br(),
                  tags$h4("Contexte d'étude", style = "margin-bottom: 0.5rem; font-weight: bold;"),
                  
                  tags$p("Nous sommes un groupe de 4 étudiants de l'Université de Technologie de Troyes et, dans le cadre de nos études, nous effectuons un projet durant l'enseignement \"IF36\" (Visualisation de données) : nous devons analyser un jeu de données."),
                  tags$p("Nous avons choisi de travailler sur un jeu de données provenant de plusieurs sources ouvertes françaises (SNCF, Île-de-France Mobilités), car il offre une vue détaillée du réseau de transport ferroviaire en France, incluant la ponctualité, les validations de titres de transport et la géolocalisation des arrêts."),
                  tags$p("Ce dataset nous permet de mieux comprendre les dynamiques du réseau ferré.")
              )
              
            ) 
          ) 
      ) 
    ) 
  )

}
