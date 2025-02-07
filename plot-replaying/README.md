# Experiments with dark mode in Quarto's knitr engine

## Overview

This is an experimental implementation of dark mode for plotting libraries in Quarto's knitr engine, using its vectorized `dev` chunk option.

Implemented in Quarto's "user-land", i.e. Lua and CSS, without any changes to Quarto.

## Objective

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

## knitr implementation

See also: [Experiments with dark mode in Quarto's Jupyter engine](https://github.com/gordonwoodhull/dark-mode-experiments-jupyter)

We rely on knitr's vectorized `dev` chunk option, with corresponding filenames:

```
#| dev: [svglite,darksvglite]
#| fig.ext: [.light.svg, .dark.svg]
```

in the cell or in `opts_chunk`. This replays the plot with multiple "devices", although we are really just setting stuff up for the plotting library in a function that sets up the device and returns it.

With those assumptions, it's reasonably safe in the Lua filter to

- pick up any image whose `src` ends with `.light.svg`
- put another image next to it pointing to the output with the corresponding dark filename
- apply the `.quarto-light-image` and `.quarto-dark-image` classes to the images

## Future

Maybe we should check if both image files exist and fall back appropriately if there is only one image, accept only dark image, etc.

We'll need a list of image file extensions.

We'll see how well this scales across all R plotting libraries.

Do something similar for HTML output, where the code certainly does need to be run twice and knitr's `dev` chunk option probably won't help. It may be necessary to fall back to the bulky but reasonably robust (?) **marker spans** approach used in the [Jupyter side of this experiment](https://github.com/gordonwoodhull/dark-mode-experiments-jupyter).

## Prior work

This is based on Mickaël Canouil's excellent introduction [Quarto Q&A: How to have images for both light and dark mode](https://mickael.canouil.fr/posts/2023-05-30-quarto-light-dark/).
