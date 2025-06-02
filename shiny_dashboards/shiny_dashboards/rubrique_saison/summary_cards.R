# summary_cards.R

library(shiny)
library(dplyr)

make_summary_cards <- function(data, annee) {
  if (is.null(annee) || length(annee) == 0) {
    return(NULL)
  }
  
  df_year <- data %>% filter(Year == annee)
  if (nrow(df_year) == 0) {
    return(NULL)
  }
  
  # Calcul des pourcentages
  total_attendus <- sum(df_year$Number_of_expected_circulations, na.rm = TRUE)
  total_annules  <- sum(df_year$Number_of_cancelled_trains, na.rm = TRUE)
  total_circules <- total_attendus - total_annules
  
  retard15 <- sum(df_year$`Number_of_late_trains_>_15min`, na.rm = TRUE)
  retard30 <- sum(df_year$`Number_of_late_trains_>_30min`, na.rm = TRUE)
  retard60 <- sum(df_year$`Number_of_late_trains_>_60min`, na.rm = TRUE)
  
  if (total_circules <= 0) {
    pct_retard60 <- 0; pct_retard30 <- 0; pct_retard15 <- 0; pct_heure <- 0
  } else {
    pct_retard60 <- round(100 * retard60 / total_circules, 1)
    pct_retard30 <- round(100 * retard30 / total_circules, 1)
    pct_retard15 <- round(100 * retard15 / total_circules, 1)
    pct_heure     <- round(100 * (total_circules - (retard15 + retard30 + retard60)) / total_circules, 1)
  }
  
  tagList(
    tags$div(
      style = "
        display: flex;
        flex-direction: row;
        flex-wrap: nowrap;
        gap: 1rem;      
        align-items: center;
        width: 100%;    
      ",
      
      # Carte 1 : % trains en retard > 60 min (rouge)
      tags$div(
        style = "
          background-color: #EF5350;  
          color: white;
          border-radius: 8px;
          padding: 1rem;
          text-align: center;
          flex: 1;      
          box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        ",
        tags$div(style = "font-size: 1.5rem; font-weight: bold;", paste0(pct_retard60, "%")),
        tags$div("Retard > 60 min")
      ),
      
      # Carte 2 : % trains en retard > 30 min (orange)
      tags$div(
        style = "
          background-color: #FFA726;  /* orange */
          color: white;
          border-radius: 8px;
          padding: 1rem;
          text-align: center;
          flex: 1;
          box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        ",
        tags$div(style = "font-size: 1.5rem; font-weight: bold;", paste0(pct_retard30, "%")),
        tags$div("Retard > 30 min")
      ),
      
      # Carte 3 : % trains en retard > 15 min (jaune)
      tags$div(
        style = "
          background-color: #FFEE58;  /* jaune */
          color: #333;
          border-radius: 8px;
          padding: 1rem;
          text-align: center;
          flex: 1;
          box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        ",
        tags$div(style = "font-size: 1.5rem; font-weight: bold;", paste0(pct_retard15, "%")),
        tags$div("Retard > 15 min")
      ),
      
      # Carte 4 : % trains à l’heure (vert)
      tags$div(
        style = "
          background-color: #66BB6A; 
          color: white;
          border-radius: 8px;
          padding: 1rem;
          text-align: center;
          flex: 1;
          box-shadow: 0 2px 4px rgba(0,0,0,0.05);
          height: 100%;
        ",
        tags$div(style = "font-size: 1.5rem; font-weight: bold;", paste0(pct_heure, "%")),
        tags$div("À l’heure")
      )
    )
  )
}
