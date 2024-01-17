-- Lua TBSSwitch for Das Modul/Benedini Micro/Mini widget V0.1
--
--
-- A Radiomaster TX16S widget for the EdgeTX OS to simulate a TBSSWT
--
-- Author: Dieter Bruse http://bruse-it.com/
--
-- This file is part of a free Widgetlibrary.
--
-- Smart Switch is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY, without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, see <http://www.gnu.org/licenses>.
local log_filename = "/LOGS/TBSSWTWidget.log"
local name = "TBSSwitch"
local touchedButton = -1
local BitmapButton = Bitmap.open("/WIDGETS/TBSSWT/PNG/Btn0.png")
local BitmapWidth, BitmapHeight = Bitmap.getSize(BitmapButton)
--[	####################################################################
--[ Takt und Auslösedauer der Logischen Schalter können entsprechend angepasst werden.cp
local LSTaktzeit = -127 -- Taktzeit für den logischen Schalter -128 = 0,1s, -127=0,2s usw.
local LSDauer = 2 -- Entspricht 1/10s und muss zur LSTaktzeit entsprechend eingestellt werden.
-- local ChannelLearning = 0

local options = {
  { "Border", COLOR, WHITE},
  { "SelectBorder", COLOR, RED},
  { "ButtonColor", COLOR, BLUE},
  { "PressedColor", COLOR, GREEN},
  { "SecondCoder12Key", BOOL, 0},
}
local ActiveChannel = 1
local ActiveButtonPage = 1
local LastActiveButton = 0
local TimerInUSeconds = 50

--[	####################################################################
--[	Value der Globalen Variable zur Übertragung der Tasten
--[	Taste 1-12 dienen für den 1st Coder 12Keys, Tasten EKMFTaste 1-12
--[ für den 2nd Coder 12Keys
--[	####################################################################
local KeyValues = {
  Neutral = 0,
  Taste1 = 922,
  Taste2 = 768,
  Taste3 = 614,
  Taste4 = 461,
  Taste5 = 307,
  Taste6 = 154,
  Taste7 = -154,
  Taste8 = -307,
  Taste9 = -461,
  Taste10 = -614,
  Taste11 = -768,
  Taste12 = -922,
  Umschaltung = 1020,
  EKMFTaste1 = 1,
  EKMFTaste2 = 2,
  EKMFTaste3 = 3,
  EKMFTaste4 = 4,
  EKMFTaste5 = 5,
  EKMFTaste6 = 6,
  EKMFTaste7 = 7,
  EKMFTaste8 = 8,
  EKMFTaste9 = 9,
  EKMFTaste10 = 10,
  EKMFTaste11 = 11,
  EKMFTaste12 = 12,
}

--[	####################################################################
--[	Zuordnung der Globalen Variable für aktive Control im Widget
--[	####################################################################
local GlobalVarialble = {
  {GVarName="GV1",
  Index=0,
  Phase=0},
  {GVarName="GV2",
  Index=1,
  Phase=0}
}

local buttonType = {
  pushbutton = "pushbutton",
  togglebutton = "togglebutton",
  ekmfabutton = "ekmfabutton",
  switch = "switch"
}

--[	####################################################################
--[	Konfiguration der Buttons
--[	Cotrol im Widget (max. 2 Stk.)
--[	 -> Pages (max. 1 Stück)
--[	   -> Buttons max. 12 Stk./Page
--[	####################################################################
local configTable = {
  {
    -- Seite 1 Ebne 1
    {
      { Name="Text", FileName="wMotor.png", Mode=buttonType.pushbutton,ROW=1,COL=1, Value=KeyValues.Taste1 },
      { Name="Text", FileName="wSound.png", Mode=buttonType.pushbutton,ROW=1,COL=2, Value=KeyValues.Taste2 },
      { Name="Text", FileName="wRKL.png",  Mode=buttonType.pushbutton,ROW=1,COL=3, Value=KeyValues.Taste3 },
      { Name="Text", FileName="wWarnblinker.png", Mode=buttonType.pushbutton,ROW=1,COL=4, Value=KeyValues.Taste4 },
      { Name="Text", FileName="wStandlicht.png", Mode=buttonType.pushbutton,ROW=1,COL=5, Value=KeyValues.Taste5 },
      { Name="Text", FileName="wAbblendlicht.png", Mode=buttonType.pushbutton,ROW=1,COL=6, Value=KeyValues.Taste6 },
      { Name="Text", FileName="wFernlicht.png", Mode=buttonType.pushbutton,ROW=2,COL=1, Value=KeyValues.Taste7 },
      { Name="Text", FileName="wNebelscheinwerfer.png", Mode=buttonType.pushbutton,ROW=2,COL=2, Value=KeyValues.Taste9 },
      { Name="Text", FileName="wBlinkLinks.png", Mode=buttonType.pushbutton,ROW=2,COL=3, Value=KeyValues.Taste9 },
      { Name="Text", FileName="wBlinkRechts.png", Mode=buttonType.pushbutton,ROW=2,COL=4, Value=KeyValues.Taste10 },
      { Name="Text", FileName="wMinus.png", Mode=buttonType.pushbutton,ROW=2,COL=5, Value=KeyValues.Taste11 },
      { Name="Text", FileName="wPlus.png", Mode=buttonType.pushbutton,ROW=2,COL=6, Value=KeyValues.Taste12 }
    }
  },
  {
    -- Seite 2 Ebne 1
    {
      { Name="Text", FileName="bMotor.png", Mode=buttonType.ekmfabutton,ROW=1,COL=1, Value=KeyValues.EKMFTaste1 },
      { Name="Text", FileName="bTempomat.png", Mode=buttonType.ekmfabutton,ROW=1,COL=2,Value=KeyValues.EKMFTaste2 },
      { Name="Text", FileName="bSchubbodenEin.png", Mode=buttonType.ekmfabutton,ROW=1,COL=3, Value=KeyValues.EKMFTaste3 },
      { Name="Text", FileName="bSchubbodenAus.png", Mode=buttonType.ekmfabutton,ROW=1,COL=4, Value=KeyValues.EKMFTaste4 },
      { Name="Text", FileName="bMF1.png", Mode=buttonType.ekmfabutton,ROW=1,COL=5, Value=KeyValues.EKMFTaste5 },
      { Name="Text", FileName="bMF2.png", Mode=buttonType.ekmfabutton,ROW=1,COL=6, Value=KeyValues.EKMFTaste6 },
      { Name="Text", FileName="bSattelstuetzeAuf.png", Mode=buttonType.ekmfabutton,ROW=2,COL=1, Value=KeyValues.EKMFTaste7 },
      { Name="Text", FileName="bSattelstuetzeAb.png", Mode=buttonType.ekmfabutton,ROW=2,COL=2, Value=KeyValues.EKMFTaste8 },
      { Name="Text", FileName="bKipperAuf.png", Mode=buttonType.ekmfabutton,ROW=2,COL=3, Value=KeyValues.EKMFTaste9 },
      { Name="Text", FileName="bKipperAb.png", Mode=buttonType.ekmfabutton,ROW=2,COL=4, Value=KeyValues.EKMFTaste10 },
      { Name="Text", FileName="bSattelplatte.png", Mode=buttonType.ekmfabutton,ROW=2,COL=5, Value=KeyValues.EKMFTaste11 },
      { Name="Text", FileName="bSequenz1.png", Mode=buttonType.ekmfabutton,ROW=2,COL=6, Value=KeyValues.EKMFTaste12 }
    }
  }
}

local buttons = {}

--[	####################################################################
--[	Button Zustand. Gedrückt oder nicht.
--[	####################################################################
local buttonState = {
  active = "active",
  inactive = "inactive"
}


--[	####################################################################
--[	write logfile
--[	####################################################################
local function write_log(message, create)
--    local write_mode = "a"
--      if create ~= true then
--        write_mode = "a"
--      else
--        write_mode = "w"
--      end
--			local file = io.open(log_filename, write_mode)
--			io.write(file, message, "\r\n")
--			io.close(file)
end

--[#####################################################################################################
--[ CallBackFunktion wird aufgerufen wenn ein Button gedrückt wurde
--[#####################################################################################################
local function CallBackFunktion(ImageButton, widget)
  local Value = ImageButton.globalVarValue
  local EkmfaCount = 0
--  lcd.drawText(0,180,"Button Pressed")

  write_log("Callback\n\tImageButton Name:[" .. ImageButton.ButtonName .. "]"
      .. "\n\tState:[" .. ImageButton.buttonState .. "]"
      .. "\n\tValue:[" .. Value .. "]"
      .. "\n\tType:[" .. ImageButton.buttonType .. "]"
      .. "\n\tbuttonSelected:[" .. tostring(ImageButton.buttonSelected) .. "]"
      .. "\n\tEKMFFireEvent:[" .. tostring(ImageButton.EKMFFireEvent) .. "]"
      .. "\n\tAktivBtnPg:[" .. ActiveButtonPage .. "]"
      , false)

  if ImageButton.buttonState == buttonState.inactive then
    Value = KeyValues.Neutral
    if ActiveButtonPage == 2 and ImageButton.buttonType ~= buttonType.switch then
      ActiveButtonPage = 1
      LastActiveButton = 0
    end
  end

  --[ Ein EKMFA Button wurde gedrückt.
  if ImageButton.buttonType == buttonType.ekmfabutton then
    EkmfaCount = Value

    if ImageButton.buttonSelected == true then --[ Der Button ist ausgewählt/gedrückt
      if ImageButton.EKMFFireEvent == true then --[ Der Button wurde zum wiederholten mal gedrükt um die Funktion auszulösen.
        Value = -1024
      else --[ Der Button wurde zu ersten mal gedrückt. Eine Sonderverarbeitung weiter unten
        Value = 1024;
      end
    else --[ Button wurde losgelassen für die Funktion
--      write_log("Callback EKMFA Button is no more Selected")
      Value = KeyValues.Neutral
      ImageButton.EKMFFireEvent = false
    end
  end

--  write_log("Callback " .. ImageButton.ButtonName .. " State:" .. ImageButton.buttonState .. " Value:" .. Value .. " AktivBtnPg:" .. ActiveButtonPage, false)
  --[ Sonderverarbeitung für die Funktionsauswahl.
  --[ Es wird nun der logische L64 auf die passende Auslösedauer programmiert der auf Globale Varialbe GV2 reagiert.
  if ImageButton.buttonType == buttonType.ekmfabutton
      and ImageButton.EKMFFireEvent == false
      and ImageButton.buttonSelected == true
      and ImageButton.buttonState == buttonState.active then
--    write_log("Callback EKMFA Button Set Switch and GV2 for select the Function :" .. EkmfaCount .. " Value: " .. Value)
    model.setLogicalSwitch(63, {func=LS_FUNC_VEQUAL, v1=getSourceIndex("GV2"), v2=1024, duration=(LSDauer * 2 * EkmfaCount)})
  end
--  write_log("Callback set the Value: " .. Value)
  model.setGlobalVariable(GlobalVarialble[ActiveChannel].Index, GlobalVarialble[ActiveChannel].Phase, Value)

  if Value ~= KeyValues.Neutral then
    if ImageButton.buttonType == buttonType.switch then
      playHaptic(20, 10 )
      playHaptic(20, 0 )
    else
      playHaptic(15, 0 )
    end
  end
end

local function doNothing()
end

--[#####################################################################################################
--[ CreateButton erzeugt einen Pushbutton oder ToggleButton
--[#####################################################################################################
local function CreateButton(Position, WidgetPosition, W, H, ButtonName, Image, ButtonType, globalVarValue, CallBack, flags)
  local self = {
    ButtonName = ButtonName,
    Image = Image,
    position = Position or { x = 0, y = 0, center = {}, bitmapScale = 100, radius = 0 },
    widgetposition = WidgetPosition or { x = 0, y = 0, center = {}, bitmapScale = 100, radius = 0 },
    xmax = Position.x + W,
    ymax = Position.y + H,
    w = W,
    h = H,
    callBack = CallBack or doNothing,
    buttonState = buttonState.inactive,
    buttonType = ButtonType or buttonType.pushbutton,
    buttonSelected = false,
    globalVarValue = globalVarValue or KeyValues.Neutral,
    EKMFFireEvent = false
  }

  function self.draw( event, widget)
    local pos = self.position
    if event == nil then
      pos = self.widgetposition
      if widget.zone.h < 84 then
        lcd.drawText(0,0,"Das Wideget benötigt min. 50% Ansicht in der Hoehe")
        lcd.drawText(0,15,"the widget need min. 50% view in hight")
        -- lcd.drawText(0,30,"Size " .. widget.zone.w .. "/" .. widget.zone.h)
        return
      end
    end

    if self.buttonSelected then
      lcd.drawFilledCircle(pos.center.x, pos.center.y, pos.radius, widget.options.SelectBorder)
    else
      lcd.drawFilledCircle(pos.center.x, pos.center.y, pos.radius, widget.options.Border)
    end

    if self.buttonState == buttonState.inactive then
      lcd.drawFilledCircle(pos.center.x, pos.center.y, pos.radius - 2, widget.options.ButtonColor)
    else
      lcd.drawFilledCircle(pos.center.x, pos.center.y, pos.radius - 2, widget.options.PressedColor)
    end
    lcd.drawBitmap(self.Image, pos.x, pos.y, pos.bitmapScale)
  end

  --[#####################################################################################################
  --[ Eventhandler für einen Button
  --[#####################################################################################################
  function self.onEvent(event, touchState, widget)
    write_log("self.OnEvent is entered at " .. self.ButtonName .. " at active Channel " .. ActiveChannel .. " from ActiveButtonPage " .. ActiveButtonPage ,false)
    if event == nil then -- Widget mode
      -- Draw in widget mode. The size equals zone.w by zone.h
    else -- Full screen mode
      -- Draw in full screen mode. The size equals LCD_W by 
      if event ~= 0 then -- Do we have an event?
        write_log("self.OnEvent in event id:" .. event,false)
        if touchState then -- Only touch events come with a touchState
          write_log("self.OnEvent in touchState.",false)
          if event == EVT_TOUCH_FIRST then
            write_log("self.OnEvent in event State: EVT_TOUCH_FIRST for ButtonType:" .. self.buttonType,false)
            if self.buttonType == buttonType.pushbutton or self.buttonType == buttonType.switch then
              write_log("self.OnEvent Push or Switch Button is pressed." ,false)
              self.buttonState = buttonState.active
            elseif self.buttonType == buttonType.togglebutton then
              write_log("self.OnEvent Toggle Button is pressed." ,false)
              if self.buttonState == buttonState.active then
                self.buttonState = buttonState.inactive
              else
                self.buttonState = buttonState.active
              end
            elseif self.buttonType == buttonType.ekmfabutton and ActiveChannel == 2 then
              write_log("self.OnEvent EKMF Button is pressed." ,false)
              if self.buttonState == buttonState.inactive then
                write_log("self.OnEvent EKMF Button is Inactive, reset all other." ,false)
                model.setGlobalVariable(GlobalVarialble[ActiveChannel].Index, GlobalVarialble[ActiveChannel].Phase, KeyValues.Neutral)
                for i=1, #buttons[ActiveChannel][ActiveButtonPage] do
                  if buttons[ActiveChannel][ActiveButtonPage][i].buttonState == buttonState.active then
                    buttons[ActiveChannel][ActiveButtonPage][i].buttonState = buttonState.inactive
                  end
                end
                write_log("self.OnEvent EKMF Button will be set to Active" ,false)
                self.buttonState = buttonState.active
              else
                self.EKMFFireEvent = true;
              end
            end
            self.buttonSelected = true
            return self.callBack(self, widget)
            -- When the finger first hits the screen
          elseif event == EVT_TOUCH_BREAK then
            write_log("self.OnEvent in event State: EVT_TOUCH_BREAK" ,false)
            if self.buttonType == buttonType.pushbutton or self.buttonType == buttonType.switch then
              self.buttonState = buttonState.inactive
            elseif self.buttonType == buttonType.ekmfabutton and ActiveChannel == 2 then
              write_log("self.OnEvent EKMF Button will fire Event." ,false)
              self.EKMFFireEvent=false;
            end
            self.buttonSelected = false
            return self.callBack(self, widget)
            -- When the finger leaves the screen and did not slide on it
          elseif event == EVT_TOUCH_TAP then
            write_log("self.OnEvent in event State: EVT_TOUCH_TAP Count [" .. touchState.tapCount .. "]" ,false)
            if self.buttonType == buttonType.pushbutton or self.buttonType == buttonType.switch then
              self.buttonState = buttonState.inactive
            end
            self.buttonSelected = false
            return self.callBack(self, widget)

            -- A short tap gives TAP instead of BREAK
            -- touchState.tapCount shows number of taps
          end
        else -- event ~= 0 and touchState == nil: key event
          write_log("self.OnEvent in KeyEvents.",false)
          if event == EVT_ENTER_FIRST then
            write_log("self.OnEvent EVT_ENTER_FIRST.",false)
            if self.buttonType == buttonType.pushbutton or self.buttonType == buttonType.switch then
              self.buttonState = buttonState.active
            elseif self.buttonType == buttonType.togglebutton then
              if self.buttonState == buttonState.active then
                self.buttonState = buttonState.inactive
              else
                self.buttonState = buttonState.active
              end
            end
            return self.callBack(self, widget)
          elseif event == EVT_VIRTUAL_ENTER then
            write_log("self.OnEvent EVT_VIRTUAL_ENTER.",false)
            if self.buttonType == buttonType.pushbutton or self.buttonType == buttonType.switch then
              self.buttonState = buttonState.inactive
            end
            return self.callBack(self, widget)
          end
        end
        write_log("End of Eventcheck at self.OnEnvent", false)
      end
      write_log("End of self.OnEvent.", false)
    end
  end

  return self
end -- CreateButton(...)

local function CalculateFullscreen(row, col, widget)
  local Position = { x = 0, y = 0, center = {}, bitmapScale = 100, radius = 0 }
  local WidgetPosition = { x = 0, y = 0, center = {}, bitmapScale = 100, radius = 0 }

  local Seitenrand = 4
  local WidgetSeitenrand = 1

  Position.x = ((Seitenrand + BitmapWidth) * col) - BitmapWidth
  Position.y = ((Seitenrand + BitmapHeight) * row) - BitmapHeight
  Position.center = {x = (Position.x + BitmapWidth) - (BitmapWidth / 2), y = (Position.y + BitmapHeight) - (BitmapHeight / 2)}
  Position.radius = BitmapWidth / 2

  WidgetPosition.bitmapScale = math.abs(((widget.zone.h / 2) / BitmapWidth ) * 100) - 5
  local ScaledBitmapHight = BitmapWidth / 100 * WidgetPosition.bitmapScale
  local ScaledBitmapWidht = BitmapHeight / 100 *  WidgetPosition.bitmapScale
  WidgetPosition.x = (WidgetSeitenrand + ScaledBitmapHight) * col - ScaledBitmapHight
  WidgetPosition.y = (WidgetSeitenrand + ScaledBitmapWidht) * row - ScaledBitmapWidht
  WidgetPosition.center = {x = WidgetPosition.x + ScaledBitmapHight - (ScaledBitmapHight / 2)
                         , y = WidgetPosition.y + ScaledBitmapWidht - (ScaledBitmapWidht / 2)}
  WidgetPosition.radius = (BitmapWidth / 100 * WidgetPosition.bitmapScale) / 2

  return Position, WidgetPosition
end

--[#####################################################################################################
--[ LoadConfig erzeugt Button aus einer Datenstruktur
--[ Die Radiomaster TX16s hat eine Auflösung von 480px * 272px,
--[ die Summer der Bilder wird nicht geprüft ob sie auch auf den Bildschirm passen. Also bitte vorher rechnen :)
--[ Ändert sich die Bildhöhe muss zwingend die Variable ImageHight oben eingestellt werden.
--[ ====================================================================================================
local function LoadConfig(widget)
  write_log("LoadConfig: Bitmap Width:" .. BitmapWidth .. " BitmapHeight:" .. BitmapHeight,true)


  -- Inititalisieren der Globalenn Variable
  model.setGlobalVariable(GlobalVarialble[ActiveChannel].Index, GlobalVarialble[ActiveChannel].Phase, KeyValues.Neutral)

  model.setLogicalSwitch(63, {func=LS_FUNC_VEQUAL, v1=getSourceIndex("GV2"), v2=1024, duration=1})
  model.setLogicalSwitch(62, {func=LS_FUNC_VEQUAL, v1=getSourceIndex("GV2"), v2=-1024})
  model.setLogicalSwitch(61, {func=LS_FUNC_TIMER,v1=LSTaktzeit,v2=LSTaktzeit, ["and"]=getSwitchIndex("L64")})
  model.setLogicalSwitch(60, {func=LS_FUNC_OR,v1=getSwitchIndex("L62"),v2=getSwitchIndex("L63")})

  buttons = {}
  for channel=1, #configTable do
    buttons[channel] = {}
    write_log("LoadConfig: Channel:" .. channel,false)
    for page=1, #configTable[channel] do
      write_log("LoadConfig: Page:" .. page,false)
      buttons[channel][page] = {}
      for idx=1, #configTable[channel][page] do
        local Position,WidgetPosition = CalculateFullscreen(configTable[channel][page][idx].ROW, configTable[channel][page][idx].COL, widget)
        write_log("LoadConfig: Row:" .. configTable[channel][page][idx].ROW .. "Col:" .. configTable[channel][page][idx].COL .. " x:" .. Position.x .. " y:" .. Position.y, false)
        buttons[channel][page][idx] = CreateButton(Position
                                ,WidgetPosition
                                ,BitmapWidth
                                ,BitmapHeight
                                ,configTable[channel][page][idx].Name
                                ,Bitmap.open("/WIDGETS/TBSSWT/PNG/" .. configTable[channel][page][idx].FileName)
                                ,configTable[channel][page][idx].Mode
                                ,configTable[channel][page][idx].Value
                                , CallBackFunktion)
      end
    end
  end
end

--[#####################################################################################################
--[ findTouch Prüft ob ein Button via Touch oder Enter Button gedrückt wurde
--[#####################################################################################################
local function findTouched(event, touchState, widget)
  local result = false

  if event == nil then -- Widget mode
    -- Draw in widget mode. The size equals zone.w by zone.h
  else -- Full screen mode
    if event ~= 0 then
      if touchState then
        for i=1, #buttons[ActiveChannel][ActiveButtonPage] do
          if touchState.x >= buttons[ActiveChannel][ActiveButtonPage][i].position.x
            and touchState.x <= buttons[ActiveChannel][ActiveButtonPage][i].xmax
            and touchState.y >= buttons[ActiveChannel][ActiveButtonPage][i].position.y
            and touchState.y <= buttons[ActiveChannel][ActiveButtonPage][i].ymax then
            result = true
            write_log("findTouched found at [" .. buttons[ActiveChannel][ActiveButtonPage][i].ButtonName .. "] Type:" ..buttons[ActiveChannel][ActiveButtonPage][i].buttonType, false)
            buttons[ActiveChannel][ActiveButtonPage][i].onEvent(event, touchState, widget);
          end
        end
      else
        if event == EVT_VIRTUAL_NEXT_PAGE or event == EVT_VIRTUAL_PREV_PAGE then
          if widget.options.SecondCoder12Key == 1 then
            if ActiveChannel == 1 then
              ActiveChannel = 2
            else
              ActiveChannel = 1
            end
            playHaptic(10, 5 )
            playHaptic(10, 0 )
          end
        elseif event == EVT_VIRTUAL_NEXT then
          -- Als erstes den TouchState aufheben
          if touchedButton ~= -1 then
            buttons[ActiveChannel][ActiveButtonPage][touchedButton].buttonSelected = false
          end

          if touchedButton == -1 or touchedButton == #buttons[ActiveChannel][ActiveButtonPage] then
            touchedButton = 1
          else
            touchedButton = touchedButton + 1
          end
          buttons[ActiveChannel][ActiveButtonPage][touchedButton].buttonSelected = true
        elseif event == EVT_VIRTUAL_PREV then
          if touchedButton ~= -1 then
            buttons[ActiveChannel][ActiveButtonPage][touchedButton].buttonSelected = false
          end

          if touchedButton == -1 or touchedButton == 1 then
            touchedButton = #buttons[ActiveChannel][ActiveButtonPage]
          else
            touchedButton = touchedButton - 1
          end
          buttons[ActiveChannel][ActiveButtonPage][touchedButton].buttonSelected = true
        elseif event == EVT_VIRTUAL_ENTER or event == EVT_ENTER_FIRST then
          result = true
          if buttons[ActiveChannel][ActiveButtonPage][touchedButton].buttonType == buttonType.switch then
            ActiveButtonPage = 2
            LastActiveButton = getGlobalTimer()["session"]
            write_log("Umschaltung erkannt um:" .. LastActiveButton)
          end
          buttons[ActiveChannel][ActiveButtonPage][touchedButton].onEvent(event, touchState, widget)
        elseif event == EVT_EXIT_FIRST or event == 1540 then
          if touchedButton ~= -1 then
            buttons[ActiveChannel][ActiveButtonPage][touchedButton].buttonSelected = false
          end
        end
      end
    end
    return result
  end
end

local function create(zone, options)
  -- Runs one time when the widget instance is registered
  -- Store zone and options in the widget table for later use


  local widget = {
    zone = zone,
    options = options
  }
  -- Add local variables to the widget table,
  -- unless you want to share with other instances!
  widget.someVariable = 3
  -- Return widget table to EdgeTX
  LoadConfig(widget)
  return widget
end

local function update(widget, options)
  -- Runs if options are changed from the Widget Settings menu
    widget.options = options
end

local function background(widget)
  -- Runs periodically only when widget instance is not visible
end

local function refresh(widget, event, touchState)
  -- Runs periodically only when widget instance is visible
  -- If full screen, then event is 0 or event value, otherwise nil
  findTouched(event, touchState, widget)

  if ActiveButtonPage == 2 and LastActiveButton > 0 then
    if getGlobalTimer()["session"] - LastActiveButton > 10 then
      -- Reset ausführen
      write_log("Automatic Switch-Reset! Inactive Time:" ..  getGlobalTimer()["session"] - LastActiveButton .. "s",false)
      LastActiveButton = 0
      ActiveButtonPage = 1
      playHaptic(20, 10 )
      playHaptic(20, 0 )
    end

  end
  if #buttons > 0 and  #buttons[ActiveChannel] > 0 then
    for i=1, #buttons[ActiveChannel][ActiveButtonPage] do
      buttons[ActiveChannel][ActiveButtonPage][i].draw(event, widget);
    end
  end
end


return {
  name = name,
  options = options,
  create = create,
  update = update,
  refresh = refresh,
  background = background
}