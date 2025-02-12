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
    if cods[1].content[1].text:match '%.bk%-notebook%-logo' then -- bokeh
      start = 3
      stride = 2
    end
    if not start or not stride then
      quarto.log.warning("don't know start/stride for " .. #cods .. ' cell-output-displays, light/dark disabled')
      quarto.log.output(cods[1])
      return nil
    end
  elseif #cods < 2 then
    quarto.log.warning('not enough cell-output-display to do light/dark')
    return nil
  else
    start = 1
    stride = 1
  end

  local lightDiv = cods[start]
  local darkDiv = cods[start+stride]
  local nlight = indices[darkDiv] - indices[lightDiv]
  local ndark = #div.content - indices[darkDiv] + 1
  if nlight ~= stride or ndark ~= stride then
    quarto.log.warning('extra non-cell-output-display content detected, nlight', nlight, 'ndark', ndark, 'start', start, 'i[l]', indices[lightDiv], 'stride', stride)
    return nil
  end

  local lightContents = pandoc.Blocks({})
  local darkContents = pandoc.Blocks({})
  for i = indices[lightDiv], indices[darkDiv]-1 do
    lightContents:insert(div.content[i].content[1])
  end
  for i = indices[darkDiv], #div.content do
    darkContents:insert(div.content[i].content[1])
  end
  div.content[indices[lightDiv]] = pandoc.Div(lightContents, pandoc.Attr("", {'quarto-light-content'}, {}))
  div.content[indices[lightDiv] + 1] = pandoc.Div(darkContents, pandoc.Attr("", {'quarto-dark-content'}, {}))
  for i = indices[lightDiv] + 2, #div.content do
    div.content[i] = nil
  end
  return div
end
