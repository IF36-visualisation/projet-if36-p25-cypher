#tableau_gares.R
        tags$div(
          style = "
        background-color: #ffffff;
        border: 1px solid #ddd;
        border-radius: 8px;
        padding: 1rem;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        margin-top: 1.5rem;
     
      ",
          tags$h4("Liste des gares françaises"),
          tags$div(
            style = "height: 400px; overflow-y: auto;",
            tableOutput("table_gares")
          )
        )
