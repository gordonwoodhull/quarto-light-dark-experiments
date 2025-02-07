function Div(div)
  -- Only process cell div with ligh-dark marker
  if not div.classes:includes("cell") or not div.classes:includes("quarto-light-dark-container") then 
    return nil 
  end

  -- expect 2 cells output display only
  if quarto.utils.match("Div/[3]/.cell-output-display")(div) then
    quarto.log.info("Requires 2 outputs only. No dark-light appplied")
    return nil
  end

  local firstClass = "light"
  return div:walk({
    traverse = 'topdown',
    Div = function(div)
      if div.classes:find_if(quarto._quarto.modules.classpredicates.isCodeCellDisplay) then
        div.classes:insert("quarto-" .. firstClass .. "-marker")
        firstClass = "dark"
        return div
      end
    end
  })

end
