def as_markdown(x):
  if hasattr(x, '_repr_markdown_'):
    return x._repr_markdown_()
  elif hasattr(x, '_repr_html_'):
    return '\n'.join([
      '```{=html}',
      x._repr_html_(),
      '```',
      ''
    ])

def compose_light_dark_container(light_markdown, dark_markdown):
  return '\n'.join([
    '::: {.quarto-light-dark-container}',
    '::: {.quarto-light-marker}',
    light_markdown,
    ':::',
    '::: {.quarto-dark-marker}',
    dark_markdown,
    ':::',
    ':::',
    ''
  ])


class LightDark:
  def __init__(self, light, dark):
    print('LIGHT HAS')
    print(dir(light))
    self.light = light
    self.dark = dark

  def _repr_markdown_(self):
    return compose_light_dark_container(
      as_markdown(self.light),
      as_markdown(self.dark))

class LightDarkStateful:
  def __init__(self, apply_light, apply_dark, chart):
    self.apply_light = apply_light
    self.apply_dark = apply_dark
    self.chart = chart

  def _repr_markdown_(self):
    self.apply_light()
    light_markdown = as_markdown(self.chart)
    self.apply_dark()
    dark_markdown = as_markdown(self.chart)
    return compose_light_dark_container(light_markdown, dark_markdown)
