# Experiments with dark mode in Quarto's Jupyter engine

## Overview

This is an experimental implementation of dark mode for plotting libraries in Quarto's Jupyter engine and Python. The same approach should work for any Jupyter languages by emitting the same **marker spans** via Markdown.

Implemented in Quarto's "user-land", i.e. Lua and CSS, without any changes to Quarto.

The objective for all engines is to produce `img.quarto-light-image` and `img.quarto-dark-image` next to each other (inside `figure > p` currently). Then they can easily and safely be swapped using

```css
body.quarto-light img.quarto-dark-image {
  display: none;
}
body.quarto-dark img.quarto-light-image {
  display: none;
}
```

## Jupyter implementation

See also: [Experiments with dark mode in Quarto's knitr engine](https://github.com/gordonwoodhull/dark-mode-experiments-knitr)

### Emitting **marker spans** in Markdown

In Jupyter, we have to run code for each of the plots; there is no way that we know to replay plots with different color themes.

We also don't want to ask users to wrap their plots in something that generates complicated Markdown around it; we want to use the familiar "interctive" plot commands that produce output like

```markdown
::: {.cell-output .cell-output-display}
![](test-matplotlib_files/figure-html/cell-2-output-2.png){width=579 height=431}
:::
```

when emitted as Pandoc markdown by Quarto's Jupyter engine.

Also we have the restriction that without changing the Jupyter engine, there is no way to emit any structural elements, e.g. fenced divs, _around_ a plot output.

This is because

```python
from IPython.display import display, Markdown
display(Markdown('...'))
```

will be wrapped in `.cell-output-display.cell-output-markdown`

```markdown
::: {.cell-output .cell-output-display .cell-output-markdown}
...
:::
```

So we emit the (hopefully harmless and invisible?) **marker span**

```markdown
::: {.cell-output .cell-output-display .cell-output-markdown}
[]{.quarto-light-marker}
:::
```

(or corresponding `.quarto-dark-marker`) before the `.cell-output-display` with the plot we want.

### Lua processing

We loop though each cell, looking for the `cell-output-display`s containing `span.quarto-light-marker` or `span.quarto-dark-marker`.

The next div is a `lightDiv` or `darkDiv`, so remember it. If we have both a `lightDiv` and a `darkDiv`, we move the dark image in with the light image.

This is maybe not robust if light or dark images are missing. Conceivably we could add structure by also having e.g. `quarto-plot-start-marker`.

We also need to remove the empty `darkDiv`, and possibly the markers, but it's in a loop and I don't want to think about that until we've validated this somewhat.

## Future

It should be possible to put this stuff, along with stuff specific to plotting libraries, into a Python library using `with` statement and context managers.

There also will be succinct and Pythonic patterns to have the same code run twice over light and dark mode, rather than duplicating the plotting code.

First priority is to validate the basic design across other Python plotting libraries, before cleaning up.

## Plotting package specifics

### matplotlib

We make sure to call

```py
plt.show(block=False)
```

to show the plot before we emit our next Markdown.
