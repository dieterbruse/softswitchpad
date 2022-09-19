-- /WIDGETS/SWTBOX/config.lua

local function f()
    local configTable = {
        -- Seite 1
        {
          { Name="Umschaltung", FileName="btn0.png", Mode=buttonType.pushbutton,ROW=1,COL=1, Value=KeyValues.Umschaltung },
          { Name="Standlicht", FileName="btn1.png", Mode=buttonType.pushbutton,ROW=1,COL=2,Value=KeyValues.Taste11 },
          { Name="Abblendlicht", FileName="btn2.png", Mode=buttonType.pushbutton,ROW=1,COL=3, Value=KeyValues.Taste10 },
          { Name="Fernlicht", FileName="btn3.png", Mode=buttonType.pushbutton,ROW=1,COL=4, Value=KeyValues.Taste9 },
          { Name="Scheinwerfer", FileName="btn4.png", Mode=buttonType.pushbutton,ROW=1,COL=5, Value=KeyValues.Taste8 },
          { Name="Nebelscheinwerfer", FileName="btn5.png", Mode=buttonType.pushbutton,ROW=1,COL=6, Value=KeyValues.Taste7 },
          { Name="Blaulicht", FileName="btn6.png", Mode=buttonType.pushbutton,ROW=2,COL=1, Value=KeyValues.Taste1 },
          { Name="Scheinwerfer", FileName="btn7.png", Mode=buttonType.pushbutton,ROW=2,COL=2, Value=KeyValues.Taste2 },
          { Name="Strahler", FileName="btn8.png", Mode=buttonType.pushbutton,ROW=2,COL=3, Value=KeyValues.Taste3 },
          { Name="Blinker links", FileName="btn9.png", Mode=buttonType.pushbutton,ROW=2,COL=4, Value=KeyValues.Taste4 },
          { Name="Warnblinker", FileName="btn10.png", Mode=buttonType.pushbutton,ROW=2,COL=5, Value=KeyValues.Taste5 },
          { Name="Blinker rechts", FileName="btn11.png", Mode=buttonType.pushbutton,ROW=2,COL=6, Value=KeyValues.Taste6 }
        },
        -- Seite 2
        {
        }
      }    return configTable
end

return f