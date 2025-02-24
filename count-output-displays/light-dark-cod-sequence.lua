-- trim a string
function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end


function Div(div)
  -- Only process cell div with renderings attr
  if not div.classes:includes("cell") or not div.attributes["renderings"] then
    return nil
  end
  local renderingsJson = div.attributes['renderings']
  quarto.log.output('renderings json', renderingsJson)
  local renderings = quarto.json.decode(renderingsJson)
  if not type(renderings) == "table" or #renderings == 0 then
    quarto.log.warning("renderings expected array of rendering names, got", renderings)
    return nil
  end
  local cods = {}
  for i, cellOutput in ipairs(div.content) do
    if cellOutput.classes:includes("cell-output-display") then
      table.insert(cods, cellOutput)
    end
  end

  if #cods ~= #renderings then
    quarto.log.warning("need", #renderings, "cell-output-display for renderings", table.concat(renderings, ",") .. ";", "got", #cods)
    return nil
  end

  local outputs = {}
  for i, r in ipairs(renderings) do
    outputs[r] = cods[i]
  end
  local lightDiv = outputs['light']
  local darkDiv = outputs['dark']

  if quarto.format.isHtmlOutput() then
    div.content = pandoc.Blocks({
      pandoc.Div(lightDiv.content, pandoc.Attr("", {'quarto-light-content'}, {})),
      pandoc.Div(darkDiv.content, pandoc.Attr("", {'quarto-dark-content'}, {}))
    })
  else
    div.content = pandoc.Blocks({lightDiv})
  end
  return div
end
