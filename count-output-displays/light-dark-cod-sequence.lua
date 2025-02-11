function Div(div)
  -- Only process cell div with ligh-dark marker
  if not div.classes:includes("cell") or not div.classes:includes("quarto-light-dark-container") then
    return nil
  end

  local cods = {}
  local indices = {}
  for i, cellOutput in ipairs(div.content) do
    if cellOutput.classes:includes("cell-output-display") then
      indices[cellOutput] = #cods
      table.insert(cods, cellOutput)
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
  else
    start = 1
    stride = 1
  end

  if stride == 1 then
    local lightDiv = cods[start]
    local darkDiv = cods[start+1]
    local lightContent = lightDiv.content[1]
    local darkContent = darkDiv.content[1]
    if lightContent and darkContent then
      local lightType = pandoc.utils.type(lightContent)
      local darkType = pandoc.utils.type(darkContent)

      if lightType ~= darkType then
        quarto.log.warning('light/dark content different types', lightType, darkType)
      elseif lightType == "Para" then
        lightContent.content[1].classes:insert 'quarto-light-content'
        darkContent.content[1].classes:insert 'quarto-dark-content'
        lightContent.content:insert(darkContent.content[1])
        darkDiv.content = pandoc.Blocks({})
      elseif lightType == "Block" then
        lightDiv.content = pandoc.Blocks({
          pandoc.Div(lightContent, pandoc.Attr("", {'quarto-light-content'}, {})),
          pandoc.Div(darkContent, pandoc.Attr("", {'quarto-dark-content'}, {}))
        })
        darkDiv.content = pandoc.Blocks({})
      else
        quarto.log.warning('do not know how to handle content type', lightType)
      end
      lightDiv = nil
      darkDiv = nil
      changed = true
    end
  end
  return div
end
