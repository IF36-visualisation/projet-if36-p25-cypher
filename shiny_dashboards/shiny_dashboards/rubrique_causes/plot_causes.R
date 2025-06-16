make_causes_plot <- function(data, annee) {
  causes_colnames <- c(
    "Delay_due_to_external_causes",
    "Delay_due_to_railway_infrastructure",
    "Delay_due_to_traffic_management",
    "Delay_due_to_rolling_stock",
    "Delay_due_to_travellers_taken_into_account",
    "Delay_due_to_station_management_and_reuse_of_material"
  )
  
  if (!all(causes_colnames %in% names(data))) {
    stop("Certaines colonnes de cause de retard sont absentes des données.")
  }
  
  df <- data %>%
    filter(Year == annee) %>%
    rename(
      cause_externe    = Delay_due_to_external_causes,
      infra_ferroviaire = Delay_due_to_railway_infrastructure,
      gestion_trafic    = Delay_due_to_traffic_management,
      materiel_roulant  = Delay_due_to_rolling_stock,
      cause_voyageur    = Delay_due_to_travellers_taken_into_account,
      retard_station    = Delay_due_to_station_management_and_reuse_of_material
    ) %>%
    group_by(Month) %>%
    summarise(across(
      c(cause_externe, infra_ferroviaire, gestion_trafic,
        materiel_roulant, cause_voyageur, retard_station),
      mean, na.rm = TRUE
    )) %>%
    pivot_longer(cols = -Month, names_to = "cause", values_to = "moyenne")
  
  saison_labels <- data.frame(
    x = c(2, 5, 8, 11),
    label = c("Hiver", "Printemps", "Été", "Automne")
  )
  
  ggplot(df, aes(x = Month, y = moyenne, fill = cause)) +
    geom_col(position = "stack") +
    geom_text(aes(label = round(moyenne, 1)),   # Sans suffixe % ici
              position = position_stack(vjust = 0.5),
              color = "white", size = 2.5) +
    
    geom_vline(xintercept = c(3.5, 6.5, 9.5), color = "black", linetype = "dashed", size = 0.6) +
    
    geom_text(data = saison_labels,
              aes(x = x, y = Inf, label = label),
              inherit.aes = FALSE,
              vjust = -0.5,
              size = 5, fontface = "bold") +
    
    labs(title = paste("Proportion des retards par mois et par cause -", annee),
         x = "Mois", y = "Proportion de retards") +
    
    scale_x_continuous(
      breaks = 1:12,
      labels = month.abb,
      limits = c(0.5, 12.5)
    ) +
    scale_y_continuous(labels = function(x) paste0(x, "%")) +  # Suffixe % uniquement sur axe Y
    
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.margin = margin(30, 20, 20, 20)
    )
}