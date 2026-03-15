ui <- dashboardPage(
  skin = "red",

  dashboardHeader(title = "Accidentologie 2024"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Vue d ensemble",     tabName = "overview", icon = icon("chart-bar")),
      menuItem("Carte interactive",  tabName = "carte",    icon = icon("map")),
      menuItem("Facteurs de risque", tabName = "risques",  icon = icon("exclamation-triangle")),
      menuItem("Profil victimes",    tabName = "victimes", icon = icon("user"))
    ),
    hr(),
    pickerInput("filtre_gravite", "Gravite",
      choices  = gravites,
      selected = gravites,
      multiple = TRUE,
      options  = list(`actions-box` = TRUE)
    ),
    pickerInput("filtre_route", "Type de route",
      choices  = types_routes,
      selected = types_routes,
      multiple = TRUE,
      options  = list(`actions-box` = TRUE)
    ),
    pickerInput("filtre_mois", "Mois",
      choices  = mois_dispo,
      selected = mois_dispo,
      multiple = TRUE,
      options  = list(`actions-box` = TRUE)
    )
  ),

  dashboardBody(
    tabItems(

      tabItem("overview",
        fluidRow(
          valueBoxOutput("vbox_total",   width = 3),
          valueBoxOutput("vbox_mortels", width = 3),
          valueBoxOutput("vbox_graves",  width = 3),
          valueBoxOutput("vbox_taux",    width = 3)
        ),
        fluidRow(
          box(title = "Repartition par gravite", width = 4, plotOutput("p_grav",    height = 280)),
          box(title = "Distribution horaire",    width = 8, plotOutput("p_horaire", height = 280))
        ),
        fluidRow(
          box(title = "Par jour de la semaine", width = 6, plotOutput("p_joursem", height = 260)),
          box(title = "Par mois",               width = 6, plotOutput("p_mois",    height = 260))
        )
      ),

      tabItem("carte",
        fluidRow(
          box(width = 12,
              leaflet::leafletOutput("carte_acc", height = "540px"))
        )
      ),

      tabItem("risques",
        fluidRow(
          box(title = "Mortalite par type de route", width = 6, plotOutput("p_route", height = 300)),
          box(title = "Mortalite par meteo",         width = 6, plotOutput("p_atm",   height = 300))
        ),
        fluidRow(
          box(title = "Etat de la chaussee", width = 6, plotOutput("p_surf", height = 300)),
          box(title = "Luminosite",          width = 6, plotOutput("p_lum",  height = 300))
        )
      ),

      tabItem("victimes",
        fluidRow(
          box(title = "Tues par age et sexe",    width = 8, plotOutput("p_age_sexe", height = 320)),
          box(title = "Categorie d usager",      width = 4, plotOutput("p_usager",   height = 320))
        ),
        fluidRow(
          box(title = "Detail accidents mortels", width = 12, DT::DTOutput("table_mortels"))
        )
      )
    )
  )
)
