# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# Source Code File: app.R
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# Program:
# - Visualization Interface for Chesapeake Optimization (VICO)
# R Shiny Source Files:
# - app.R, vicofunc.R, vicotext.R, counties.csv, and hotjar.js
# Data Files (and AWS S3 Access):
# - See VICOBucketName and VICOBucketPathPrefixFront.
# - See aws.s3, aws.ec2metadata, and setenv.
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO - libraries
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
library(shiny)
# library(sm) - remove this library reference if not needed
library(sm) # Smoothing Methods for Nonparametric Regression and Density Estimation
library(aws.s3)
library(aws.ec2metadata)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO - options
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
options(shiny.maxRequestSize = 6*1024^2)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO - setenv
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
Sys.setenv("AWS_DEFAULT_REGION" = "us-east-1")
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO - subprograms
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
source('vicofunc.R')
source('vicotext.R')
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO - initialize here for visibility across all sessions - geo menu
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
GeoMaster <- read.csv(file = "counties.csv", header = FALSE)
GeoMenu <- split(GeoMaster$V1, GeoMaster$V2)
GeoMenu$DC <- NULL
AskClearGeoString <- 'Choose Geography (No Current Selection)'
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO - initialize here for visibility across all sessions - AWS S3 Access
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
VICOBucketName <- "modeling-data.chesapeakebay.net"
VICOBucketPathPrefixFront <- "optimization/vico_beta2-bayota_0.1b2_20191004/"
VICOBucketOK <- (bucket_exists('modeling-data.chesapeakebay.net'))
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
ui <- navbarPage(
  title = "VICO", id="navbar",
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
tabPanel(
  title = "Explore Optimization Results",
  value = "twogeos",
  tags$head(tags$style(
    HTML(
      "
      .shiny-output-error-validation {
      color: maroon;padding: 30px 10px 10px 10px;text-align: center;
      }
      "
    )
    ),
    includeScript(path="hotjar.js")  
    ),
  uiOutput("otaintro"),
  wellPanel(
    style = "margin-bottom: 10px",
    align = "left",
    wellPanel(
      style = "background-color:White;margin: 6px 4px 12px 4px",
      fluidRow(
        tags$div(style = "padding: 0px 10px 10px 10px;text-align: left;",
                 tags$span(
                   style = "color: black;",
                   tags$strong("Step 1: Select One Geography or Two Geographies and Objective")
                 ))
      ),
      fluidRow(column(
        6,
        selectInput("otageo1comp", NULL,
                    choices = c(
                      list("No Selection" = list(AskClearGeoString)), list("DC" = list("Washington, DC")), GeoMenu
                    ))
      ),
      column(
        6,
        selectInput("otageo2comp", NULL,
                    choices = c(
                      list("No Selection" = list(AskClearGeoString)), list("DC" = list("Washington, DC")), GeoMenu
                    ))
      )),
      fluidRow(column(
        12,
        selectInput(
          "otaobjcomp",
          NULL,
          choices = c(
            "Minimize Cost for Target N Load Reduction (1% to 50%)" = "costmin_Nloadredtarget",
            "Minimize Cost for Target P Load Reduction (1% to 50%)" = "costmin_Ploadredtarget",
            "Maximize N Load Reduction for Target Cost ($100K to $5M)" = "Nloadredmax_totalcosttarget",
            "Maximize P Load Reduction for Target Cost ($100K to $5M)" = "Ploadredmax_totalcosttarget"
          )
        )
      ))
    ),
    wellPanel(
      style = "background-color:White;margin: 6px 4px 12px 4px",
      fluidRow(
        tags$div(style = "padding: 0px 10px 10px 10px;text-align: left;",
                 tags$span(
                   style = "color: black;",
                   tags$strong("Step 2: Select One Point or Two Points")
                 ))
      ),
      fluidRow(column(
        6,
        selectInput(
          "pointmode",
          NULL,
          choices = c(
            "One Point of Interest" = "OnePoint",
            "Compare Two Points" = "TwoPoint"
          )
        )
      ),
      uiOutput("clicksetting")),
      fluidRow(
        tags$div(style = "padding: 0px 20px 5px 20px;text-align: left;",
                 plotOutput("otageomainplot", click = "comp_click"))
      )
    ),
    wellPanel(style = "background-color:White;margin: 6px 4px 12px 4px",
              fluidRow(
                tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
                         tags$span(
                           style = "color: black;",
                           tags$strong("Results: BMP Implementation")
                         ))
              ),
              fluidRow(
                tags$div(style = "padding: 0px 20px 5px 20px;text-align: left;",
                         plotOutput("otabarplot", height = "auto"))
              )),
    wellPanel(
      style = "background-color:White;margin: 6px 4px 12px 4px",
      fluidRow(
        tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
                 tags$span(style = "color: black;",
                           tags$strong("Download(s)")))
      ),
      fluidRow(
        tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;font-size: 10px;",
                 tags$span(
                   style = "color: black;",
                   paste0(
                     "Data tables (.txt) of BMP implementation acres for selected point(s), ",
                     "including delineation by land-river segment, load source, and agency."
                   )
                 ))
      ),
      fluidRow(
        tags$div(style = "padding: 8px 10px 15px 20px;text-align: left;",
                 uiOutput("grabfiles")
        )
      )
    )),
    uiOutput("otadisclaim")
  ),
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
tabPanel(title = "About",
         value = "vicoinfo",
         fluidRow(column(
           12,
           wellPanel(
             style = "background-color:AliceBlue;",
             align = "left",
             list(
               abouttop(),
               tags$hr(),
               engineversion(),
               tags$hr(),
               credits(),
               tags$hr(),
               funding()
             )
           )
         )))
)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
server <- function(input, output) {
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - interface booleans
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  gotriangle <-
    reactive ({
      okay <- (input$otageo1comp != AskClearGeoString)
    })
  gocircle <-
    reactive ({
      okay <- (input$otageo2comp != AskClearGeoString)
    })
  doempty <-
    reactive ({
      okay <- ((!VICOBucketOK) | ((!gotriangle()) & (!gocircle())))
    })
  dotriangleonly <-
    reactive ({
      okay <- ((VICOBucketOK) & gotriangle() & (!gocircle()))
    })
  docircleonly <-
    reactive ({
      okay <- ((VICOBucketOK) & gocircle() & (!gotriangle()))
    })
  doboth <-
    reactive ({
      okay <- ((VICOBucketOK) & gotriangle() & gocircle())
    })
  onepointmode <-
    reactive ({
      okay <- (input$pointmode == 'OnePoint')
    })
  twopointmode <-
    reactive ({
      okay <- (input$pointmode == 'TwoPoint')
    })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - no geography selection
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  havegeo1 <- 
    reactive ({ noselection <- gotriangle()
    })
  havegeo2 <- 
    reactive ({ noselection <- gocircle()
    })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - conditional loads
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  stategui <- reactiveValues(
    dataset1 = NULL,
    dataset2 = NULL
  )
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - primary graph
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otageo1code <-
    reactive ({
      geocodeforthat(input$otageo1comp)
    })
  otageo2code <-
    reactive ({
      geocodeforthat(input$otageo2comp)
    })
  otageo1dataset <- reactive({
    stategui$dataset1
  })
  otageo2dataset <- reactive({
    stategui$dataset2
  })
  otageo1feasible <- reactive({
    feasiblepart(otageo1dataset())
  })
  otageo2feasible <- reactive({
    feasiblepart(otageo2dataset())
  })
  otageo1datause <- reactive({
    validate(
    )
    validate(
      need((!is.null(otageo1feasible())), "No plot possible. No feasible data points.")
    ) # handle no rows, as well, as no rows is marked with NULL
    otageo1feasible()
  })
  otageo2datause <- reactive({
    validate(
    )
    validate(
      need((!is.null(otageo2feasible())), "No plot possible. No feasible data points.")
    ) # handle no rows, as well, as no rows is marked with NULL
    otageo2feasible()
  })
  otageo1markset <- reactive({
    if (!is.null(otageo1dataset()))
    {
      markdataset <-
        otageo1dataset()[which(otageo1dataset()$feasible == 'False'), ]
      if (nrow(markdataset) > 0)
      {
        mindisplayvalue <- min(otageo1dataset()$solution_objective)
        markdataset$solution_objective <- mindisplayvalue
      }
      else
        markdataset <- NULL
    }
    else
      markdataset <- NULL
    markdataset
  })
  otageo2markset <- reactive({
    if (!is.null(otageo2dataset()))
    {
      markdataset <-
        otageo2dataset()[which(otageo2dataset()$feasible == 'False'), ]
      if (nrow(markdataset) > 0)
      {
        mindisplayvalue <- min(otageo2dataset()$solution_objective)
        markdataset$solution_objective <- mindisplayvalue
      }
      else
        markdataset <- NULL
    }
    else
      markdataset <- NULL
    markdataset
  })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - some strings/labels
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otaTrianglePlace <-
    reactive ({
      place <- input$otageo1comp
    })
  otaCirclePlace <-
    reactive ({
      place <- input$otageo2comp
    })
  otaMainAxisLabel <-
    reactive ({
      otaobjval = input$otaobjcomp
      if (otaobjval == "costmin_Nloadredtarget")
        objstr = "N Load Reduction Target (%)"
      else
      {
        if (otaobjval == "costmin_Ploadredtarget")
          objstr = "P Load Reduction Target (%)"
        else
        {
          if (otaobjval == "Nloadredmax_totalcosttarget")
            objstr = "Maximized N Load Reduction (%)"
          else # Ploadredmax_totalcosttarget
            objstr = "Maximized P Load Reduction (%)"
        }
      }
      titlestr <- objstr
    })
  otaXAxisLabel <-
    reactive ({
      if (costmincase(input$otaobjcomp))
        objstr = otaMainAxisLabel()
      else
        objstr = "Total Cost ($)"
      titlestr <- objstr
    })
  otaYAxisLabel <-
    reactive ({
      if (costmincase(input$otaobjcomp))
        objstr = "Minimized Cost ($)"
      else
        objstr = otaMainAxisLabel()
      titlestr <- objstr
    })
  otaMainTitle <-
    reactive ({
      otaobjval = input$otaobjcomp
      if (otaobjval == "costmin_Nloadredtarget")
        objstr = "Minimized Cost for Target N Load Reduction (1% to 50%)"
      else
      {
        if (otaobjval == "costmin_Ploadredtarget")
          objstr = "Minimized Cost for Target P Load Reduction (1% to 50%)"
        else
        {
          if (otaobjval == "Nloadredmax_totalcosttarget")
            objstr = "Maximized N Load Reduction for Target Cost ($100K to $5M)"
          else # Ploadredmax_totalcosttarget
            objstr = "Maximized P Load Reduction for Target Cost ($100K to $5M)"
        }
      }
      titlestr <- objstr
    })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - primary graph - point click
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otaclickmode <- reactive({
    if (is.null(input$clickmode))
      mode <- "Nearest"
    else
      mode <- input$clickmode
  })
  gotvals <- reactiveValues(# keeprows = rep(TRUE, nrow(mtcars))
    point1curve = NULL,
    point2curve = NULL,
    point1 = c(NULL, NULL),
    point2 = c(NULL, NULL)
  )
  gottwopoints <- reactive({
    gottwo <- ((!is.null(gotvals$point1curve) & !is.null(gotvals$point2curve)))
  })
  ota1getnear <- reactive({
    if (costmincase(input$otaobjcomp))
      near <- nearPoints(otageo1feasible(), input$comp_click, xvar="percent_reduction_minimum", yvar="solution_objective", threshold = 7000, maxpoints=1)
    else
      near <- nearPoints(otageo1feasible(), input$comp_click, xvar="totalcostupperbound", yvar="solution_objective", threshold = 7000, maxpoints=1)
  })
  ota2getnear <- reactive({
    if (costmincase(input$otaobjcomp))
      near <- nearPoints(otageo2feasible(), input$comp_click, xvar="percent_reduction_minimum", yvar="solution_objective", threshold = 7000, maxpoints=1)
    else
      near <- nearPoints(otageo2feasible(), input$comp_click, xvar="totalcostupperbound", yvar="solution_objective", threshold = 7000, maxpoints=1)
  })
  observeEvent(input$pointmode, {
    gotvals$point1curve = NULL
    gotvals$point2curve = NULL
    gotvals$point1 = c(NULL, NULL)
    gotvals$point2 = c(NULL, NULL)
  }, priority = 7)
  observeEvent(input$otaobjcomp, {
    gotvals$point1curve = NULL
    gotvals$point2curve = NULL
    gotvals$point1 = c(NULL, NULL)
    gotvals$point2 = c(NULL, NULL)
    have <- (input$otageo1comp != AskClearGeoString)
    same <- (input$otageo1comp == input$otageo2comp)
    dataset <- geoloadguts(VICOBucketOK, have, input$otageo1comp, input$otaobjcomp, 
                           VICOBucketName, VICOBucketPathPrefixFront, paste0(otaTrianglePlace(), ":"))
    stategui$dataset1 <- dataset
    justcopy <- have & same
    if (!justcopy)
      dataset <- geoloadguts(VICOBucketOK, have, input$otageo2comp, input$otaobjcomp, 
                             VICOBucketName, VICOBucketPathPrefixFront, paste0(otaCirclePlace(), ":"))
    stategui$dataset2 <- dataset
  }, priority = 7)
  observeEvent(input$otageo1comp, {
    gotvals$point1curve = NULL
    gotvals$point2curve = NULL
    gotvals$point1 = c(NULL, NULL)
    gotvals$point2 = c(NULL, NULL)
    have <- (input$otageo1comp != AskClearGeoString)
    same <- (input$otageo1comp == input$otageo2comp)
    justcopy <- have &  same
    if (justcopy)
      dataset <- stategui$dataset2
    else
      dataset <- geoloadguts(VICOBucketOK, have, input$otageo1comp, input$otaobjcomp, 
                             VICOBucketName, VICOBucketPathPrefixFront, paste0(otaTrianglePlace(), ":"))
    stategui$dataset1 <- dataset
  }, priority = 7)
  observeEvent(input$otageo2comp, {
    gotvals$point1curve = NULL
    gotvals$point2curve = NULL
    gotvals$point1 = c(NULL, NULL)
    gotvals$point2 = c(NULL, NULL)
    have <- (input$otageo2comp != AskClearGeoString)
    same <- (input$otageo2comp == input$otageo1comp)
    justcopy <- have &  same
    if (justcopy)
      dataset <- stategui$dataset1
    else
      dataset <- geoloadguts(VICOBucketOK, have, input$otageo2comp, input$otaobjcomp, 
                             VICOBucketName, VICOBucketPathPrefixFront, paste0(otaCirclePlace(), ":"))
    stategui$dataset2 <- dataset
  }, priority = 7)
  observeEvent(input$comp_click, {
    if (doboth())
      oncompclickboth()
    else
      if (dotriangleonly())
        oncompclicktriangle()
    else
      if (docircleonly())
        oncompclickcircle()
    else
      NULL
  }, priority = 7)
  oncompclickboth <- function() {
    if (costmincase(input$otaobjcomp))
    {
      near1 <-
        c(ota1getnear()$percent_reduction_minimum,
          ota1getnear()$solution_objective)
      near2 <-
        c(ota2getnear()$percent_reduction_minimum,
          ota2getnear()$solution_objective)
    }
    else
    {
      near1 <-
        c(ota1getnear()$totalcostupperbound,
          ota1getnear()$solution_objective)
      near2 <-
        c(ota2getnear()$totalcostupperbound,
          ota2getnear()$solution_objective)
    }
    distance1 <-
      mydistance(input$comp_click$x, near1[1], input$comp_click$y, near1[2])
    distance2 <-
      mydistance(input$comp_click$x, near2[1], input$comp_click$y, near2[2])
    if (is.null(gotvals$point1[1]) | onepointmode())
    {
      if (distance1 <= distance2 & !forcedcircle(otaclickmode()))
      {
        gotvals$point1curve <- 1
        gotvals$point1 <- near1
      }
      else
      {
        gotvals$point1curve <- 2
        gotvals$point1 <- near2
      }
    }
    else
    {
      if (!is.null(gotvals$point2[1]))
      {
        gotvals$point1curve <- gotvals$point2curve 
        gotvals$point1 <- gotvals$point2
      }
      if (distance1 <= distance2 & !forcedcircle(otaclickmode()))
      {
        gotvals$point2curve <- 1
        gotvals$point2 <- near1
      }
      else
      {
        gotvals$point2curve <- 2
        gotvals$point2 <- near2
      }
    }
  }
  oncompclicktriangle <- function() {
    if (costmincase(input$otaobjcomp))
    {
      near1 <-
        c(ota1getnear()$percent_reduction_minimum,
          ota1getnear()$solution_objective)
    }
    else
    {
      near1 <-
        c(ota1getnear()$totalcostupperbound,
          ota1getnear()$solution_objective)
    }
    if (is.null(gotvals$point1[1]) | onepointmode())
    {
      gotvals$point1curve <- 1
      gotvals$point1 <- near1
    }
    else
    {
      if (!is.null(gotvals$point2[1]))
      {
        gotvals$point1curve <- gotvals$point2curve
        gotvals$point1 <- gotvals$point2
      }
      gotvals$point2curve <- 1
      gotvals$point2 <- near1
    }
  }
  oncompclickcircle <- function() {
    if (costmincase(input$otaobjcomp))
    {
      near2 <-
        c(ota2getnear()$percent_reduction_minimum,
          ota2getnear()$solution_objective)
    }
    else
    {
      near2 <-
        c(ota2getnear()$totalcostupperbound,
          ota2getnear()$solution_objective)
    }
    if (is.null(gotvals$point1[1]) | onepointmode())
    {
      gotvals$point1curve <- 2
      gotvals$point1 <- near2
    }
    else
    {
      if (!is.null(gotvals$point2[1]))
      {
        gotvals$point1curve <- gotvals$point2curve
        gotvals$point1 <- gotvals$point2
      }
      gotvals$point2curve <- 2
      gotvals$point2 <- near2
    }
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - money/dollars
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  ota1dollars <- reactive({
    if (costmincase(input$otaobjcomp))
        moneyportion(gotvals$point1[2])
    else
        moneyportion(gotvals$point1[1])
  })
  ota2dollars <- reactive({
    if (costmincase(input$otaobjcomp))
        moneyportion(gotvals$point2[2])
    else
        moneyportion(gotvals$point2[1])
  })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - colors for plots
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otacurve1color <- reactive({
    if (otaclickmode() == "Forced")
      color <- "Gray" # Grey
    else
      color <- "#F5CDAB"
  })
  otacurve1pointcolor <- reactive({
    if (otaclickmode() == "Forced")
      color <- "DarkGray" # Dark Grey
    else
      color <- "#ED7E16"
  })
  otacurve2color <- reactive({
    if (otaclickmode() == "First")
      color <- "Gray" # Grey
    else
      color <- "#9CD9F6"
  })
  otacurve2pointcolor <- reactive({
    if (otaclickmode() == "First")
      color <- "DarkGray" # Dark Grey
    else
      color <- "#2F8DC7"
  })
  otabar1color <- reactive({
    if (!is.null(gotvals$point1curve))
    {
      if (gotvals$point1curve == 1)
        color <- "#ED7E16"
      else
        color <- "#2F8DC7"
    }
    else
      color <- "Gray" # Grey
  })
  otabar2color <- reactive({
    if (gottwopoints())
    {
      if (gotvals$point1curve == 1)
      {
        if (gotvals$point2curve == 2)
          color <- "#2F8DC7"
        else
          color <- "#F5CDAB"
      }
      else
        if (gotvals$point1curve == 2)
        {
          if (gotvals$point2curve == 1)
            color <- "#ED7E16"
          else
            color <- "#9CD9F6"
        }
      else
        color <- "Gray" # Grey
    }
    else
      color <- "Gray" # Grey
  })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - bar graph, etc.
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  ota1bardata <- reactive({
    if (!is.null(gotvals$point1curve))
      {
        if ((!is.null(otageo1feasible()) & (gotvals$point1curve == 1)))
        {
          point1bardata <- load.otabardata(otageo1dataset(),
                                           input$otaobjcomp,
                                           gotvals$point1[1],
                                           VICOBucketName)
          names(point1bardata)[2] <- "point1acres"
          names(point1bardata)[3] <- "point1annualcostperunit"
          point1bardata
        }
        else
        {
          if ((!is.null(otageo2feasible()) & (gotvals$point1curve == 2)))
          {
            point1bardata <- load.otabardata(otageo2dataset(),
                                             input$otaobjcomp,
                                             gotvals$point1[1],
                                             VICOBucketName)
            names(point1bardata)[2] <- "point1acres"
            names(point1bardata)[3] <- "point1annualcostperunit"
            point1bardata
          }
          else
            NULL
        }
    }
    else
      NULL
  })
  ota2bardata <- reactive({
    if (gottwopoints())
    {
      if (!samepoint(
        gotvals$point1curve,
        gotvals$point2curve,
        gotvals$point1[1],
        gotvals$point2[1],
        gotvals$point1[2],
        gotvals$point2[2]
      ))
      {
        if ((!is.null(otageo1feasible()) & (gotvals$point2curve == 1)))
        {
          point2bardata <- load.otabardata(otageo1dataset(),
                                           input$otaobjcomp,
                                           gotvals$point2[1],
                                           VICOBucketName)
          names(point2bardata)[2] <- "point2acres"
          names(point2bardata)[3] <- "point2annualcostperunit"
          point2bardata
        }
        else
        {
          if ((!is.null(otageo2feasible()) & (gotvals$point2curve == 2)))
          {
            point2bardata <- load.otabardata(otageo2dataset(),
                                             input$otaobjcomp,
                                             gotvals$point2[1],
                                             VICOBucketName)
            names(point2bardata)[2] <- "point2acres"
            names(point2bardata)[3] <- "point2annualcostperunit"
            point2bardata
          }
          else
            NULL
        }
      }
      else
        NULL
    }
    else
      NULL
  })
  otacompbardata <- reactive({
    if (!is.null(ota1bardata()) &
        !is.null(ota2bardata()))
    {
      otagroupedbardata <- merge(x = ota1bardata(),
                          y = ota2bardata(),
                          by = "bmpfullname",
                          all = TRUE) # sort = TRUE
      otagroupedbardata[is.na(otagroupedbardata$point1acres), "point1acres"] <- 0
      otagroupedbardata[is.na(otagroupedbardata$point2acres), "point2acres"] <- 0
      otagroupedbardata[is.na(otagroupedbardata$point1annualcostperunit), "point1annualcostperunit"] <- otagroupedbardata[is.na(otagroupedbardata$point1annualcostperunit), "point2annualcostperunit"]
      otagroupedbardata[is.na(otagroupedbardata$point2annualcostperunit), "point2annualcostperunit"] <- otagroupedbardata[is.na(otagroupedbardata$point2annualcostperunit), "point1annualcostperunit"]
      otagroupedbardata
    }
    else
      NULL
  })
  ota1barrows <- reactive({
    if (!is.null(ota1bardata()))
      nrow(ota1bardata())
    else # set to zero or one for bar plot space calculation
      0
  })
  otacompbarrows <- reactive({
    if (!is.null(otacompbardata()))
      nrow(otacompbardata())
    else # set to zero or one for bar plot space calculation
      0
  })
  otabarheight <- reactive({
    if (twopointmode() & gottwopoints())
    {
      howmany <- 2*otacompbarrows()
      if (howmany < 4)
        howmany <- 4
    }
    else
      if (onepointmode() & !is.null(gotvals$point1curve))
      {
        howmany <- ota1barrows()
        if (howmany < 4)
          howmany <- 4
      }
    else
      howmany <- 3
    if (howmany >= 0)
      howtall <- 120+24*howmany
    else
      howtall <- 10
    howtall
  })
  otaShowCompBarPlot <- reactive({
    if (gottwopoints() &
        !samepoint(
          gotvals$point1curve,
          gotvals$point2curve,
          gotvals$point1[1],
          gotvals$point2[1],
          gotvals$point1[2],
          gotvals$point2[2]))
    {
      if (!is.null(otacompbardata()))
        showit <- TRUE
      else
        showit <- FALSE
    }
    else
      showit <- FALSE
    showit
  })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - load change
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  ota1loaddiff <- reactive({
    if (!is.null(gotvals$point1curve))
    {
      if (!is.null(otageo1feasible()) & (gotvals$point1curve == 1))
      {
        if (costmincase(input$otaobjcomp))
          zoomin <-
            otageo1feasible()[which(otageo1feasible()$percent_reduction_minimum == gotvals$point1[1]), ]
        else
          zoomin <-
            otageo1feasible()[which(otageo1feasible()$totalcostupperbound == gotvals$point1[1]), ]
        if (nitrogencase(input$otaobjcomp))
          loaddiff <- zoomin$original_load_N - zoomin$new_load_N
        else
          loaddiff <- zoomin$original_load_P - zoomin$new_load_P
      }
      else
        if (!is.null(otageo2feasible()) & (gotvals$point1curve == 2))
        {
          if (costmincase(input$otaobjcomp))
            zoomin <-
              otageo2feasible()[which(otageo2feasible()$percent_reduction_minimum == gotvals$point1[1]), ]
          else
            zoomin <-
              otageo2feasible()[which(otageo2feasible()$totalcostupperbound == gotvals$point1[1]), ]
          if (nitrogencase(input$otaobjcomp))
            loaddiff <- zoomin$original_load_N - zoomin$new_load_N
          else
            loaddiff <- zoomin$original_load_P - zoomin$new_load_P
        }
      else
        loaddiff <- 0.0
    }
    else
      loaddiff <- 0.0
    loaddiff
  })
  ota2loaddiff <- reactive({
    if (!is.null(gotvals$point2curve))
    {
      if (!is.null(otageo1feasible()) & (gotvals$point2curve == 1))
      {
        if (costmincase(input$otaobjcomp))
          zoomin <-
            otageo1feasible()[which(otageo1feasible()$percent_reduction_minimum == gotvals$point2[1]), ]
        else
          zoomin <-
            otageo1feasible()[which(otageo1feasible()$totalcostupperbound == gotvals$point2[1]), ]
        if (nitrogencase(input$otaobjcomp))
          loaddiff <- zoomin$original_load_N - zoomin$new_load_N
        else
          loaddiff <- zoomin$original_load_P - zoomin$new_load_P
      }
      else
        if (!is.null(otageo2feasible()) & (gotvals$point2curve == 2))
        {
          if (costmincase(input$otaobjcomp))
            zoomin <-
              otageo2feasible()[which(otageo2feasible()$percent_reduction_minimum == gotvals$point2[1]), ]
          else
            zoomin <-
              otageo2feasible()[which(otageo2feasible()$totalcostupperbound == gotvals$point2[1]), ]
          if (nitrogencase(input$otaobjcomp))
            loaddiff <- zoomin$original_load_N - zoomin$new_load_N
          else
            loaddiff <- zoomin$original_load_P - zoomin$new_load_P
        }
      else
        loaddiff <- 0.0
    }
    else
      loaddiff <- 0.0
    loaddiff
  })
  ota1lb <- reactive({lbportion(ota1loaddiff())})
  ota2lb <- reactive({lbportion(ota2loaddiff())})
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Reactive Objects and Data Structures - more strings/labels
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otaBar1Place <-
    reactive ({
      if (twopointmode() & gottwopoints())
        bar1place <-
          pointplace(gotvals$point1curve, otaTrianglePlace(), otaCirclePlace())
      else
        if (onepointmode() & !is.null(gotvals$point1curve))
          bar1place <-
            pointplace(gotvals$point1curve, otaTrianglePlace(), otaCirclePlace())
        else
          bar1place <- ""
    })
  otaBar2Place <-
    reactive ({
      if (twopointmode() & gottwopoints())
        bar2place <-
          pointplace(gotvals$point2curve, otaTrianglePlace(), otaCirclePlace())
      else
        bar2place <- ""
    })
  otaBarLegend1Other <-
    reactive ({
      legendother(input$otaobjcomp,
                  gotvals$point1[1],
                  gotvals$point1[2],
                  ota1lb(),
                  ota1dollars())
    })
  otaBarLegend2Other <-
    reactive ({
      legendother(input$otaobjcomp,
                  gotvals$point2[1],
                  gotvals$point2[2],
                  ota2lb(),
                  ota2dollars())
    })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Miscellaneous - Download Handling
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  output$csvdownloadData1 <- downloadHandler(
    filename = function() {
      paste("download1", ".csv", sep = "")
    },
    content = function(file) {
      point1filedata <- load.otadownloaddata(otageo1dataset(), input$otaobjcomp, gotvals$point1[1], VICOBucketName)
      write.csv(point1filedata, file, row.names = FALSE)
    })  
  output$csvdownloadData2 <- downloadHandler(
    filename = function() {
      paste("download2", ".csv", sep = "")
    },
    content = function(file) {
      point2filedata <- load.otadownloaddata(otageo2dataset(), input$otaobjcomp, gotvals$point2[1], VICOBucketName)
      write.csv(point2filedata, file, row.names = FALSE)
    })  
  output$downloadData1 <- downloadHandler(
    filename = function() {
      if (gotvals$point1curve == 1)
        placepart <- otageo1code()
      else
        placepart <- otageo2code()
      paste("VICObeta2_results_point1_", placepart, ".txt", sep = "")
    },
    content = function(file) {
      if (gotvals$point1curve == 1)
        point1filedata <- load.otadownloadtxtdata(otageo1dataset(), input$otaobjcomp, gotvals$point1[1], VICOBucketName)
      else
        point1filedata <- load.otadownloadtxtdata(otageo2dataset(), input$otaobjcomp, gotvals$point1[1], VICOBucketName)
      writeLines(point1filedata, file, sep = "\r\n")
    })  
  output$downloadData2 <- downloadHandler(
    filename = function() {
      if (gotvals$point2curve == 1)
        placepart <- otageo1code()
      else
        placepart <- otageo2code()
      paste("VICObeta2_results_point2_", placepart, ".txt", sep = "")
    },
    content = function(file) {
      if (gotvals$point2curve == 1)
        point2filedata <- load.otadownloadtxtdata(otageo1dataset(), input$otaobjcomp, gotvals$point2[1], VICOBucketName)
      else
        point2filedata <- load.otadownloadtxtdata(otageo2dataset(), input$otaobjcomp, gotvals$point2[1], VICOBucketName)
      writeLines(point2filedata, file, sep = "\r\n")
    })  
  output$grabfiles <- renderUI({
    if (onepointmode() & !is.null(gotvals$point1curve))
    {
      fluidRow(tags$div(style = "padding: 8px 10px 15px 20px;text-align: left;",
                        downloadButton(
                          "downloadData1",
                          paste0("Point - ", otaBar1Place())
                        )))
    }
    else
      if (twopointmode() &
          !is.null(gotvals$point1curve) & !is.null(gotvals$point2curve))
      {
        list(fluidRow(
          tags$div(style = "padding: 8px 10px 15px 20px;text-align: left;",
                   downloadButton(
                     "downloadData1",
                     paste0("Point 1 - ", otaBar1Place())
                   ))
        ),
        fluidRow(
          tags$div(style = "padding: 8px 10px 12px 20px;text-align: left;",
                   downloadButton(
                     "downloadData2",
                     paste0("Point 2 - ", otaBar2Place())
                   ))
        ))
      }
    else
      NULL
  })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # OTA/VICO Miscellaneous - Dynamic Control
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  output$clicksetting <- renderUI({
    if (doboth())
    {
      column(6,
             selectInput(
               "clickmode",
               NULL,
               choices = c(
                 "Nearest Point" = "Nearest",
                 "Circle" = "Forced",
                 "Triangle" = "First"
               )
             ))
    }
    else
      column(6)
  })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Introductory Information Panel and Text
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  output$otaintro <- renderUI({
    list(otaintrorealtop(),
         limitationsnow(),
         callforfeedbacknow())
  })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Bottom Disclaimer Panel and Text
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  output$otadisclaim <- renderUI({
    list(feedbacknow(),
         disclaimernow(),
         considerationsnow(),
         furtherdetailsnow())
  })
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Main Plot (for Beta 2 Release)
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  output$otageomainplot <- renderPlot({
    if (doboth())
      otageoplotboth()
    else
      if (dotriangleonly())
        otageoplottriangle()
    else
      if (docircleonly())
        otageoplotcircle()
    else
      plotempty(
        otaMainTitle(),
        otaXAxisLabel(),
        otaYAxisLabel(),
        otacurve1color(),
        otacurve1color(),
        0,
        50
      )
  })
  outputOptions(output, "otageomainplot", priority = -7)
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Main Plot for Beta 2 Release - Both "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otageoplotboth <- function() {
    if (!is.null(otageo1datause()) & !is.null(otageo2datause()))
    {
      if ((nrow(otageo1datause()) != 0) &
          (nrow(otageo2datause()) != 0)) {
        if (costmincase(input$otaobjcomp))
          otageoplotbothcostmin()
        else
          otageoplotbothloadredmax()
      }
      else
        NULL
    }
    else
      plotempty(
        otaMainTitle(),
        otaXAxisLabel(),
        otaYAxisLabel(),
        otacurve1color(),
        otacurve1color(),
        0,
        50
      )
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Main Plot for Beta 2 Release - Triangle "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otageoplottriangle <- function() {
    if (!is.null(otageo1datause()))
    {
      if ((nrow(otageo1datause()) != 0))
      {
        if (costmincase(input$otaobjcomp))
          otageoplotonecostmin(1)
        else
          otageoplotoneloadredmax(1)
      }
      else
        NULL
    }
    else
      plotempty(
        otaMainTitle(),
        otaXAxisLabel(),
        otaYAxisLabel(),
        otacurve1color(),
        otacurve1color(),
        0,
        50
      )
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Main Plot for Beta 2 Release - Circle "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otageoplotcircle <- function() {
    if (!is.null(otageo2datause()))
    {
      if ((nrow(otageo2datause()) != 0))
      {
        if (costmincase(input$otaobjcomp))
          otageoplotonecostmin(2)
        else
          otageoplotoneloadredmax(2)
      }
      else
        NULL
    }
    else
      plotempty(
        otaMainTitle(),
        otaXAxisLabel(),
        otaYAxisLabel(),
        otacurve1color(),
        otacurve1color(),
        0,
        50
      )
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Main Plot for Beta 2 Release - Both - Cost Min "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otageoplotbothcostmin <- function() {
    yrange <-
      range(c(
        otageo1datause()$solution_objective,
        otageo2datause()$solution_objective
      ))
    plot(
      otageo1datause()$percent_reduction_minimum,
      otageo1datause()$solution_objective,
      xlab = otaMainAxisLabel(),
      ylab = 'Minimized Cost ($)',
      type = 'b',
      pch = 24,
      cex = 1.5,
      col = otacurve1color(),
      bg = otacurve1color(),
      lwd = 2,
      yaxt = "n",
      xlim = c(0, 50),
      ylim = yrange
    )
    points(
      otageo1datause()$percent_reduction_minimum,
      otageo1datause()$solution_objective,
      type = 'p',
      pch = 24,
      cex = 1.5,
      col = otacurve1pointcolor(),
      bg = otacurve1pointcolor(),
      lwd = 2,
      yaxt = "n"
    )
    points(
      otageo2datause()$percent_reduction_minimum,
      otageo2datause()$solution_objective,
      type = 'b',
      pch = 21,
      cex = 1.5,
      col = otacurve2color(),
      bg = otacurve2color(),
      lwd = 2,
      yaxt = "n"
    )
    points(
      otageo2datause()$percent_reduction_minimum,
      otageo2datause()$solution_objective,
      type = 'p',
      pch = 21,
      cex = 1.5,
      col = otacurve2pointcolor(),
      bg = otacurve2pointcolor(),
      lwd = 2,
      yaxt = "n"
    )
    plotpoint(gotvals$point1curve, gotvals$point1[1], gotvals$point1[2], 1, twopointmode())
    plotpoint(gotvals$point2curve, gotvals$point2[1], gotvals$point2[2], 2, twopointmode())
    if (!is.null(otageo1markset()))
    { 
      points(
        otageo1markset()$percent_reduction_minimum,
        otageo1markset()$solution_objective,
        type = 'p',
        pch = 4,
        cex=1.5,
        col=otacurve1pointcolor(), bg="White", lwd=2, yaxt = "n"
      )
    }
    if (!is.null(otageo2markset()))
    { 
      points(
        otageo2markset()$percent_reduction_minimum,
        otageo2markset()$solution_objective,
        type = 'p',
        pch = 4,
        cex=1.5,
        col=otacurve2pointcolor(), bg="White", lwd=2, yaxt = "n"
      )
    }
    grid()
    title(main = otaMainTitle(), line = 1)
    myTicks = axTicks(2)
    axis(2,
         at = myTicks,
         labels = paste(formatC(myTicks / 1000000, format = 'd'), 'M', sep = ''))
    legend(
      'topleft',
      legend = c(otaTrianglePlace(), otaCirclePlace()),
      pch = c(24, 21),
      col = c(otacurve1pointcolor(), otacurve2pointcolor()),
      pt.bg = c(otacurve1pointcolor(), otacurve2pointcolor())
    )
    plotdraftdata()
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Main Plot for Beta 2 Release - Both - Load Red Max "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otageoplotbothloadredmax <- function() {
    yrange <-
      range(c(
        otageo1datause()$solution_objective,
        otageo2datause()$solution_objective
      ))
    plot(
      otageo1datause()$totalcostupperbound,
      otageo1datause()$solution_objective,
      xlab = 'Total Cost ($)',
      ylab = otaMainAxisLabel(),
      type = 'b',
      pch = 24,
      cex = 1.5,
      col = otacurve1color(),
      bg = otacurve1color(),
      lwd = 2,
      xaxt = "n",
      xlim = c(0, 5000000),
      ylim = yrange
    )
    points(
      otageo1datause()$totalcostupperbound,
      otageo1datause()$solution_objective,
      type = 'p',
      pch = 24,
      cex = 1.5,
      col = otacurve1pointcolor(),
      bg = otacurve1pointcolor(),
      lwd = 2,
      xaxt = "n"
    )
    points(
      otageo2datause()$totalcostupperbound,
      otageo2datause()$solution_objective,
      type = 'b',
      pch = 21,
      cex = 1.5,
      col = otacurve2color(),
      bg = otacurve2color(),
      lwd = 2,
      xaxt = "n"
    )
    points(
      otageo2datause()$totalcostupperbound,
      otageo2datause()$solution_objective,
      type = 'p',
      pch = 21,
      cex = 1.5,
      col = otacurve2pointcolor(),
      bg = otacurve2pointcolor(),
      lwd = 2,
      xaxt = "n"
    )
    plotpoint(gotvals$point1curve, gotvals$point1[1], gotvals$point1[2], 1, twopointmode())
    plotpoint(gotvals$point2curve, gotvals$point2[1], gotvals$point2[2], 2, twopointmode())
    if (!is.null(otageo1markset()))
    {
      points(otageo1markset()$totalcostupperbound,
             otageo1markset()$solution_objective,
             type = 'p',
             pch = 4,
             cex=1.5,
             col=otacurve1pointcolor(), bg="White", lwd=2, yaxt = "n"
      )
    }
    if (!is.null(otageo2markset()))
    {
      points(otageo2markset()$totalcostupperbound,
             otageo2markset()$solution_objective,
             type = 'p',
             pch = 4,
             cex=1.5,
             col=otacurve2pointcolor(), bg="White", lwd=2, yaxt = "n"
      )
    }
    grid()
    title(main = otaMainTitle(), line = 1)
    myTicks = axTicks(1)
    axis(1,
         at = myTicks,
         labels = paste(formatC(myTicks / 1000000, format = 'd'), 'M', sep = ''))
    legend(
      'topleft',
      legend = c(otaTrianglePlace(), otaCirclePlace()),
      pch = c(24, 21),
      col = c(otacurve1pointcolor(), otacurve2pointcolor()),
      pt.bg = c(otacurve1pointcolor(), otacurve2pointcolor())
    )
    plotdraftdata()
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Main Plot for Beta 2 Release - One Curve - Cost Min "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otageoplotonecostmin <- function(curveindex) {
    if (curveindex == 1) # curveindex is 1 for geo 1 (triangle)
    {
      usedata <- otageo1datause()
      markset <- otageo1markset()
      curvecolor <- otacurve1color()
      pointcolor <- otacurve1pointcolor()
      useplace <- otaTrianglePlace()
      useshape <- 24
    }
    else # curveindex is 2 for geo 2 (circle), or impossible other case
    {
      usedata <- otageo2datause()
      markset <- otageo2markset()
      curvecolor <- otacurve2color()
      pointcolor <- otacurve2pointcolor()
      useplace <- otaCirclePlace()
      useshape <- 21
    }
    yrange <-
      range(c(
        usedata$solution_objective
      ))
    plot(
      usedata$percent_reduction_minimum,
      usedata$solution_objective,
      xlab = otaMainAxisLabel(),
      ylab = 'Minimized Cost ($)',
      type = 'b',
      pch = useshape,
      cex = 1.5,
      col = curvecolor,
      bg = curvecolor,
      lwd = 2,
      yaxt = "n",
      xlim = c(0, 50),
      ylim = yrange
    )
    points(
      usedata$percent_reduction_minimum,
      usedata$solution_objective,
      type = 'p',
      pch = useshape,
      cex = 1.5,
      col = pointcolor,
      bg = pointcolor,
      lwd = 2,
      yaxt = "n"
    )
    plotpoint(gotvals$point1curve, gotvals$point1[1], gotvals$point1[2], 1, twopointmode())
    plotpoint(gotvals$point2curve, gotvals$point2[1], gotvals$point2[2], 2, twopointmode())
    if (!is.null(markset))
    { 
      points(
        markset$percent_reduction_minimum,
        markset$solution_objective,
        type = 'p',
        pch = 4,
        cex=1.5,
        col=pointcolor, bg="White", lwd=2, yaxt = "n"
      )
    }
    grid()
    title(main = otaMainTitle(), line = 1)
    myTicks = axTicks(2)
    axis(2,
         at = myTicks,
         labels = paste(formatC(myTicks / 1000000, format = 'd'), 'M', sep = ''))
    legend(
      'topleft',
      legend = c(useplace),
      pch = c(useshape), # 17
      col = c(pointcolor),
      pt.bg = c(pointcolor)
    )
    plotdraftdata()
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO Main Plot for Beta 2 Release - One Curve - Load Red Max "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otageoplotoneloadredmax <- function(curveindex) {
    if (curveindex == 1) # curveindex is 1 for geo 1 (triangle)
    {
      usedata <- otageo1datause()
      markset <- otageo1markset()
      curvecolor <- otacurve1color()
      pointcolor <- otacurve1pointcolor()
      useplace <- otaTrianglePlace()
      useshape <- 24
    }
    else # curveindex is 2 for geo 2 (circle), or impossible other case
    {
      usedata <- otageo2datause()
      markset <- otageo2markset()
      curvecolor <- otacurve2color()
      pointcolor <- otacurve2pointcolor()
      useplace <- otaCirclePlace()
      useshape <- 21
    }
    yrange <-
      range(c(
        usedata$solution_objective
      ))
    plot(
      usedata$totalcostupperbound,
      usedata$solution_objective,
      xlab = 'Total Cost ($)',
      ylab = otaMainAxisLabel(),
      type = 'b',
      pch = useshape,
      cex = 1.5,
      col = curvecolor,
      bg = curvecolor,
      lwd = 2,
      xaxt = "n",
      xlim = c(0, 5000000),
      ylim = yrange
    )
    points(
      usedata$totalcostupperbound,
      usedata$solution_objective,
      type = 'p',
      pch = useshape,
      cex = 1.5,
      col = pointcolor,
      bg = pointcolor,
      lwd = 2,
      xaxt = "n"
    )
    plotpoint(gotvals$point1curve, gotvals$point1[1], gotvals$point1[2], 1, twopointmode())
    plotpoint(gotvals$point2curve, gotvals$point2[1], gotvals$point2[2], 2, twopointmode())
    if (!is.null(markset))
    {
      points(markset$totalcostupperbound,
             markset$solution_objective,
             type = 'p',
             pch = 4,
             cex=1.5,
             col=pointcolor, bg="White", lwd=2, yaxt = "n"
      )
    }
    grid()
    title(main = otaMainTitle(), line = 1)
    myTicks = axTicks(1)
    axis(1, at = myTicks, labels = paste(formatC(myTicks/1000000, format = 'd'), 'M', sep = ''))      
    legend(
      'topleft',
      legend = c(useplace),
      pch = c(useshape),
      col = c(pointcolor),
      pt.bg = c(pointcolor)
    )
    plotdraftdata()
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO BMP Bar Plot (for Beta 2 Release)
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  output$otabarplot <- renderPlot({
    if (twopointmode() & gottwopoints())
      otabarplottwo()
    else
      if (onepointmode() & !is.null(gotvals$point1curve))
        otabarplotone()
    else
      plotemptybar(
        "Implementation Amounts",
        otacurve1color(),
        otacurve1color()
      )
  },
  height = function() {
    otabarheight()
  })
  outputOptions(output, "otabarplot", priority = -14)
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO BMP Bar Plot for Beta 2 Release - One Point "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otabarplotone <- function() {
    if (!is.null(gotvals$point1curve))
    {
      if (!is.null(ota1bardata()))
      {
        if (nrow(ota1bardata()) != 0)
          otabarplotoneguts()
        else
          NULL
      }
      else
        NULL
    }
    else
      NULL
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO BMP Bar Plot for Beta 2 Release - One Point "Subroutine" Guts
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otabarplotoneguts <- function() {
    par(mar=c(5.1,4.1,0,2.1)) # bottom, left, top, right
    opar = par(oma = c(0,0,4,0))
    bp <- barplot(
      rev(ota1bardata()[, 2]),
      main = "",
      horiz = "TRUE",
      xlab = 'Acres',
      ylab = 'Efficiency BMP',
      xaxt = "n",
      xlim = range(pretty(c(0, rev(ota1bardata()[, 2])))),
      axisnames = FALSE,
      col = c(otabar1color()),
      space = 0.5,
      border = NA
    )
    grid(nx = NULL, ny = NA)
    text(1, bp, paste0(" ", rev(ota1bardata()[, 1]), ": ",
                       rev(
                         formatC(
                           round(ota1bardata()[, 2], digits = 1),
                           format = "f",
                           digits = 1,
                           big.mark = ","
                         )
                       ), 
                       " at $", 
                       rev(
                         formatC(
                           round(ota1bardata()[, 3], digits = 2),
                           format = "f",
                           digits = 2,
                           big.mark = ","
                         )
                       ), 
                       " total annualized cost per unit"), adj = c(0, 0.5))
    myTicks = axTicks(1)
    axis(1, at = myTicks, labels = paste(formatC(myTicks, format = 'd', big.mark = ","), sep = ''))      
    par(opar) # Reset par
    opar = par(oma = c(0,0,0,0), mar = c(0,0,0,0), new = TRUE)
    legend(fill = c(otabar1color(), 'White'), legend = c(otaBar1Place(), otaBarLegend1Other()), 
           x = 'top', bty = 'n', cex = 1.15, border = NA, y.intersp = 1.5, xpd=NA) # inset = c(-0.1), 
    par(opar) # reset par 
    plotdraftdata()
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO BMP Bar Plot for Beta 2 Release - Two Point "Subroutine"
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otabarplottwo <- function() {
    if (gottwopoints())
    {
      if (!is.null(otacompbardata()))
      {
        if (nrow(otacompbardata()) != 0)
          otabarplottwoguts()
        else
          NULL
      }
      else
        NULL
    }
    else
      NULL
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # VICO BMP Bar Plot for Beta 2 Release - Two Point "Subroutine" Guts
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  otabarplottwoguts <- function() {
    newdf <- otacompbardata()
    newdf$strsortfield <- as.character(newdf$bmpfullname)
    sorteddf <- newdf[order(newdf$strsortfield, decreasing = TRUE), ]
    whole <-
      cbind(sorteddf$point2acres,
            sorteddf$point1acres)
    rownames(whole) <- sorteddf$strsortfield
    colnames(whole) <- c("point1acres", "point2acres")
    barmatrix <- t(whole)
    try <-
      c(rbind(sorteddf$strsortfield,
              sorteddf$strsortfield))
    acres <-
      c(rbind(sorteddf$point2acres,
              sorteddf$point1acres))
    annual <-
      c(rbind(
        sorteddf$point2annualcostperunit,
        sorteddf$point1annualcostperunit
      ))
    par(mar = c(5.1, 4.1, 0, 2.1)) # bottom, left, top, right
    opar = par(oma = c(0, 0, 7, 0))
    bp <- barplot(
      barmatrix,
      main = "",
      xlab = 'Acres',
      ylab = 'Efficiency BMP',
      xaxt = "n",
      xlim = range(pretty(c(
        0,
        c(sorteddf$point2acres,
          sorteddf$point1acres)
      ))),
      axisnames = FALSE,
      col = c(otabar2color(), otabar1color()),
      horiz = TRUE,
      beside = TRUE,
      border = NA
    )
    grid(nx = NULL, ny = NA)
    text(
      1,
      bp,
      paste0(
        " ",
        try,
        ": ",
        formatC(
          round(acres, digits = 1),
          format = "f",
          digits = 1,
          big.mark = ","
        ),
        " at $",
        formatC(
          round(annual, digits = 2),
          format = "f",
          digits = 2,
          big.mark = ","
        ),
        " total annualized cost per unit"
      ),
      adj = c(0, 0.5)
    )
    myTicks = axTicks(1)
    axis(1, at = myTicks, labels = paste(formatC(myTicks, format = 'd', big.mark = ","), sep = ''))      
    par(opar) # reset par
    opar = par(oma = c(0, 0, 0, 0),
               mar = c(0, 0, 0, 0),
               new = TRUE)
    legend(
      fill = c(otabar1color(), 'White', otabar2color(), 'White'),
      legend = c(
        otaBar1Place(),
        otaBarLegend1Other(),
        otaBar2Place(),
        otaBarLegend2Other()
      ),
      x = 'top',
      bty = 'n',
      cex = 1.15,
      border = NA,
      y.intersp = 1.5,
      xpd = NA
    ) # inset = c(-0.1),
    par(opar) # reset par
    plotdraftdata()
  }
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
  # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
}
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
shinyApp(ui = ui, server = server)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
