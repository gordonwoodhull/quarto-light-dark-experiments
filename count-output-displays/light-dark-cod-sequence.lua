function Div(div)
  -- Only process cell div with light-dark marker
  if not div.classes:includes("cell") or not div.classes:includes("quarto-light-dark-container") then
    return nil
  end
  quarto.log.output('light-dark-cod-sequence')
  local cods = {}
  local indices = {}
  for i, cellOutput in ipairs(div.content) do
    if cellOutput.classes and cellOutput.classes:includes("cell-output-display") then
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
    quarto.log.warning('not enough cell-output-display to do light/dark', #cods)
    return nil
  else
    start = 1
    stride = 1
  end

  local lightDiv = cods[start]
  local darkDiv = cods[start+stride]

  quarto.log.output('light', lightDiv)
  quarto.log.output('dark', darkDiv)
  local nlight = indices[darkDiv] - indices[lightDiv]
  local ndark = #div.content - indices[darkDiv] + 1
  quarto.log.output('info: #div.content', #div.content, 'nlight', nlight, 'ndark', ndark, 'start', start, 'i[l]', indices[lightDiv], 'stride', stride)

  if nlight ~= stride or ndark ~= stride then
    quarto.log.warning('extra non-cell-output-display content detected, nlight', nlight, 'ndark', ndark, 'start', start, 'i[l]', indices[lightDiv], 'stride', stride)
    return nil
  end

  local lightContents = pandoc.Blocks({})
  local darkContents = pandoc.Blocks({})
  local caption
  local identifier = nil
  for i = indices[lightDiv], indices[darkDiv]-1 do
    -- remove identifier from figure
    if div.content[i].content[1].caption and div.content[i].content[1].attr.identifier then
      identifier = div.content[i].content[1].attr.identifier
      div.content[i].content[1].attr.identifier = ""
    -- else remove identifier from image
    elseif div.content[i].content[1].content[1] and div.content[i].content[1].content[1].caption
        and div.content[i].content[1].content[1].attr.identifier ~= "" then
      identifier = div.content[i].content[1].content[1].attr.identifier
      div.content[i].content[1].content[1].attr.identifier = ""
    end

  lightContents:insert(div.content[i].content[1])
    if #div.content[i].content > 1 then
      caption = div.content[i].content[2]
    end
  end
  -- if cell doesn't have identifier, use one from figure/imate, removing number at end
  if identifier and div.attr.identifier == "" then
    div.attr.identifier = identifier:gsub('%-%d+$', '')
  end

  -- if light is a figure but dark is not, dupe light figure and replace src
  -- to preserve caption, which only goes on first
  if stride == 1 and lightDiv.content[1].caption and not darkDiv.content[1].caption then
    local darkFigure = lightDiv.content[1]:walk {} -- already has identifier removed
    darkFigure.content[1].content[1].src = darkDiv.content[1].content[1].src
    darkContents:insert(darkFigure)
  else
    for i = indices[darkDiv], #div.content do
      -- remove identifier from figure
      if div.content[i].content[1].caption then
        div.content[i].content[1].attr.identifier = ""
      -- or from image
      elseif div.content[i].content[1].content[1] and div.content[i].content[1].content[1].caption
          and div.content[i].content[1].content[1].attr.identifier ~= "" then
        div.content[i].content[1].content[1].attr.identifier = ""
      end
      darkContents:insert(div.content[i].content[1])
    end
  end

  div.content[indices[lightDiv]] = pandoc.Div(lightContents, pandoc.Attr("", {'quarto-light-content'}, {}))
  div.content[indices[lightDiv] + 1] = pandoc.Div(darkContents, pandoc.Attr("", {'quarto-dark-content'}, {}))
  local outj = indices[lightDiv] + 1
  if caption then
    outj = outj + 1
    div.content[outj] = caption
  end
  for i = outj + 1, #div.content do
    div.content[i] = nil
  end
  return div
end
