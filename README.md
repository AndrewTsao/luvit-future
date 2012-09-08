luvit-future
============

Luvit port of Dart Future

Example
=======

```
local timer = require("timer")
local Future = require("future").Future
local Completer = require("future").Completer

local function getTimeoutFuture()
  local completer = Completer:new()
  timer.setTimeout(1000, function()
    completer:complete(true, 100)
  end)
  return completer:getFuture()
end

getTimeoutFuture()
:on("then", function(ok, val)
  if ok then
    p(val)
  else
    p("error!", val)
  end
end)
:transform(function(ok, val)
  if not ok then
    return ok, val
  end
  return ok, val + 100
end)
:chain(function(ok, val)
  if not ok then
    return Future.immediate(false, val) 
  end
  local completer = Completer:new()
  timer.setTimeout(100, function()
    completer:complete(true, val .. " wait 100ms")
  end)
  return completer:getFuture()
end)
:on("then", print)

-- An immediate future
f = Future.immediate(true, 'immediate')
f:on("then", print)
```