from base64 import b64encode

def html_as_markdown(html):
    return '\n'.join([
      '```{=html}',
      html,
      '```',
      ''
    ])

def image_as_markdown(mimetype, content):
  return f'![](data:{mimetype};base64,{b64encode(content.encode('utf8')).decode('ascii')})'

def as_markdown(x):
  if hasattr(x, '_repr_mimebundle_'):
    bundle = x._repr_mimebundle_()
    if len(bundle.keys()) > 1:
      print("warning: don't know how to handle multiple mimetype, ", bundle.keys())
    # return '```\n' + '\n'.join(bundle.keys()) + '\n```\n'
    mimetype = next(iter(bundle.keys()))
    content = bundle[mimetype]
    match mimetype:
      case 'text/html': return html_as_markdown(content)
      case 'image/svg+xml': return image_as_markdown(mimetype, content)
      case _:
        print("warning: don't know mimetype", mimetype)
        return f'_{mimetype}_'
  elif hasattr(x, '_repr_markdown_'):
    return x._repr_markdown_()
  elif hasattr(x, '_repr_html_'):
    return html_as_markdown(x._repr_html_())
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
