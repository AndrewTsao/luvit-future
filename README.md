luvit-future
============

Luvit port of [Dart Future](http://api.dartlang.org/docs/continuous/dart_core/Future.html)

Follow [lua exception pattern](http://www.lua.org/wshop06/Belmonte.pdf), our Future always has an `ok` flag plus a `value`. if future failed, then 
the `then` callback called with `false` plus string with error message, otherwise `true` plus `value`.

Example
=======

```lua
local Future = require("future").Future
local Completer = require("future").Completer
local wait = require("future").wait

local timer = require("timer")

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
:on("then", p)

-- An immediate future
f = Future.immediate(true, 'immediate')
f:on("then", p)

-- wait futures
f = wait(getTimeoutFuture(), getTimeoutFuture())
f:on("then", p)
```