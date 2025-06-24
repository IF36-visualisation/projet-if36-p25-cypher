# plot_saisons.R

library(dplyr)
library(tidyr)      
library(ggplot2)
library(plotly)
library(lubridate)
library(scales)      

make_saison_plot <- function(data_trains, annee) {
  
  # 1) Filtrer l'année 
  df_annee <- data_trains %>%
    filter(Year == annee) %>%
    mutate(date = as.Date(sprintf("%d-%02d-01", Year, Month)))
  
  # 2) Agréger mois par mois
  retards_mensuels <- df_annee %>%
    group_by(date) %>%
    summarise(
      nb_total       = sum(Number_of_expected_circulations, na.rm = TRUE),
      nb_annules     = sum(Number_of_cancelled_trains, na.rm = TRUE),
      retard_15min   = sum(`Number_of_late_trains_>_15min`, na.rm = TRUE),
      retard_30min   = sum(`Number_of_late_trains_>_30min`, na.rm = TRUE),
      retard_60min   = sum(`Number_of_late_trains_>_60min`, na.rm = TRUE),
      retard_depart  = sum(Number_of_late_trains_at_departure, na.rm = TRUE),
      retard_arrivee = sum(Number_of_trains_late_on_arrival, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      nb_circules         = nb_total - nb_annules,
      total_retards       = retard_arrivee,
      trains_a_lheure     = nb_circules - total_retards,
      pourcentage_alheure = round((trains_a_lheure / nb_circules) * 100, 1),
      Mois_annee          = format(date, "%m/%Y"),
      tooltip_text        = paste0(
        "<b>", Mois_annee, "</b><br>",
        "Trains à l'heure : ", trains_a_lheure, " trains<br>",
        "Soit <b>", pourcentage_alheure, "</b>% des trains"
      )
    )
  
  # 3) Passer en format long pour empiler les trois types de retards
  retards_long <- retards_mensuels %>%
    pivot_longer(
      cols      = c(retard_15min, retard_30min, retard_60min),
      names_to  = "Type_retard",
      values_to = "Nombre"
    ) %>%
    mutate(
      Saison = case_when(
        month(date) %in% c(12, 1, 2)  ~ "Hiver",
        month(date) %in% c(3, 4, 5)   ~ "Printemps",
        month(date) %in% c(6, 7, 8)   ~ "Été",
        month(date) %in% c(9, 10, 11) ~ "Automne"
      ),
      Mois_annee  = format(date, "%m/%Y"),
      pourcentage = round((Nombre / (Nombre + trains_a_lheure)) * 100, 1),
      tooltip_text = paste0(
        "<b>", Mois_annee, "</b><br>",
        case_when(
          Type_retard == "retard_15min" ~ "> 15 min : ",
          Type_retard == "retard_30min" ~ "> 30 min : ",
          Type_retard == "retard_60min" ~ "> 60 min : ",
          TRUE ~ ""
        ),
        Nombre, " trains<br>",
        "Soit <b>", pourcentage, "</b>% des trains"
      )
    )
  
  # 4) Définir les saisons (xmin/xmax et position des labels)
  saisons <- data.frame(
    Saison    = c("Hiver", "Printemps", "Été", "Automne"),
    xmin      = as.Date(c(
      paste0(annee, "-12-21"),
      paste0(annee, "-03-21"),
      paste0(annee, "-06-21"),
      paste0(annee, "-09-21")
    )),
    xmax      = as.Date(c(
      paste0(annee, "-03-20"),
      paste0(annee, "-06-20"),
      paste0(annee, "-09-20"),
      paste0(annee, "-12-20")
    )),
    label_pos = as.Date(c(
      paste0(annee, "-02-05"),
      paste0(annee, "-05-05"),
      paste0(annee, "-08-05"),
      paste0(annee, "-11-05")
    ))
  )
  
  # 5) Hauteur maxi pour placer les labels de saisons juste au-dessus des barres
  hauteur_max <- max(retards_mensuels$nb_circules, na.rm = TRUE)
  
  # 6) Palette fixe pour les trois niveaux de retard
  couleurs_retard <- c(
    "retard_15min" = "#FFEE58",
    "retard_30min" = "#FFA726",
    "retard_60min" = "#EF5350"
  )
  
  # 7) Construction du ggplot (sans appel en-dehors de la fonction)
  p <- ggplot() +
    # 7.1) Barres grisées = trains à l’heure
    geom_col(
      data = retards_mensuels,
      aes(
        x    = date,
        y    = trains_a_lheure,
        fill = "trains_a_lheure",
        text = tooltip_text
      ),
      width = 25,
      alpha = 0.5
    ) +
    # 7.2) Barres empilées des retards
    geom_col(
      data = retards_long,
      aes(
        x    = date,
        y    = Nombre,
        fill = Type_retard,
        text = tooltip_text
      ),
      position = "stack",
      width = 25
    ) +
    # 7.3) Traits verticaux pour les saisons
    geom_vline(
      data = saisons,
      aes(xintercept = as.numeric(xmin)),
      linetype = "dashed",
      color    = "grey50",
      size     = 0.5
    ) +
    # 7.4) Libellés des saisons
    geom_text(
      data = saisons,
      aes(
        x     = label_pos,
        y     = hauteur_max * 1.02,
        label = Saison
      ),
      inherit.aes = FALSE,
      size     = 4,
      color    = "grey40"
    ) +
    # 7.5) Palette manuelle
    scale_fill_manual(
      values = c(couleurs_retard, "trains_a_lheure" = "#90EE90"),
      breaks = c("trains_a_lheure", "retard_15min", "retard_30min", "retard_60min"),
      labels = c("Trains à l'heure", "> 15 min", "> 30 min", "> 60 min")
    ) +
    # 7.6) Format des axes
    scale_y_continuous(labels = label_number(scale = 1e-3, suffix = "k")) +
    scale_x_date(date_labels = "%b", date_breaks = "1 month") +
    labs(
      x    = "Mois",
      y    = "Nombre de trains",
      fill = "Type de retards"
    ) +
    theme_minimal(base_size = 12, base_family = "Arial") +
    theme(
      axis.title.x       = element_text(size = 12, color = "grey40"),
      axis.title.y       = element_text(size = 12, color = "grey40"),
      axis.text.x        = element_text(angle = 45, hjust = 1, size = 10),
      axis.text.y        = element_text(size = 10),
      legend.position    = "none",
      panel.grid.major.x = element_blank(),
      plot.margin        = margin(t = 30, r = 10, b = 10, l = 10)
    )
  
  # 8) Conversion en Plotly (toujours à l’intérieur de la fonction)
  p_interactif <- ggplotly(p, tooltip = "text") %>%
    layout(
      font       = list(family = "Arial", size = 11),
      showlegend = FALSE
    )
  
  return(p_interactif)
  
} 


