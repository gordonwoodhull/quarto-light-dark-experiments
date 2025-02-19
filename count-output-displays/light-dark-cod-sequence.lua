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
    local cod = div.content[i] -- light cell-output-display
    -- remove identifier from figure
    if cod.content[1].caption and cod.content[1].attr.identifier then
      identifier = cod.content[1].attr.identifier
      cod.content[1].attr.identifier = ""
    -- else remove identifier from image
    elseif cod.content[1].content
        and cod.content[1].content[1]
        and cod.content[1].content[1].caption
        and cod.content[1].content[1].attr.identifier ~= "" then
      identifier = cod.content[1].content[1].attr.identifier
      cod.content[1].content[1].attr.identifier = ""
    end

    lightContents:insert(cod.content[1])
    if #cod.content > 1 then
      caption = cod.content[2]
    end
  end
  -- if cell doesn't have identifier, use one from figure/imate, removing number at end
  if identifier and div.attr.identifier == "" then
    div.attr.identifier = identifier:gsub('%-%d+$', '')
  end

  -- if light is a figure but dark is not, dupe light figure and replace src
  -- to preserve caption, which only goes on first
  if stride == 1 then
    local lightImage, darkImage
    if lightDiv.content[1].caption and not darkDiv.content[1].caption then
      quarto.log.output('dark div has no figure')
      if lightDiv.content[1].content
          and lightDiv.content[1].content[1] -- Plain
          and lightDiv.content[1].content[1].content
          and lightDiv.content[1].content[1].content[1] then -- Image
        lightImage = lightDiv.content[1].content[1].content[1]
        darkImage = darkDiv.content[1].content[1]
      end
  -- if both are figures containing images, move image from dark figure into light one
    elseif lightDiv.content[1].caption and darkDiv.content[1].caption then
      quarto.log.output('both figure')
      if lightDiv.content[1].content
          and lightDiv.content[1].content[1] -- Plain
          and lightDiv.content[1].content[1].content
          and lightDiv.content[1].content[1].content[1] -- Image
          and darkDiv.content[1].content
          and darkDiv.content[1].content[1] -- Plain
          and darkDiv.content[1].content[1].content
          and darkDiv.content[1].content[1].content[1] then -- Image
        lightImage = lightDiv.content[1].content[1].content[1]
        darkImage = darkDiv.content[1].content[1].content[1]
      end
    end
    if lightImage and darkImage then
      lightImage.attr.classes:insert 'quarto-light-content'
      darkImage.attr.classes:insert 'quarto-dark-content'
      lightDiv.content[1].content = pandoc.Blocks({
        pandoc.Div({
          pandoc.Plain(lightImage),
          pandoc.Plain(darkImage)
        })
      })
      lightDiv.content[1].attr.identifier = div.attr.identifier
      div.attr.identifier = ""
      lightContents = nil
      darkContents = nil
      quarto.log.output('image patchup complete', lightDiv)
    end
  else
    for i = indices[darkDiv], #div.content do
      local cod = div.content[i] -- dark cell-output-display
      -- remove identifier from figure
      if cod.content[1].caption then
        quarto.log.output('waht would this mean')
        cod.content[1].attr.identifier = ""
      -- or from image
      elseif cod.content[1].content
          and cod.content[1].content[1]
          and cod.content[1].content[1].caption
          and cod.content[1].content[1].attr.identifier ~= "" then
        cod.content[1].content[1].attr.identifier = ""
      end
      darkContents:insert(cod.content[1])
    end
  end

  quarto.log.output('lightContents', lightContents)
  local outj = indices[lightDiv]
  if lightContents then
    div.content[indices[lightDiv]] = pandoc.Div(lightContents, pandoc.Attr("", {'quarto-light-content'}, {}))
    outj = outj + 1
  else
    -- we have modified lightDiv
    outj = outj + 1
  end
  if darkContents then
    div.content[indices[lightDiv] + 1] = pandoc.Div(darkContents, pandoc.Attr("", {'quarto-dark-content'}, {}))
    outj = outj + 1
  end

  if caption then
    div.content[outj] = caption
    outj = outj + 1
  end
  quarto.log.output('delete cods from', outj)
  for i = outj, #div.content do
    div.content[i] = nil
  end
  return div
end
