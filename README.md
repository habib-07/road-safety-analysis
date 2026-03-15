# 🚗 Analyse de la Sécurité Routière — BAAC 2024

Dashboard interactif d'analyse des accidents corporels de la circulation en France,
développé en R à partir de la base de données BAAC 2024 (Bulletin d'Analyse 
des Accidents Corporels).

## 🎯 Objectifs

- Visualiser la distribution spatiale et temporelle des accidents
- Identifier les facteurs de risque (météo, type de route, luminosité)
- Analyser le profil des victimes (âge, sexe, catégorie d'usager)
- Produire des indicateurs clés : taux de mortalité, accidents par gravité

## 📊 Dashboard Shiny

4 onglets interactifs avec filtres dynamiques (gravité, type de route, mois) :

- **Vue d ensemble** — KPIs, répartition par gravité, distribution horaire, saisonnalité
- **Carte interactive** — Géolocalisation des accidents sur la France entière
- **Facteurs de risque** — Taux de mortalité par type de route, météo, chaussée, luminosité
- **Profil des victimes** — Tués par âge et sexe, catégorie d usager, tableau détaillé

## 🛠️ Stack technique

- **R** : tidyverse, lubridate, leaflet, shiny, shinydashboard, shinyWidgets, DT, scales
- **Données** : BAAC 2024 — Ministère de l Intérieur / data.gouv.fr
- **Visualisation** : ggplot2, leaflet

## 📦 Structure du projet

road-safety-analysis/
├── global.R      # Chargement des données et packages
├── ui.R          # Interface utilisateur du dashboard
└── server.R      # Logique serveur et graphiques

## 📥 Données sources

Télécharger les 4 fichiers CSV sur data.gouv.fr :
https://www.data.gouv.fr/fr/datasets/53698f4ca3a729239d2036df/

Placer dans un dossier local et mettre à jour chemin_proc dans global.R

## 🚀 Lancer le dashboard

library(shiny)
runApp("chemin/vers/le/dossier")

## 👤 Auteur

Habib Laskin KPENGOU — Data Analyst, données territoriales
DRIEAT Île-de-France
linkedin.com/in/kpengou-habib-laskin-4b772a201
