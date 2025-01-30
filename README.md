# Experiments with dark mode using fenced divs in Pandoc markdown

## Overview

This is an experimental implementation of dark mode for plotting and table libraries in Quarto's Jupyter and knitr engines, using fenced divs to identify the light and dark content.

Implemented in Quarto's "user-land", i.e. Lua and CSS, without any changes to Quarto.

The same approach should work for any Jupyter languages by emitting the same **marker spans** via Markdown.

The Jupyter markdown is slightly more complicated than the [knitr markdown](#knitr-implementation), because of constraints described in the [Jupyter section](#jupyter-implementation).

The objective for all engines is to produce a div with two items classed `.quarto-light-content` and `.quarto-dark-content` next to each other (inside `figure > p` currently).

Then they can easily and safely be swapped using

```css
body.quarto-light .quarto-dark-content {
  display: none;
}
body.quarto-dark .quarto-light-content {
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

## knitr implementation

For knitr, we can use `output: asis` and output simpler markdown with `.quarto-light-marker` and `.quarto-dark-marker` applied directly to the the `.cell-output-display` divs, e.g.

```markdown
::: {.cell}
::: {.cell-output-display .quarto-light-marker}
![](thematic_files/figure-html/unnamed-chunk-3-1.png){width=672}
:::
::: {.cell-output-display .quarto-dark-marker}
![](thematic_files/figure-html/unnamed-chunk-3-2.png){width=672}
:::
```

## Lua processing

We loop though the contents of each `div.cell`

- for Jupyter content, we look for the `cell-output-display`s containing `span.quarto-light-marker` or `span.quarto-dark-marker`.
  The next div is a `lightDiv` or `darkDiv`, so remember it.
- for knitr content, the `lightDiv` is a `div.cell-output-display.quarto-light-marker`, and respectively for darkDiv

If we have both a `lightDiv` and a `darkDiv`, we move the content of the dark div in with the light div.

We support two kinds of content:

- Paragraphs containing one item, probably an image. We class that item `.quarto-light-content` or `.quarto-dark-content`
- Raw blocks, probably HTML. We enclose them in `div.quarto-light-content` or `div.quarto-dark-content`

This is maybe not robust if light or dark content is missing. Conceivably we could add structure by also having e.g. `quarto-plot-start-marker`.

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
