function Div(div)
  -- Only process cell div with ligh-dark marker
  if not div.classes:includes("cell") or not div.classes:includes("quarto-light-dark-container") then
    return nil
  end
  local cods = {}
  local indices = {}
  for i, cellOutput in ipairs(div.content) do
    if cellOutput.classes:includes("cell-output-display") then
      table.insert(cods, cellOutput)
      indices[cellOutput] = i
    end
  end

  local start, stride
  if #cods > 2 then
    quarto.log.warning("more that two cell-output-display not supported")
    return nil
  elseif #cods < 2 then
    quarto.log.warning('not enough cell-output-display to do light/dark')
    return nil
  else
    start = 1
    stride = 1
  end

  -- fail if there is other content
  local lightDiv = cods[start]
  local darkDiv = cods[start+1]
  local nlight = indices[darkDiv] - indices[lightDiv]
  local ndark = #div.content - indices[darkDiv] + 1
  if nlight ~= stride or ndark ~= stride then
    quarto.log.warning('extra non-cell-output-display content detected, nlight', nlight, 'ndark', ndark, 'start', start, 'i[l]', indices[lightDiv], 'stride', stride)
    return nil
  end

  div.content[indices[lightDiv]] = pandoc.Div(
    pandoc.Blocks({lightDiv.content[1]}),
    pandoc.Attr("", {'quarto-light-content'}, {}))
  div.content[indices[darkDiv]] = pandoc.Div(
    pandoc.Blocks({darkDiv.content[1]}),
    pandoc.Attr("", {'quarto-dark-content'}, {}))
  for i = indices[lightDiv] + 2, #div.content do
    div.content[i] = nil
  end
  return div
end
