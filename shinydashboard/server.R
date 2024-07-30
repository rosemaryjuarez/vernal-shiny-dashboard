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
                                  "Area: ", Acres, "<br>",
                                  "<a href='#' onclick='Shiny.setInputValue(\"selected_pool\", \"", Pool_ID, "\")'>View Data</a>")
      )
  })
  
  #============== Simple Leaflet Plot for Data END ==================
  
  filtered_pools <- reactive({ ## conditional statemnent for pool area
    if (input$pool_size_select == "All") {
      vernal_polygon
    } else if (input$pool_size_select == "Greater than 1") {
      vernal_polygon %>% filter(Acres > 1)
    } else {
      vernal_polygon %>% filter(Acres <= 1)
    }
  })

  
  
  # Update the pool_id_select choices based on the filtered data
  observe({
    updateSelectizeInput(session, "pool_id_select",
                         choices = unique(filtered_pools()$Pool_ID),
                         selected = character(0))
  })
  
  
  
}

