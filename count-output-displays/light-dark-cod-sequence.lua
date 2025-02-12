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
      quarto.log.output(cods[1])
      quarto.log.warning("don't know start/stride for " .. #cods .. ' cell-output-displays, light/dark disabled')
      return nil
    end
    return div
  elseif #cods < 2 then
    quarto.log.warning('not enough cell-output-display to do light/dark')
    return nil
  else
    start = 1
    stride = 1
  end

  local lightDiv = cods[start]
  local darkDiv = cods[start+stride]
  local lightContent = lightDiv.content[1]
  local darkContent = darkDiv.content[1]
  if lightContent and darkContent then
    local lightType = pandoc.utils.type(lightContent)
    local darkType = pandoc.utils.type(darkContent)

    -- quarto.log.output('cod doin light/dark', lightType, darkType, '\n', lightDiv)
    if lightType ~= darkType then
      quarto.log.warning('light/dark content different types', lightType, darkType)
      return nil
    elseif lightType == "Para" then
      if stride ~= 1 then
        quarto.log.warning('multiple Para light/dark content currently not supported')
        return nil
      end
      lightContent.content[1].classes:insert 'quarto-light-content'
      darkContent.content[1].classes:insert 'quarto-dark-content'
      lightContent.content:insert(darkContent.content[1])
      darkDiv.content = pandoc.Blocks({})
    elseif lightType == "Block" then
      local nlight = indices[darkDiv] - indices[lightDiv]
      local ndark = #div.content - indices[darkDiv] + 1
      if nlight ~= stride or ndark ~= stride then
        quarto.log.warning('extra non-cell-output-display content detected, nlight', nlight, 'ndark', ndark, 'start', start, 'i[l]', indices[lightDiv], 'stride', stride)
        return nil
      end
      quarto.log.output('nlight', nlight, 'ndark', ndark, 'start', start, 'i[l]', indices[lightDiv], 'stride', stride)

      local lightContents = pandoc.Blocks({})
      local darkContents = pandoc.Blocks({})
      for i = indices[lightDiv], indices[darkDiv]-1 do
        quarto.log.output(div.content[i])
        lightContents:insert(div.content[i].content[1])
      end
      for i = indices[darkDiv], #div.content do
        darkContents:insert(div.content[i].content[1])
      end
      div.content[indices[lightDiv]] = pandoc.Div(lightContents, pandoc.Attr("", {'quarto-light-content'}, {}))
      div.content[indices[lightDiv] + 1] = pandoc.Div(darkContents, pandoc.Attr("", {'quarto-dark-content'}, {}))
      quarto.log.output('lc', lightContents) -- div.content[indices[lightDiv]])
      for i = indices[lightDiv] + 2, #div.content do
        div.content[i] = nil
      end
      return div
    else
      quarto.log.warning('do not know how to handle content type', lightType)
      return nil
    end
    return div
  end
  return nil
end
