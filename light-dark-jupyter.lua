function Div(div)
  local cod1 = quarto.utils.match(".cell/[1]/.cell-output-display")(div)
  local cod2 = quarto.utils.match(".cell/[2]/.cell-output-display")(div)

  if cod1 and cod2 then
    local imgPat = '.cell-output-display/[1]/[1]/Image'
    local image1 = quarto.utils.match(imgPat)(cod1)
    local image2 = quarto.utils.match(imgPat)(cod2)
    if image1 and image2 then
      local image1par = quarto.utils.match('.cell-output-display/[1]/')(cod1)
      local image2par = quarto.utils.match('.cell-output-display/[1]/')(cod2)
      quarto.log.output('images', image1par, image2par)
      image1par.content:insert(image2)
      image2par.content = pandoc.Inlines({})
      return div
    end
  end
end
