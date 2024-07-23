server <- function(input, output, session) {
  
  # Define the reactive value
  selected_polygon <- reactiveVal(NULL)
  
  #============== Simple Leaflet Plot for Data ==================
  
  
  #------------------
  #       map
  # -----------------
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -119.8489, lat = 34.4140, zoom = 13) %>% 
      addPolygons(data = vernal_polygon,
                  fillColor = "blue",
                  fillOpacity = 0.7,
                  color = "black",
                  weight = 1,
                  layerId = ~Pool_ID,
                  popup = ~paste0("Pool ID: ", Pool_ID, "<br>",
                                  "<a href='#' onclick='Shiny.setInputValue(\"selected_pool\", \"", Pool_ID, "\")'>View Data</a>")
      )
  })
  
  #============== Simple Leaflet Plot for Data END ==================
  
  #------------------
  #       observe event
  # -----------------
  observeEvent(input$selected_pool, {
    selected_data <- vernal_polygon[vernal_polygon$Pool_ID == input$selected_pool, ]
    selected_polygon(selected_data)
    
    # Automatically switch to the dataviz tab
    updateTabItems(session, "sidebarMenu", "dataviz")
  })
  
  
  observeEvent(input$active_tab, {
    updateTabItems(session, "sidebarMenu", input$active_tab)
  })
  
  
  #------------------
  #       graph
  # -----------------
  
  output$graph <- renderPlot({
    req(selected_polygon())
    data <- selected_polygon()
    
    ggplot(data, aes(x = Location, y = Acres)) +
      geom_point() +
      theme_minimal() +
      ggtitle(paste("Data for Pool ID:", data$Pool_ID))
  })
  
  
  
}

