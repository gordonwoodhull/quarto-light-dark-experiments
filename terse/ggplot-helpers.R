library(knitr)

ggplot_theme <- function(bgcolor, fgcolor) {
  library(ggplot2)
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

brand_ggplot <- function(brand_yml) {
  brand <- yaml::yaml.load_file(brand_yml)
  ggplot_theme(brand$color$background, brand$color$foreground)
}

darkmode_theme <- function(light, dark, default = light) {
  themes <- list(light = light, dark = dark)
  knit_print.ggplot <- function(x, options, ...) {
    if (is.null(options$renderings)) {
      ggplot2:::print.ggplot(x + default, ...)
    } else {
      for (theme in options$renderings) {
        ggplot2:::print.ggplot(x + themes[theme], ...)
      }
    }
    invisible(x)
  }
  registerS3method("knit_print", "ggplot", knit_print.ggplot)
}
