library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(leaflet)
library(DT)
library(scales)

chemin_proc <- "C:/Users/habib/Desktop/BAAC/processed"

accidents     <- readRDS(file.path(chemin_proc, "accidents_clean.rds"))
usagers_clean <- readRDS(file.path(chemin_proc, "usagers_clean.rds"))

accidents <- accidents |>
  mutate(
    mois_lab    = as.character(mois_lab),
    gravite_max = case_when(
      gravite_max == "L\u00e9ger"    ~ "Leger",
      gravite_max == "Mat\u00e9riel" ~ "Materiel",
      TRUE                           ~ gravite_max
    )
  )

palette_grav <- c(
  "Mortel"   = "#A32D2D",
  "Grave"    = "#E24B4A",
  "Leger"    = "#EF9F27",
  "Materiel" = "#888780"
)

pal_leaflet  <- colorFactor(palette_grav, levels = names(palette_grav))
gravites     <- c("Mortel", "Grave", "Leger", "Materiel")
types_routes <- sort(unique(na.omit(accidents$catr_lib)))
types_routes <- types_routes[types_routes != "Inconnu"]
ordre_mois   <- c("janv","fevr","mars","avr","mai","juin",
                  "juil","aout","sept","oct","nov","dec")
mois_dispo   <- ordre_mois[ordre_mois %in% unique(na.omit(accidents$mois_lab))]
