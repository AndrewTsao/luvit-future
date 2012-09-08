luvit-future
============

Luvit port of [Dart Future](http://api.dartlang.org/docs/continuous/dart_core/Future.html)

Follow then lua return style, our Future always has an `ok` flag and a `value`, when future failed, `then` callback will called
with `false` and error message, otherwise `true` and `value`.

Example
=======

```lua
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
:on("then", p)

-- An immediate future
f = Future.immediate(true, 'immediate')
f:on("then", p)

-- wait futures
f = wait(getTimeoutFuture(), getTimeoutFuture())
f:on("then", p)
```