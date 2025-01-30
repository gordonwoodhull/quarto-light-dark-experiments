function Div(div)
  if not quarto.utils.match(".quarto-light-dark-container") then return nil end
  local lightDiv, darkDiv, changed
  for i, cod in ipairs(div.content) do
    if quarto.utils.match(".quarto-light-marker")(cod) then
      lightDiv = cod
    elseif quarto.utils.match("[1]/Para/[1]/Span/.quarto-light-marker")(cod) then
      lightDiv = div.content[i+1]
    elseif quarto.utils.match(".quarto-dark-marker")(cod) then
      darkDiv = cod
    elseif quarto.utils.match("[1]/Para/[1]/Span/.quarto-dark-marker")(cod) then
      darkDiv = div.content[i+1]
    end
    if lightDiv and darkDiv then
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
  end
  return changed and div
end
