function Div(div)
  -- Only process cell div with ligh-dark marker
  if not div.classes:includes("cell") or not div.classes:includes("quarto-light-dark-container") then 
    return nil 
  end

  -- expect 2 cells output display only
  local nOutputDisplay = 2
  div:walk({
    Div = function(div)
      if div.classes:includes("cell-output-display") then
        nOutputDisplay = nOutputDisplay - 1
      end
      if nOutputDisplay < 0 then 
        quarto.log.info("Requires 2 outputs only. No dark-light appplied")
        return nil
      end
    end
  })

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
