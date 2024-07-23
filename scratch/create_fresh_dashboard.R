# load libraries ----
library(fresh)

# create theme ----
create_theme(
  
  # change "light-blue"/"primary" color
  adminlte_color(
    light_blue = "#D2D0CA" # dark blue
  ),
  
  # dashboardBody styling (includes boxes)
  adminlte_global(
    content_bg = "#D2D0CA" # blush pink
  ),
  
  # dashboardSidebar styling
  adminlte_sidebar(
    dark_bg = "#D2D0CA", # light blue
    dark_hover_bg = "#364030", # magenta
    dark_color = "#5C4033" # red
  ),
  output_file = "shinydashboard/www/shinydashboard-fresh-theme.css" # generate css file & save to www/
)
