library(plotly)

plotly_theme_colors <- function(bg, fg)
  (function(plot)
    plot |> layout(paper_bgcolor = bg,
      plot_bgcolor = bg,
      font = list(color = fg)
    )
  )
plotly_theme_brand <- function(brand_yml) {
  brand <- yaml::yaml.load_file(brand_yml)
  plotly_theme_colors(brand$color$background, brand$color$foreground)
}
