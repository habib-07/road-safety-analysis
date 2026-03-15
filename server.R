server <- function(input, output, session) {

  # Donnees filtrees
  acc_f <- reactive({
    accidents |>
      filter(
        gravite_max %in% input$filtre_gravite,
        catr_lib    %in% input$filtre_route | is.na(catr_lib),
        mois_lab    %in% input$filtre_mois  | is.na(mois_lab)
      )
  })

  # ---- VALUE BOXES ----

  output$vbox_total <- renderValueBox({
    valueBox(format(nrow(acc_f()), big.mark = " "),
             "Accidents", icon = icon("car-crash"), color = "blue")
  })

  output$vbox_mortels <- renderValueBox({
    valueBox(format(sum(acc_f()$gravite_max == "Mortel"), big.mark = " "),
             "Mortels", icon = icon("skull"), color = "red")
  })

  output$vbox_graves <- renderValueBox({
    valueBox(format(sum(acc_f()$gravite_max == "Grave"), big.mark = " "),
             "Graves", icon = icon("ambulance"), color = "orange")
  })

  output$vbox_taux <- renderValueBox({
    taux <- round(sum(acc_f()$gravite_max == "Mortel") / nrow(acc_f()) * 100, 1)
    valueBox(paste0(taux, "%"), "Taux mortalite",
             icon = icon("percent"), color = "purple")
  })

  # ---- VUE D ENSEMBLE ----

  output$p_grav <- renderPlot({
    acc_f() |> count(gravite_max) |> mutate(pct = n / sum(n) * 100) |>
      ggplot(aes("", pct, fill = gravite_max)) +
      geom_col(width = 1) + coord_polar("y") +
      scale_fill_manual(values = palette_grav) +
      geom_text(aes(label = paste0(round(pct, 1), "%")),
                position = position_stack(vjust = .5), color = "white", size = 4) +
      labs(fill = NULL) + theme_void()
  })

  output$p_horaire <- renderPlot({
    acc_f() |> filter(!is.na(heure)) |> count(heure, gravite_max) |>
      ggplot(aes(heure, n, fill = gravite_max)) + geom_col() +
      scale_fill_manual(values = palette_grav) +
      scale_x_continuous(breaks = seq(0, 23, 2)) +
      scale_y_continuous(labels = scales::label_number(big.mark = " ")) +
      labs(x = "Heure", y = NULL, fill = "Gravite") + theme_minimal(base_size = 11)
  })

  output$p_joursem <- renderPlot({
    acc_f() |>
      mutate(j = lubridate::wday(date, label = TRUE, abbr = TRUE)) |>
      filter(!is.na(j)) |> count(j, gravite_max) |>
      ggplot(aes(j, n, fill = gravite_max)) + geom_col() +
      scale_fill_manual(values = palette_grav) +
      labs(x = NULL, y = NULL, fill = "Gravite") + theme_minimal(base_size = 11)
  })

  output$p_mois <- renderPlot({
    acc_f() |> filter(!is.na(mois_lab)) |>
      mutate(mois_lab = factor(mois_lab, levels = mois_dispo)) |>
      count(mois_lab, gravite_max) |>
      ggplot(aes(mois_lab, n, fill = gravite_max)) + geom_col() +
      scale_fill_manual(values = palette_grav) +
      labs(x = NULL, y = NULL, fill = "Gravite") + theme_minimal(base_size = 11)
  })

  # ---- CARTE ----

  output$carte_acc <- leaflet::renderLeaflet({
    df <- acc_f() |>
      filter(!is.na(lat), !is.na(long),
             lat > 41, lat < 51.5, long > -5, long < 10) |>
      head(8000)

    leaflet::leaflet(df) |>
      leaflet::addProviderTiles("CartoDB.Positron") |> leaflet::setView(lng=2.3, lat=46.5, zoom=6) |>
      leaflet::addCircleMarkers(
        lng = ~long, lat = ~lat, radius = 4,
        color = ~pal_leaflet(gravite_max),
        stroke = FALSE, fillOpacity = .65,
        popup = ~paste0(
          "<b>", gravite_max, "</b><br>",
          date, " a ", hrmn, "<br>",
          catr_lib, "<br>", atm_lib
        )
      ) |>
      leaflet::addLegend("bottomright",
                         pal    = pal_leaflet,
                         values = ~gravite_max,
                         title  = "Gravite")
  })

  # ---- FACTEURS DE RISQUE ----

  output$p_route <- renderPlot({
    acc_f() |> filter(!is.na(catr_lib), catr_lib != "Inconnu") |>
      group_by(catr_lib) |>
      summarise(taux = mean(gravite_max == "Mortel") * 100, n = n(), .groups = "drop") |>
      filter(n > 50) |>
      ggplot(aes(reorder(catr_lib, taux), taux)) +
      geom_col(fill = "#A32D2D", alpha = .85) +
      geom_text(aes(label = paste0(round(taux, 1), "%")), hjust = -.1, size = 3.5) +
      coord_flip() + scale_y_continuous(limits = c(0, 25)) +
      labs(x = NULL, y = "Taux (%)") + theme_minimal(base_size = 11)
  })

  output$p_atm <- renderPlot({
    acc_f() |> filter(atm_lib != "Inconnu") |>
      group_by(atm_lib) |>
      summarise(taux = mean(gravite_max == "Mortel") * 100, n = n(), .groups = "drop") |>
      filter(n > 50) |>
      ggplot(aes(reorder(atm_lib, taux), taux)) +
      geom_col(fill = "#185FA5", alpha = .8) +
      geom_text(aes(label = paste0(round(taux, 1), "%")), hjust = -.1, size = 3.5) +
      coord_flip() +
      labs(x = NULL, y = "Taux (%)") + theme_minimal(base_size = 11)
  })

  output$p_surf <- renderPlot({
    acc_f() |> filter(!is.na(surf_lib), surf_lib != "Inconnu") |>
      count(surf_lib, gravite_max) |>
      ggplot(aes(reorder(surf_lib, n), n, fill = gravite_max)) +
      geom_col(position = "fill") +
      scale_fill_manual(values = palette_grav) +
      scale_y_continuous(labels = scales::label_percent()) +
      coord_flip() + labs(x = NULL, y = "Proportion", fill = NULL) +
      theme_minimal(base_size = 11)
  })

  output$p_lum <- renderPlot({
    acc_f() |> filter(!is.na(lum_lib), lum_lib != "Inconnu") |>
      count(lum_lib, gravite_max) |>
      ggplot(aes(reorder(lum_lib, n), n, fill = gravite_max)) +
      geom_col(position = "fill") +
      scale_fill_manual(values = palette_grav) +
      scale_y_continuous(labels = scales::label_percent()) +
      coord_flip() + labs(x = NULL, y = "Proportion", fill = NULL) +
      theme_minimal(base_size = 11)
  })

  # ---- PROFIL VICTIMES ----

  output$p_age_sexe <- renderPlot({
    usagers_clean |>
      filter(grav == 2, tranche_age != "Inconnu", sexe_lib != "Inconnu") |>
      mutate(tranche_age = factor(tranche_age, levels = c(
        "Moins de 18 ans", "18-24 ans", "25-34 ans",
        "35-44 ans", "45-64 ans", "65 ans et plus"
      ))) |>
      count(tranche_age, sexe_lib) |>
      ggplot(aes(tranche_age, n, fill = sexe_lib)) +
      geom_col(position = "dodge") +
      scale_fill_manual(values = c("Masculin" = "#185FA5", "Feminin" = "#D4537E")) +
      labs(x = NULL, y = "Tues", fill = "Sexe") +
      theme_minimal(base_size = 11) +
      theme(axis.text.x = element_text(angle = 30, hjust = 1))
  })

  output$p_usager <- renderPlot({
    usagers_clean |> filter(grav == 2) |>
      count(catu_lib) |> mutate(pct = n / sum(n) * 100) |>
      ggplot(aes(reorder(catu_lib, n), n, fill = catu_lib)) +
      geom_col(show.legend = FALSE) +
      geom_text(aes(label = paste0(n, " (", round(pct, 0), "%)")),
                hjust = -.1, size = 3.5) +
      coord_flip() +
      scale_fill_manual(values = c(
        "Conducteur" = "#185FA5", "Passager" = "#5DCAA5",
        "Pieton"     = "#EF9F27", "Autre"    = "#888780"
      )) +
      scale_y_continuous(limits = c(0,
        max(usagers_clean |> filter(grav == 2) |> count(catu_lib) |> pull(n)) * 1.3
      )) +
      labs(x = NULL, y = "Tues") + theme_minimal(base_size = 11)
  })

  output$table_mortels <- DT::renderDT({
    acc_f() |> filter(gravite_max == "Mortel") |>
      select(Num_Acc, date, hrmn, dep, catr_lib, atm_lib, lum_lib, nb_tues, nb_blesses_hosp) |>
      DT::datatable(options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
}
