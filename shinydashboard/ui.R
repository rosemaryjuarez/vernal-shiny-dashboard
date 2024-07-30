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
  
  #START  TABS ......................................
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
  
  # START DASHBOARD TAB PAGE--------------------
  tabItem(tabName = "dashboard",
          
          fluidRow( #vernal dashboard button customization
            box(width = 12,
                title = strong("Vernal Pool Interactive Map"),
                fluidRow(
                  column(width = 4,
                         selectizeInput("pool_id_select", "Select Pool ID(s):",
                                        choices = unique(vernal_polygon$Pool_ID),
                                        multiple = TRUE)
                  ),
                  column(width = 4,
                         selectizeInput("location_select", "Select Location(s):",
                                        choices = unique(vernal_polygon$Location),
                                        multiple = TRUE)
                  ),
                  column(width = 4,
                         selectizeInput("pool_size_select", "Select Pool Size(Acres):",
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
  
  
  # START DATAVIZ TAB PAGE 
  tabItem(tabName = "dataviz",
          fluidRow( #dataviz button customization
            box(width = 12,
                title = strong("Vernal Pool Calculations"),
                fluidRow(
                  column(width = 4,
                         selectizeInput("species_select", "Select Species:",
                                        choices = c("species 1", "species 2"),
                                        multiple = TRUE))
                ))
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
