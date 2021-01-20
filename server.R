preprocess_movie_data()
mult <- load_scene_matrix()
net_by_scene <- get_network(mult)
net_cum_by_scene <- get_cum_network(mult)

shinyServer(function(input, output) {
  output$network_complete <- renderSimpleNetwork({
    imp <- input$importance
    print(imp)
    net_cum_by_scene %>%
      filter(imp.x %in% 1:imp, imp.y %in% 1:imp) %>%
      simpleNetwork(
        fontSize = 12, linkDistance = 325, zoom = TRUE,
        linkColour = "#e62294", nodeColour = "#262875", opacity = 0.8,
        fontFamily = "Roboto"
      )
  })

  output$network_by_scene <- renderSimpleNetwork({
    simpleNetwork(net_by_scene[[input$scene]],
      fontSize = 20,
      linkDistance = 200,
      linkColour = "#e62294", nodeColour = "#262875", opacity = 0.8,
      fontFamily = "Roboto"
    )
  })

  output$script_by_scene <- DT::renderDataTable({
    DT::datatable(get_scene_script(input$scene),
      rownames = FALSE, colnames = NULL, options = list(
        dom = "t",
        paging = FALSE
      )
    )
  })
})
