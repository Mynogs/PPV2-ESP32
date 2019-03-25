
--**************************************************************************$
--* Copyright (C) 2013-2018 Ing. Buero Riesberg - All Rights Reserved
--* Unauthorized copy, print, modify or use of this file, via any medium is
--* strictly prohibited. Proprietary and confidential.
--* Written by Andre Riesberg <andre@riesberg-net.de>
--***************************************************************************/

-- 06.03.2019 12:58:59 AR V1.0a
-- 18.03.2019 10:58:50 AR V1.0b Timer fixed

-- Special hash function.
-- Line endings can be different between windows and ESP32, so ignore CR and LF.
-- ESP32 Lua RTOS don't use int64, so mask out the lower 32 bist
function calcHash(name)
  f = io.open(name, 'r')
  if f then
    local h = 37
    while true do
      local c = f:read(1)
      if not c then
        return h
      end
      local b = c:byte(1)
      if b ~= 10 and b ~= 13 then
        h = ((h * 54059) ~ (b * 76963)) & 0x7FFFFFFF
      end
    end
  end
  return -1
end

target = {
  name = 'ESP32 Lua RTOS',
  lua = 5.3,

  parameter = {
    com = 4,
    baud = 115200,
    powerupStart = false,
  },

  init = function(self)
  end,

  open = function(self)
    gui.add('HTMLInfo', 'Info', self.name, [[
<b>ESP32 running Lua RTOS</b><br><br>
For more informations visit <a href="https://github.com/whitecatboard/Lua-RTOS-ESP32">Lua-RTOS-ESP32</a>
]], {Height = 100})
    gui.add('Edit', 'EditCOM', 'COM port number', {IntegerMode = true})
    gui.add('Edit', 'EditBaud', 'Baud rate', {IntegerMode = true})
    gui.add('CheckBox', 'CheckBoxPowerupStart', 'Start model on power up', {Width = 200})
    gui.set('EditCOM', 'Integer', self.parameter.com)
    gui.set('EditBaud', 'Integer', self.parameter.baud)
    gui.set('CheckBoxPowerupStart', 'Checked', self.parameter.powerupStart)
    gui.add('HTMLLabel', 'HTMLLabel1', [[
<b>Note:</b><br>Don't set this option during development!<br>
If this option is set you have to press CTRL-D in a terminal program<br>
during boot process of the board to interrupt autostart.
    ]], {Left = 150, Width = 400, Height = 80})
  end,

  apply = function(self)
    self.parameter.com = gui.get('EditCOM', 'Integer')
    self.parameter.baud = gui.get('EditBaud', 'Integer')
    self.parameter.powerupStart = gui.get('CheckBoxPowerupStart', 'Checked')
  end,

  close = function(self)
  end,

  generate = function(self, what)
--    if what == 'GENERATOR_REQUIRE' then
--      return [[
--token = {set = function() end, get = function() end}
--      ]]
--    end
    if what == 'GENERATOR_MAIN' then
--[[    
      return [[
do
  print('Start p+ simulation ' .. (sim.stepRateS * 1000) .. 'ms cycle time')
  print('Using delayms() function')
  while true do
    if sim.cycle then
      sim.cycle(true)
    end
    block.step()
    collectgarbage()
    sim.step = sim.step + 1
    sim.stepT0 = sim.stepT0 + 1
    sim.timeS = sim.timeS + sim.stepRateS
    if sim.cycle then
      sim.cycle(false)
    end
    tmr.delayms(sim.stepRateS * 1000)
  end
end
    ]]
--]]      
---[[
      return [[
do
  local co = coroutine.create(
    function()
      while true do  
        coroutine.yield()
        if sim.cycle then
          sim.cycle(true)
        end
        block.step()
        collectgarbage()
        sim.step = sim.step + 1
        sim.stepT0 = sim.stepT0 + 1
        sim.timeS = sim.timeS + sim.stepRateS
        if sim.cycle then
          sim.cycle(false)
        end
      end
    end
  )
  print('Start p+ simulation ' .. (sim.stepRateS * 1000) .. 'ms cycle time')
  local t = tmr.attach(
    tmr.TMR0,
    math.floor(sim.stepRateS * 1000000),
    function()
      if coroutine.status(co) == 'suspended' then
        coroutine.resume(co)
      end
    end
  )
  t:start()
  while true do 
    tmr.sleepms(1)
  end
end
    ]]
--]]      
--[[
      return [[
do
  local trigger = 0
  print('Start p+ simulation ' .. (sim.stepRateS * 1000) .. 'ms cycle time')
  local t = tmr.attach(
    tmr.TMR0,
    math.floor(sim.stepRateS * 1000000),
    function()
      trigger = trigger + 1
      print('#', trigger)
    end
  )
  t:start()
  while true do  
    print('*', trigger)
    if sim.cycle then
      sim.cycle(false)
    end
    while trigger <= 0 do end
    if sim.cycle then
      sim.cycle(true)
    end
    trigger = 0
    block.step()
    collectgarbage()
    sim.step = sim.step + 1
    sim.stepT0 = sim.stepT0 + 1
    sim.timeS = sim.timeS + sim.stepRateS
  end
end
    ]]
--]]      
--[[
      return [[
do
  print('Start p+ simulation ' .. (sim.stepRateS * 1000) .. 'ms cycle time')
  local t = tmr.attach(
    tmr.TMR0,
    math.floor(sim.stepRateS * 1000000),
    function()
      if sim.cycle then
        sim.cycle(true)
      end
      block.step()
      collectgarbage()
      sim.step = sim.step + 1
      sim.stepT0 = sim.stepT0 + 1
      sim.timeS = sim.timeS + sim.stepRateS
      if sim.cycle then
        sim.cycle(false)
      end
    end
  )
  t:start()
end
    ]]
--]]      
    end
  end,

--[[
do
  print('Start p+ simulation ' .. (sim.stepRateS * 1000) .. 'ms cycle time')
  local t = tmr.attach(
    tmr.TMR0,
    math.floor(sim.stepRateS * 1000000),
    function()
      block.step()
      collectgarbage()
      sim.step = sim.step + 1
      sim.stepT0 = sim.stepT0 + 1
      sim.timeS = sim.timeS + sim.stepRateS
    end
  )
  t:start()
end

do
  print('Start p+ simulation ' .. (sim.stepRateS * 1000) .. 'ms cycle time')
  while true do
    block.step()
    collectgarbage()
    sim.step = sim.step + 1
    sim.stepT0 = sim.stepT0 + 1
    sim.timeS = sim.timeS + sim.stepRateS
    tmr.delayms(sim.stepRateS * 1000)
  end
end



--]]


  inject = function(self, files)
    --print('hash', injector.hash('hallo'))
    local sys = require 'sys'
    local token = require 'token'
    local serial = require 'serial'

    sys.debug('Injector start')

    injector.needPPVersion(2, 2, 'c')
    injector.assert(
      injector.projectHasFlags('RunInRealtime', 'Endless', 'SaveMemory'),
      "Injector needs project options 'RunInRealtime', 'Endless' and 'SaveMemory'"
    )

    injector.closeLuaConsole('ESP32 board COM' .. self.parameter.com);

    local esp = serial.new(self.parameter.com)
    esp:open(self.parameter.baud, 8, 'N', 1)

    local function s(s)
      local results = {}
      --sys.debug('#'..s)
      esp:send(s .. '\r\n')
      for i = 1, 10000 do
        local recv = esp:recv('\r\n')
        sys.sleep(0.001)
        if recv then
          results[#results + 1] = recv
          --sys.debug('##'..recv)
          if recv == '/ > ' then
            return results
          end
        end
      end
      injector.assert(false, 'Receive timeout')
    end

    esp:recv()
    for i = 1, 3 do
      esp:send(string.char(3))
    end
    repeat
      sys.sleep(0.2)
    until esp:recv()

    for i = 1, #files do
      local f = io.open(files[i].host, 'rb')
      injector.assert(f, 'Can\'t open ' .. files[i].host)
      injector.assert(f:read(1) ~= 27, 'Injector don\'t support precompiled files')
    end

    -- Count the total number of lines
    -- and the size of all files
    local lineCounts = {}
    local fileSizes = {}
    local lineCountTotal = 0
    for i = 1, #files do
      local lineCount, fileSize = 0, 0
      for line in io.lines(files[i].host) do
        lineCount = lineCount + 1
        fileSize = fileSize + line:len() + 1
      end
      lineCounts[files[i].remote] = lineCount
      fileSizes[files[i].remote] = fileSize
      lineCountTotal = lineCountTotal + lineCount
    end

    local pb = injector.addProgressBar('Upload progress', lineCountTotal, false)
    local fl = injector.addFileList('Files')

    local dirs = {}
    local lineCount = 0
    for i = 1, #files do
      local hash1 = calcHash(files[i].host)
      local dir = string.match('/' .. files[i].remote, '^(/.+/)')
      if dir and not dirs[dir] then
        s("os.mkdir('" .. dir .. "')")
        dirs[dir] = true
      end
      --s("os.remove('" .. files[i].remote .. "')")
      s("collectgarbage()")
      
      print('hash[', files[i].remote)
      local results = s([[f=io.open('/]] .. files[i].remote .. [[','r') if f then local h=37 while true do local c=f:read(1) if not c then print(h) break end local b=c:byte(1) if b~=10 and b~=13 then h=((h*54059)~(b*76963))&0x7FFFFFFF end end end]])
      --for i = 1, #results do
      --  print(i, results[i])
      --end
      --print(']')
      local hash2 = tonumber(results[2])
      if hash1 ~= hash2 then
        injector.addFile(fl, files[i].remote, 'Upload ' .. lineCounts[files[i].remote] .. ' lines')
        print('Different test', files[i].remote, 'here', hash1, 'there', hash2)
        sys.sleep(0.1)
        s("f = io.open('/" .. files[i].remote .. "','w+')")
        for line in io.lines(files[i].host) do
          --print(line)       
          s("f:write(" .. injector.wrapString(line) .. "..string.char(10))")
          lineCount = lineCount + 1
          injector.setProgressBar(pb, lineCount)
          sys.sleep(0.1)
        end
        s("f:close()")
        local results = s([[f=io.open('/]] .. files[i].remote .. [[','r') if f then local h=37 while true do local c=f:read(1) if not c then print(h) break end local b=c:byte(1) if b~=10 and b~=13 then h=((h*54059)~(b*76963))&0x7FFFFFFF end end end]])
        local hash3 = tonumber(results[2])
        if hash1 ~= hash3 then
          print('Different verify', files[i].remote, 'here', hash1, 'there', hash3)
          injector.assert(hash1 == hash3, 'File verify fail ' .. files[i].remote)
        end  
        
        --token.set('.upload:' .. files[i].host, tostring(hash))
      else
        injector.addFile(fl, files[i].remote, '<b>Already exists</b>')
        print('Equal', files[i].remote)
        lineCount = lineCount + lineCounts[files[i].remote]
        injector.setProgressBar(pb, lineCount)
      end
    end
    injector.setProgressBar(pb, lineCountTotal)

    local lineGetter = coroutine.create(
      function ()
        do
          local s = ''
          while true do
            s = s .. esp:recv()
            local p = s:find('\n')
            while p do
              coroutine.yield(s:sub(1, p - 1))
              s = s:sub(p + 1)
              p = s:find('\n')
            end
            sys.sleep(0.01)
          end
        end
      end
    )

    --for k, v in pairs(fileSizes) do
    --  print('->', k, v)
    --end

    --[[
    sys.sleep(0.2)
    esp:recv()
    s("do local l = file.list() for k,v in pairs(l) do print(k..':'..v) end print('#') end")
    local errorCount = 0
    while true do
      local _, line = coroutine.resume(lineGetter)
      if line:byte() == 35 then
        break
      end
      local name, size = line:match('^(.*):(%d+)')
      if fileSizes[name] then
        if fileSizes[name] ~= tonumber(size) then
          errorCount = errorCount + 1
        end
      end
    end
    if errorCount > 0 then
      injector.addLabel('<FONT size="10"><FONT color="#FF0000"><b>File size wrong on ' .. errorCount .. ' uploaded files!</b></FONT></FONT>')
    else
      injector.addLabel('<FONT size="10"><FONT color="#008000"><b>Success</b></FONT></FONT>')
    end
    --]]

    if self.parameter.powerupStart then
      s("f = io.open('autorun.lua','w+')")
      s("f:writeline([[dofile('startup.lua')]])")
      s("f:close")
    else
      s("os.remove('ini.lua')")
    end

    injector.addLabel('<b>Reboot target board</b>')
    esp:recv()
    esp:send('os.exit(true, true)\r\n')
    sys.sleep(1.5)
    local restartMessage = esp:recv()

    injector.addLabel('<b>Start</b> <i>startup.lua</i>')
    esp:send("dofile('startup.lua')\r\n")
    esp:close()

    injector.addLabel('<FONT size="10"><FONT color="#000080"><b>Redirect boards output (COM' .. self.parameter.com .. ') to console.</b></FONT></FONT>')
    do
      source = [[
print([=[RESTARTMESSAGE]=])
local sys = require 'sys'
local serial = require 'serial'
local esp = serial.new(COM)
esp:open(BAUD, 8, 'N', 1)
do
  while true do
    local recv = esp:recv('\r\n')
    if recv then
      print(recv)
    else
      sys.sleep(0.01)
    end
  end
end
]]
      restartMessage = restartMessage:gsub('[\000-\009]', '')
      restartMessage = restartMessage:gsub('[\011-\031]', '')
      restartMessage = restartMessage:gsub('[\128-\255]', '')
      local replaces = {
        ['RESTARTMESSAGE'] = restartMessage,
        ['BAUD'] = self.parameter.baud,
        ['COM'] = self.parameter.com,
      }
      source = source:gsub('%a+', replaces)
      injector.spanLuaConsole('ESP32 board COM' .. self.parameter.com, source, 'GreenYellow', 'Black');
    end

  end,
}

--[[
spi
require
uart
fs
gdisplay
_G
nvs
i2c
neopixel
ulp
can
mangle
debug
servo
mqtt
thread
bt
adc
pack
pio
tmr
f
sensor
pwm
event
encoder
stepper
foralli
utf8
package
table
string
os
net
coroutine
math
block
__index
cpu
io
sim

os.
  date
  difftime
  clock
  remove
  rename
  time
  tmpname
  exit
  execute
  setlocale
  getenv
  factoryreset
  partitions
  passwd
  uptime
  locks
  exists
  stdout
  clear
  cpu
  board
  sleep
  version
  ls
  cd
  pwd
  mkdir
  logcons
  loglevel
  stats
  format
  history
  shell
  cp
  cat
  more
  dmesg
  run
  luarunning
  luainterpreter
  resetreason
  bootcount
  flashEUI
  edit
  LOG_INFO
  LOG_EMERG
  LOG_ALERT
  LOG_CRIT
  LOG_ERR
  LOG_WARNING
  LOG_NOTICE
  LOG_DEBUG
  LOG_ALL
--]]





