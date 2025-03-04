#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(gt)
library(bslib)
library(thematic)
#library(shinyWidgets)


# set themes

light <- bs_theme(preset = "simplex", bg = "white", fg = "#7a0019",
                   )
dark <- bs_theme(bg = "black", fg = "#ffcc33", primary = "#7a0019")

# Define UI for application that draws a histogram
ui <- page_sidebar(
  title = "Convert .csv culture results to allow DC305 import of culture results",
  sidebar = sidebar(
    fileInput(
      inputId = "upload",
      label = "Upload a .csv file with no collumn headings (Accepts .csv files only)",
      # Specify the file type(s) that can be uploaded (does not guarantee a csv)
      accept = ".csv"
    ),
    textInput("herd", "Enter HerdCode (Usually 8 numbers)", c("HerdCode")
    # selectInput(
    #   "herd", "Select Herd",
    #   choices = c("41464500", "41230523")
    ),
    downloadButton("downloadData", "Download HerdCode.DNQ"),
    br(),
    br(),
    checkboxInput("dark_mode", "Dark mode", value = FALSE)
  ),
  layout_columns(page_fluid(
      card("File Contents",
      tableOutput("table")
      ),
      row_heights = c(1)
      )),
  #shinyWidgets::setBackgroundImage(src = "b_clean_labelled.jpg")
  img(src = "b_clean_labelled.jpg",
      width = "150px",
      height = "150px",
      style = "position: fixed; bottom: 
      24px; right: 24px; opacity: 0.75; z-index: -1"
      )
  )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # for dark mode
  observe({
    session$setCurrentTheme(
      if (input$dark_mode) {
        dark
      } else {
        light
      }
    )
  })

  d <- reactive({
    req(input$upload) # req() is used to ensure the file is uploaded
    readr::read_csv(input$upload$datapath,
                    col_names = c("date", "id_cow",
                                  "culture_result",
                                  "culture_sample")  
    )
  })

    output$table <- renderTable({
        d() |> gt()
    })
    
    # Downloadable csv of selected dataset ----
    output$downloadData <- downloadHandler(
      filename = function() {
        paste(input$herd,".DNQ", 
              sep = "")
      },
      content = function(file) {
        write_delim(d(), file,
                    delim = " ",
                    col_names = FALSE)
      }
    )
}

# for graphs later
thematic_shiny(font = "auto")
# Run the application 
shinyApp(ui = ui, server = server)
