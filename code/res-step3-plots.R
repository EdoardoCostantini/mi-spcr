# Project:   mi-spcr
# Objective: Making plots
# Author:    Edoardo Costantini
# Created:   2022-07-19
# Modified:  2022-07-29

# Clean environment:
rm(list = ls())

# Support Functions and packages
source("init-software.R")

library(ggplot2)
library(shiny)
library(shinyWidgets)
library(dplyr)

# Read output
gg_shape <- readRDS("../output/20220726-143214-small-run-for-plot-development-pc-main-res.rds")
dat_sub <- gg_shape

plot_x_axis <- "npcs"
plot_y_axis <- "coverage"
moderator <- "method"
grid_x_axis <- "mech"
grid_y_axis <- "pm"

# R shiny plot -----------------------------------------------------------------

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput("nla",
                  "Number of latent variables",
                  choices = sort(unique(gg_shape$nla))),
      checkboxGroupInput("pm",
                         "Proportion of missing values",
                         choices = sort(unique(gg_shape$pm)),
                         selected = sort(unique(gg_shape$pm))),
      checkboxGroupInput("mech",
                         "Missing data mechanism",
                         inline = TRUE,
                         choices = levels(gg_shape$mech),
                         selected = levels(gg_shape$mech)),
      selectInput("stat",
                  "Statistic",
                  choices = unique(gg_shape$stat)),
      selectInput("vars",
                  "Variables",
                  choices = unique(gg_shape$vars)),
      selectInput("plot_y_axis",
                  "Outcome measure",
                  choices = c("RB", "PRB", "coverage", "CIW_avg", "mcsd")),
      checkboxGroupInput("method", "Imputation methods to compare:",
                         choices = levels(gg_shape$method),
                         selected = levels(gg_shape$method)[1:4]),
      shinyWidgets::sliderTextInput(inputId = "npcs",
                                    label = "Number of principal components",
                                    hide_min_max = TRUE,
                                    choices = sort(unique(gg_shape$npcs)),
                                    selected = range(gg_shape$npcs),
                                    grid = TRUE),
    ),
    mainPanel(
      plotOutput("plot", height = "800px")
    )
  )
)

server <- function(input, output, session) {

  # Dynamically update inputs
  observe({
    # Statistics and Variables requested
    if(any(input$stat %in% c("cor", "cov"))){
      updateSelectInput(session,
                        "vars",
                        choices = unique(gg_shape$vars)[1:3]
      )
    } else {
      updateSelectInput(session,
                        "vars",
                        choices = unique(gg_shape$vars)[4:6]
      )
    }

    # Number of components displayed by slider based on nla condition
    npcs_to_plot <- unique((gg_shape %>% filter(nla == input$nla))$npcs)
    npcs_to_plot <- sort(npcs_to_plot)
    shinyWidgets::updateSliderTextInput(session,
                                        inputId = "npcs",
                                        choices = npcs_to_plot,
                                        selected = range(npcs_to_plot))
  })

  output$plot <- renderPlot(
    res = 96,
  {
    gg_shape %>%
      filter(
        nla == input$nla,
        mech %in% input$mech,
        pm %in% input$pm,
        vars == input$vars,
        stat == input$stat,
        method %in% input$method,
        npcs <= input$npcs[2],
        npcs >= input$npcs[1]
      ) %>%
      ggplot(aes_string(x = plot_x_axis,
                        y = input$plot_y_axis,
                        group = moderator)) +
      geom_point(aes_string(shape = moderator), size = 1.5) +
      geom_line(aes_string(lines = moderator)) +
      scale_x_continuous(breaks = sort(unique(gg_shape$npcs)), sort(unique(gg_shape$npcs))) +
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
        axis.title.x = element_blank(),
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

library(rsconnect)
rsconnect::deployApp()

# Regular plotting -------------------------------------------------------------

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