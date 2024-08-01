#================================================================
#                      DashboardHeader
#================================================================
#  Everything to do with the Title of the project
          

#Start DashboardHeader :::::::::::::::::::::::::::::::::::::::::
header <- dashboardHeader(
  
  title = "SB 2019 Vernal Pool Monitoring", #title
  titleWidth = 420
  
)#end DashboardHeader :::::::::::::::::::::::::::::::::::::::::

#================================================================
#                        DashboardSidebar
#================================================================
#   Changing the sidebar options and adding Tabs within the main Dashboard Sidebar


sidebar <- dashboardSidebar(# START dashboardSidebar ::::::::::::
  
  sidebarMenu(  
    
    #we will include two tab names in out sidebar:
    #   Welcome 
    #   Dashboard
    
    menuItem(text = "Welcome", tabName = "welcome", icon = icon("star")), #Welcome Tab
    menuItem(text = "Dashboard", tabName = "dashboard", icon = icon("gauge")), # Dashboard Tab
    menuItem(text = "Data Visualization", tabName = "dataviz", icon = icon("chart-line"))
  )
  
) #END dashboardSidebar :::::::::::::::::::::::::::::::::::::::::

#================================================================
#                        DashboardBody
#================================================================
#   Changing the elements withing each Tab created from the sidebar



body <- dashboardBody(
  # START DASHBOARD BODY::::::::::::::::::::::::
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "sass-styles.css"),
    tags$script(src = "https://kit.fontawesome.com/b7f4c476ba.js")),
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  #                                 WELCOME TAB
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  tabItems(
    tabItem( tabName = "welcome",
             fluidRow(
             box(width = 12,
                 title = tagList(icon("tint"), 
                                 strong("Santa Barbara 2019 Vernal Pool Monitoring Dashboard")),
                 tags$img(src ="venal-pic-ex.jpg",
                          height="75%",
                          width="75%",
                          align="center",
                          style  = "max-width:80%; text-align: center;display: block; margin-left: auto; margin-right: auto;"),
                 includeMarkdown("text/welcome.md")),
             box(width = 12,
                 title = tagList(icon("tint"), 
                                 strong("Dashboard Usage")),
                 tags$img(src ="shinydashboard/www/vernal-draft-map.jpg",
                          height="75%",
                          width="75%",
                          align="center",
                          style  = "max-width:80%; text-align: center;display: block; margin-left: auto; margin-right: auto;"),
                 includeMarkdown("text/usage.md"))
             )
    ),
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  #                                 MAP DASHBOARD TAB
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  
  tabItem(tabName = "dashboard",
          
          fluidRow( #vernal dashboard button customization
            box(width = 12,
                title = strong("Vernal Pool Interactive Map"),
                fluidRow(
                  column(width = 4,
                         selectizeInput("location_pool_id_select", "Select Location-Pool ID(s):",
                                        choices = unique(vernal_polygon_abiotic$location_pool_id),
                                        multiple = TRUE)
                  ),
                  column(width = 4,
                         selectizeInput("location_pool_size_select", "Select Location-Pool Size(Acres):",
                                        choices = c("All", "Greater than 1", "Less than or equal to 1"),
                                        selected = "All")
                  )
                ),
                fluidRow(
                  column(width = 6,
                         selectizeInput("month_select", "Select Month(s):",
                                        choices = month.name,  # grabs month names
                                        multiple = TRUE)
                  ),
                  column(width = 6,
                         selectizeInput("year_select", "Select Year(s):",
                                        choices = 2019:2020,  # just these two years
                                        multiple = TRUE)
                  )
                )
            )
          ),
         
          fluidRow( #leaflet map output
            box(width = 12,
              (leafletOutput("map"))
              )
            ) # end dashboard fluidrow
          
          
          ), # END DASHBOARD TAB PAGE------------
  
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  #                                 DATAVIZ TAB
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  tabItem(tabName = "dataviz",
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
                         selectizeInput("viz_water_year", "Select Water Year:",
                                        choices = unique(hydro$water_year),
                                        multiple = FALSE)
                  ),
                  column(width = 3,
                         selectizeInput("viz_species", "Select Species:",
                                        choices = unique(percent_cover$species),
                                        multiple = FALSE)
                  ),
                  column(width = 3,
                         selectizeInput("viz_plot_type", "Select Plot Type:",
                                        choices = c("Water Level", "Species Abundance", "Native Cover", "Non-Native Cover", "Species Cover"),
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
  
  ) #END DASHBOARD TABS .......................................
  

)#END DASHBOARD BODY :::::::::::::::::::::::::::::::::::::::::

#================================================================
#                        Dashboard Page
#================================================================
#   Combines the elements above to create the dashboard
dashboardPage(header, sidebar, body,
              fresh::use_theme("shinydashboard-fresh-theme.css"))
