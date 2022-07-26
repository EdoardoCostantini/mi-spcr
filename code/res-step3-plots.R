# Project:   mi-spcr
# Objective: Making plots
# Author:    Edoardo Costantini
# Created:   2022-07-19
# Modified:  2022-07-26

# Clean environment:
rm(list = ls())

# Support Functions and packages
source("init-software.R")

library(ggplot2)

# Read results
inDir <- "../output/"
files <- grep("rds", list.files(inDir), value = TRUE)
runName <- "20220111_165620_pc_main_gg_shape.rds" # toy run with PC
runName <- "8447019_main_gg_shape.rds" # good run with lisa
runName <- "8469421_main_gg_shape.rds" # final run with lisa

# Read output
gg_shape <- readRDS("../output/20220719-155627-trial-pc-main-res.rds")
dat_sub <- gg_shape

plot_x_axis <- "npcs"
plot_y_axis <- "coverage"
moderator <- "method"
grid_x_axis <- "mech"
grid_y_axis <- "pm"

head(gg_shape)

# Fix factors for this plot
nla     <- unique(gg_shape$nla)[1]
auxcor  <- unique(gg_shape$auxcor)[1]
pm      <- unique(gg_shape$pm)[1]
mech    <- unique(gg_shape$mech)[1]
vars    <- unique(gg_shape$vars)[1]
stat    <- unique(gg_shape$stat)[1]

filters     <- list(nla     = unique(gg_shape$nla)[2],
                    auxcor  = unique(gg_shape$auxcor)[1],
                    method  = levels(gg_shape$method)[1:6],
                    # pm      = unique(gg_shape$pm)[1],
                    # mech    = unique(gg_shape$mech)[1],
                    vars    = unique(gg_shape$vars)[1],
                    stat    = unique(gg_shape$stat)[1])

# Filter data to have only what I want
dat_sub <- gg_shape
for (f in seq_along(filters)){
  filter_factor <- names(filters)[f]
  filter_lvels <- filters[[f]]
  dat_sub <- dat_sub %>%
    filter(!!as.symbol(filter_factor) %in% filter_lvels)
}
head(dat_sub)
# Define what to plot

# Plot
plot_main <- dat_sub %>%
  ggplot(aes_string(x = plot_x_axis,
                    y = plot_y_axis,
                    group = moderator)) +
  geom_point(aes_string(shape = moderator), size = 1.5) +
  geom_line() +
  scale_x_continuous(breaks = sort(unique(dat_sub$npcs)), sort(unique(dat_sub$npcs))) +
  facet_grid(reformulate(grid_x_axis,
                         grid_y_axis),
             labeller = labeller(.rows = label_both, .cols = label_value),
             switch = "y") +
  theme(
      # Text
      text = element_text(size = 12),
      strip.text.y.right = element_text(angle = 0),
      plot.title = element_text(hjust = 0.5),
      axis.title = element_text(size = 10),
      # Legend
      legend.title = element_blank(),
      legend.position = "bottom",
      # Backgorund
      panel.background = element_rect(fill = NA, color = "gray")
    )
plot_main

# R shiny plot -----------------------------------------------------------------

library(shiny)
library(shinyWidgets)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Plotting results for study"),
  sidebarLayout(
    sidebarPanel(
      selectInput("plot_y_axis",
                  "Outcome measure",
                  choices = c("RB", "PRB", "coverage", "CIW_avg", "mcsd")),
      selectInput("nla",
                  "Number of latent variables",
                  choices = sort(unique(gg_shape$nla))),
      selectInput("vars",
                  "Variables",
                  choices = unique(gg_shape$vars)),
      selectInput("stat",
                  "Statistic",
                  choices = unique(gg_shape$stat)),
      selectInput("auxcor",
                  "Correlation of auxiliary variables",
                  choices = unique(gg_shape$auxcor)),
      shinyWidgets::sliderTextInput(inputId = "npcs",
                                    label = "Number of principal components",
                                    hide_min_max = TRUE,
                                    choices = sort(unique(gg_shape$npcs)),
                                    selected = max(unique(gg_shape$npcs)),
                                    grid = TRUE),
      checkboxGroupInput("method", "Imputation methods to compare:",
                         choices = levels(gg_shape$method),
                         selected = levels(gg_shape$method)),
    ),
    mainPanel(
      plotOutput("plot", height = "800px")
    )
  )
)

server <- function(input, output, session) {

  output$plot <- renderPlot(
    res = 96,
  {
    dat_sub %>%
      filter(nla == input$nla,
             vars == input$vars,
             stat == input$stat,
             auxcor == input$auxcor,
             method %in% input$method,
             npcs <= input$npcs) %>%
      ggplot(aes_string(x = plot_x_axis,
                        y = input$plot_y_axis,
                        group = moderator)) +
      geom_point(aes_string(shape = moderator), size = 1.5) +
      geom_line(aes_string(lines = moderator)) +
      scale_x_continuous(breaks = sort(unique(dat_sub$npcs)), sort(unique(dat_sub$npcs))) +
      facet_grid(reformulate(grid_x_axis,
                             grid_y_axis),
                 labeller = labeller(.rows = label_both,
                                     .cols = label_value),
                 switch = "y") +
      theme(
        # Text
        text = element_text(size = 12),
        strip.text.y.right = element_text(angle = 0),
        plot.title = element_text(hjust = 0.5),
        axis.title = element_text(size = 10),
        # Legend
        legend.title = element_blank(),
        legend.position = "bottom",
        # Backgorund
        panel.background = element_rect(fill = NA, color = "gray")
      )
  }
  )

}

shinyApp(ui, server)
