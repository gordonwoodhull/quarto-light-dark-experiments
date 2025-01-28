function Div(div)
  if not quarto.utils.match(".cell") then return nil end
  local lightDiv, darkDiv, changed
  for i, cod in ipairs(div.content) do
    if quarto.utils.match(".cell-output-display/[1]/Para/[1]/Span/.quarto-light-marker")(cod) then
      lightDiv = div.content[i+1]
      quarto.log.output('light', lightDiv)
    elseif quarto.utils.match(".cell-output-display/[1]/Para/[1]/Span/.quarto-dark-marker")(cod) then
      darkDiv = div.content[i+1]
      quarto.log.output('dark', darkDiv)
    end
    if lightDiv and darkDiv then
      local darkImage = quarto.utils.match("[1]/Para/[1]/Image")(darkDiv)
      local lightPara = quarto.utils.match("[1]/{Para}/[1]/Image")(lightDiv)[1]
      lightPara.content:insert(darkImage)
      darkDiv.content = pandoc.Blocks({})
      lightDiv = nil
      darkDiv = nil
      changed = true
    end
  end
  return changed and div
end
