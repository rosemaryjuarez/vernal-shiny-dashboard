#================================================================
#                      DashboardHeader
#================================================================

# Header
header <- dashboardHeader(
  title = "SB 2019 Vernal Pool Monitoring",
  titleWidth = 420
)


#================================================================
#                        DashboardSidebar
#================================================================
#   Changing the sidebar options and adding Tabs within the main Dashboard Sidebar

# Sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Welcome", tabName = "welcome", icon = icon("star")),
    menuItem("Dashboard", tabName = "dashboard", icon = icon("gauge")),
    menuItem("Data Visualization", tabName = "dataviz", icon = icon("chart-line"))
  )
)

#================================================================
#                        DashboardBody
#================================================================
#   Changing the elements withing each Tab created from the sidebar

# Body
body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sass-styles.css"),
    tags$script(src = "https://kit.fontawesome.com/b7f4c476ba.js")
  ),
  
  #                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  #                            WELCOME TAB
  #                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  tabItems(
    tabItem("welcome",
            fluidRow(
              box(width = 12,
                  title = tagList(icon("tint"), strong("Santa Barbara 2019 Vernal Pool Monitoring Dashboard")),
                  tags$img(src = "venal-pic-ex.jpg", height = "75%", width = "75%", align = "center",
                           style = "max-width:80%; text-align: center; display: block; margin: auto;"),
                  includeMarkdown("text/welcome.md")
              ),
              box(width = 12,
                  title = tagList(icon("tint"), strong("Background on Vernal Pools")),
                  tags$img(src = "Vernal_pool_cross_section_diagram.jpg", height = "75%", width = "75%", align = "center",
                           style = "max-width:80%; text-align: center; display: block; margin: auto;"),
                  includeMarkdown("text/usage.md")
              ),
              box(width = 12,
                  title = tagList(icon("tint"), strong("Data")),
                  tags$img(height = "75%", width = "75%", align = "center",
                           style = "max-width:80%; text-align: center; display: block; margin: auto;"),
                  includeMarkdown("text/data.md") # https://www.google.com/url?sa=i&url=https%3A%2F%2Fohv.parks.ca.gov%2F%3Fpage_id%3D27452&psig=AOvVaw3ugCtlsqzW8-tq6YoaF3RC&ust=1724806019834000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCNikqaX5k4gDFQAAAAAdAAAAABAE
              )
            )
    ),
    
  
    #                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    #                            DASHBOARD TAB
    #                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 
  tabItem(tabName = "dashboard",
          fluidRow(
            box(width = 12,
                title = strong("How to Use the Mapping Dashboard"),
                includeMarkdown("text/how-to-map.md")
            )
          ),
          fluidRow(
            box(width = 12,
                title = strong("Vernal Pool Interactive Map"),
                fluidRow(
                  column(width = 4,
                         selectizeInput("location_pool_id_select", "Select Location-Pool ID(s):",
                                        choices = unique(vernal_polygon_abiotic$location_pool_id),
                                        multiple = TRUE
                         )
                  ),
                  column(width = 3,
                         selectInput("location_pool_size_select", "Select Pool Size (Area):",
                                     choices = c("All", jenks_labels),
                                     selected = "All"
                         )
                  ),
                  column(width = 2,
                         selectizeInput("month_select", "Select Month(s):",
                                        choices = unique(vernal_polygon_abiotic$month),
                                        multiple = TRUE,
                                        width = "100%"
                         )
                  ),
                  column(width = 3,
                         selectizeInput("year_select", "Select Year(s):",
                                        choices = unique(vernal_polygon_abiotic$year), 
                                        multiple = TRUE,
                                        width = "100%"
                         )
                  )
                )
            )
          ),
         
          fluidRow( #leaflet map output
            box(width = 12,
              (leafletOutput("map"))
              )
            ) 
          
          
          ), 
  
  
  #                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  #                            DATAVIZ TAB
  #                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    tabItem("dataviz",
      fluidRow(
        box(width = 12,
          title = strong("How to Use the Data Visualization Tab"),
          includeMarkdown("text/how-to-data-viz.md")
        )
      ),
      fluidRow(
        box(width = 12,
          title = strong("Vernal Pool Data Visualization"),
          fluidRow(
            column(width = 3,
              selectizeInput("viz_location_pool_id", "Select Location-Pool ID:",
                             choices = unique(c(hydro$location_pool_id, percent_cover$location_pool_id)),
                             multiple = FALSE)
            ),
            column(width = 3,
                   selectizeInput("viz_plot_type", "Select Plot Type:",
                                  choices = c("Water Level", "Species Abundance", "Native Cover", "Non-Native Cover", "Species Cover"),
                                  multiple = FALSE)
            ),
            column(width = 3,
              selectizeInput("viz_water_year", "Select Water Year:",
                             choices = unique(hydro$water_year),
                             multiple = FALSE)
            ),
            column(width = 3,
              selectizeInput("viz_species", "Select Species:",
                             choices = unique(percent_cover$species),
                             multiple = FALSE)
            )
          )
        )
      ),
      fluidRow(
        box(width = 12,
          plotlyOutput("viz_plot")
        )
      )
    )
  )
)

#================================================================
#                        Dashboard Page
#================================================================
#   Combines the elements above to create the dashboard
dashboardPage(header, sidebar, body,
              fresh::use_theme("shinydashboard-fresh-theme.css"))
