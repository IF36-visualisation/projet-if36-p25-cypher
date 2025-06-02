# ui_helpers.R 

legendPlotlyUI <- function() {
  tags$div(
    style = "
      border: 1px solid #ddd;
      border-radius: 4px;
      padding: 10px;
      width: 200px;
      background-color: #ffffff;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    ",
    # Titre de la légende
    tags$div(
      style = "font-family:Arial; font-size:14px; font-weight:bold; margin-bottom:8px;",
      "Légende"
    ),
    
    # 1. Trains à l'heure (vert)
    tags$div(
      style = "display:flex; align-items:center; margin-bottom:6px;",
      tags$div(
        style = "width:15px; height:15px; background-color:green; margin-right:8px; border:1px solid #ccc;"
      ),
      tags$span(style = "font-family:Arial; font-size:12px;", "Trains à l’heure")
    ),
    # 2. > 15 min (jaune)
    tags$div(
      style = "display:flex; align-items:center; margin-bottom:6px;",
      tags$div(
        style = "width:15px; height:15px; background-color:#FFEE58; margin-right:8px; border:1px solid #ccc;"
      ),
      tags$span(style = "font-family:Arial; font-size:12px;", "> 15 min")
    ),
    # 3. > 30 min (orange)
    tags$div(
      style = "display:flex; align-items:center; margin-bottom:6px;",
      tags$div(
        style = "width:15px; height:15px; background-color:#FFA726; margin-right:8px; border:1px solid #ccc;"
      ),
      tags$span(style = "font-family:Arial; font-size:12px;", "> 30 min")
    ),
    # 4. > 60 min (rouge)
    tags$div(
      style = "display:flex; align-items:center;",
      tags$div(
        style = "width:15px; height:15px; background-color:#EF5350; margin-right:8px; border:1px solid #ccc;"
      ),
      tags$span(style = "font-family:Arial; font-size:12px;", "> 60 min")
    )
  )
}
