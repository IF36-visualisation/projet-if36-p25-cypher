ui_cartes <- function(data_trains, annees_disponibles) {
  tabPanel(
    title = "Cartes Retards Saisons",
    sidebarLayout(
      sidebarPanel(
        selectInput("annee_carte", "Choisir une année :", choices = annees_disponibles)
      ),
      mainPanel(
        uiOutput("titre_carte_ete"),
        leafletOutput("carte_ete"),
        tags$hr(),
        uiOutput("titre_carte_hiver"),
        leafletOutput("carte_hiver")
      )
    )
  )
}