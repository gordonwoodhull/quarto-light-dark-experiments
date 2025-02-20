
-- does the table contain a value
local function tcontains(t, value)
  if t and type(t) == "table" and value then
    for _, v in ipairs(t) do
      if v == value then
        return true
      end
    end
    return false
  end
  return false
end

function removeClass(classes, remove)
  return classes:filter(function(clz) return clz ~= remove end)
end

function Div(div)
  if tcontains(div.classes, 'quarto-float')
      and tcontains(div.classes, 'quarto-light-content')
      and tcontains(div.classes, 'quarto-dark-content') then
    quarto.log.output('remove contradictory light dark')
    div.classes = removeClass(removeClass(div.classes, 'quarto-light-content'), 'quarto-dark-content')
    return div
  end
  return nil
end