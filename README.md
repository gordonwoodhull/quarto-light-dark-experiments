# Approaches to light & dark modes for plots and tables in Quarto

This repo collects examples of various approaches to implement light and dark mode for plots and tables in Quarto.

## Replaying of drawing commands

* knitr allows multiple devices to be specified via `dev`.
* The plot is drawn once, and then replayed to multiple devices, each with a different color palette enabled.
* This should work across all R plotting libraries that use the R graphic system.
* Conceivably other languages could have a similar graphics system.

One example is the `plot-replaying/` subdirectory.

## By marking output divs

### Fenced divs

Where we are able to completely control the Markdown emitted, we can put the light plot in a div with the `.quarto-light-marker` class, and the dark plot in a div with `.quarto-dark-marker`.

However, we don't have precise control over the way the `.cell-output-display` divs are emitted in R without using `output: asis`, and we don't want users to have to use this.

We also don't have precise control in Jupyter, because packages can always emit plots as a side-effect.

So this wouldn't be a nice approach without more engine support, and some alternate way to display Python plots without letting them be emitted as a side-effect.

Some examples are in the `fenced-divs/` subdirectory.

### Emitting a "marker span" before the plot

If the output cannot be directly controlled, we can instead emit a separate output before the plot, and inside it put a span with the `.quarto-light-marker` or `.quarto-dark-marker` class.

This worked quite well, but is exceedingly ugly.

Some examples are in the `marker-spans/` subdirectory.

## By counting `.cell-output-display`s in a cell

This is a general approach that avoids the problems described in the last section, at the cost of some ambiguity in the Markdown output.

First, we stipulate that the code block (and `.cell`) should only contain `.cell-output-display`s that pertain to one plot's light and dark output.

The user should add

````
#| classes: quarto-light-dark-container
````

to this code block. Then our filter counts the number of `.cell-output-display` and if it is two, we use those two as light and dark plots.

It does not currently work when a plot emits more than one `cell-output-display` but this should be fixable by checking for a multiple of the expected number (two).

Examples in the `count-output-displays/` subdirectory.

## Filter approaches

If the user does not care about exact colors and styling, and does not specify how to produce dark brand plots, we can filter the light brand plots in the browser to produce an approximate dark mode version.

### CSS filter

A CSS filter can be applied to invert the colors and then rotate them 180°. This reverses the luminosity while preserving the hue.

Example in the `css-filters/` directory.
