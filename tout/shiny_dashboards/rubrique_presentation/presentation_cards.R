# presentation_cards.R
# fichier : presentation_cards.R

library(shiny)
library(dplyr)

make_presentation_cards <- function(data) {
  # data : data.frame complet des trains, contenant déjà la colonne "date" et les colonnes "Departure_station" & "Arrival_station"
  
  # 1) Calculs sommaires -------------------------------------------------------
  # a) Dates min / max
  date_min <- min(data$date, na.rm = TRUE)
  date_max <- max(data$date, na.rm = TRUE)
  
  # b) Nombre total de lignes (enregistrements)
  n_lignes <- nrow(data)
  
  # c) Extraction des gares “françaises” (même filtre que dans data_loader)
  gares_francaises <- data %>%
    transmute(station = Departure_station) %>%
    bind_rows(data %>% transmute(station = Arrival_station)) %>%
    distinct(station) %>%
    filter(
      !station %in% c(
        "LAUSANNE", "ZURICH", "STUTTGART", "ITALIE",
        "GENEVE", "MADRID", "FRANCFORT"
      )
    )
  n_gares <- nrow(gares_francaises)
  
  # 2) Construction de l’UI ----------------------------------------------------
  tagList(
    # ─── Conteneur flex horizontal (100 % de largeur) pour les 3 cartes ───
    tags$div(
      style = "
        display: flex;
        flex-direction: row;
        flex-wrap: nowrap;
        gap: 1rem;        
        align-items: center;
        width: 100%;      
      ",
      
      # Carte 1 : Période (date min – date max)
      tags$div(
        style = "
          background-color: #2196F3;   /* bleu */
          color: white;
          border-radius: 8px;
          padding: 1rem;
          display: flex; flex-direction: column; justify-content: center; align-items: center;
          margin : 0.5rem;
          flex: 1;                     
          box-shadow: 0 2px 4px rgba(0,0,0,0.05);
          height: 20vh;                
        ",
        tags$div(
          style = "font-size: 2rem; font-weight: bold;",  
          paste0(format(date_min, "%b %Y"), " – ", format(date_max, "%b %Y"))
        ),
        tags$div("Période couverte")
      ),
      
      # Carte 2 : Nombre d’enregistrements (lignes)
      tags$div(
        style = "
          background-color: #4CAF50;   /* vert */
          color: white;
          border-radius: 8px;
          padding: 1rem;
          display: flex; flex-direction: column; justify-content: center; align-items: center;
          flex: 1;
          margin : 0.5rem;
          box-shadow: 0 2px 4px rgba(0,0,0,0.05);
          height: 20vh;                /* hauteur fixée à 20vh */
        ",
        tags$div(
          style = "font-size: 2rem; font-weight: bold;", 
          n_lignes
        ),
        tags$div("Nombre d’enregistrements")
      ),
      
      # Carte 3 : Nombre de gares françaises
      tags$div(
        style = "
          background-color: #FF9800;   /* orange */
          color: white;
          border-radius: 8px;
          padding: 1rem;
          display: flex; flex-direction: column; justify-content: center; align-items: center;
          flex: 1;
          margin : 0.5rem;
          box-shadow: 0 2px 4px rgba(0,0,0,0.05);
          height: 20vh;                /* hauteur fixée à 20vh */
        ",
        tags$div(
          style = "font-size: 2rem; font-weight: bold;",  
          n_gares
        ),
        tags$div("Nombre de gares FR")
      )
    )
  )
}




