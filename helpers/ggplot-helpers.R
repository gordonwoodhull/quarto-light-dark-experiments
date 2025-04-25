library(ggplot2)

ggplot_theme_colors <- function(bgcolor, fgcolor) {
  theme_minimal(base_size = 11) %+%
    theme(
      panel.border = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      text = element_text(colour = fgcolor),
      axis.text = element_text(colour = fgcolor),
      rect = element_rect(colour = bgcolor, fill = bgcolor),
      plot.background = element_rect(fill = bgcolor, colour = NA),
      axis.line = element_line(colour = fgcolor),
      axis.ticks = element_line(colour = fgcolor)
    )
}

ggplot_theme_brand <- function(brand_yml) {
  brand <- yaml::yaml.load_file(brand_yml)
  ggplot_theme_colors(brand$color$background, brand$color$foreground)
}
