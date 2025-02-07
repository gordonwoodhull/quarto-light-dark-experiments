---
title: dark mode approaches
---

There are various possible approaches to dark mode for plots and tables in Quarto.

# Replaying of drawing commands

* knitr allows multiple devices to be specified via `dev`.
* The plot is drawn once, and then replayed to multiple devices, each with a different color palette enabled.
* This should work across all R plotting libraries that use the R graphic system.
* Conceivably other languages could have a similar graphics system.

One example is the `plot-replaying/` subdirectory.

# By marking output divs

## Marking the output div directly

Where we are able to completely control the Markdown emitted, we can put the light plot in a div with the `.quarto-light-marker` class, and the dark plot in a div with `.quarto-dark-marker`.

Some examples are in the `fenced-divs/` subdirectory.

## Emitting a "marker span" before the plot

If the output cannot be directly controlled, we can instead emit a separate output before the plot, and inside it put a span with the `.quarto-light-marker` or `.quarto-dark-marker` class.

# Filter approaches

## CSS filter

A CSS filter can be applied to invert the colors and then rotate them 180°. This reverses the luminosity while preserving the hue. Example TK.
