
ui_analyse_causes <- function(data, annees) {
  tabPanel(
    title = "Analyse par Causes",
    sidebarLayout(
      sidebarPanel(
        selectInput("annee_cause", "Année :", choices = annees, selected = max(annees))
      ),
      mainPanel(
        uiOutput("titre_graph_causes"),
        plotlyOutput("plot_causes")
      )
    )
  )
}