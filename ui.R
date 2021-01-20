library(DT)
library(shiny)
library(shinymaterial)
library(zoo)
library(reshape2)
library(tidyverse)
library(networkD3)

source("functions/functions.R")

material_page(
  title = "Magnolia",
  material_parallax("magnolia.jpg"),

  material_tabs(
    tabs = c(
      "Geral" = "general_tab",
      "Por Cena" = "by_scene_tab"
    )
  ),
  material_tab_content(
    tab_id = "general_tab",
    material_row(
      material_column(
        width = 2,
        material_card(
          material_radio_button(
            "importance",
            "Selecione os personagens:",
            choices = list(
              "Principais" = 1,
              "+ Secundários" = 2,
              "+ Terciários" = 3,
              "+ Quaternários" = 4
            ),
            selected = list("Principais" = 1)
          )
        )
      ),
      material_column(
        width = 10,
        material_card(
          title = "Rede de Personagens",
          simpleNetworkOutput("network_complete")
        )
      )
    )
  ),
  material_tab_content(
    tab_id = "by_scene_tab",
    material_row(
      material_column(
        material_card(
          title = "Roteiro",
          DT::dataTableOutput("script_by_scene")
        )
      ),
      material_column(
        material_card(
          title = "Rede",
          simpleNetworkOutput("network_by_scene")
        )
      )
    ),
    material_row(
      material_column(width = 2),
      material_column(
        width = 8,
        material_card(
          title = "Selecione a Cena:",
          material_slider("scene",
            "",
            min = 1,
            max = 323,
            initial_value = 1
          )
        )
      ),
      material_column(width = 2)
    )
  )
)
