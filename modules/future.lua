-- Luvit port of Dart Future

local Emitter = require("core").Emitter
local Object = require("core").Object

local Future = Emitter:extend()
local Completer = Object:extend()

function Future:initialize()
  -- _ok
  -- _val
  -- _isComplete
end

function Future.immediate(ok, val)
  local future = Future:new()
  future:_setValue(ok, val)
  return future
end

function Future:getValue()
  if not self._isComplete then
    error("future not complete")
  end
  return self._ok, self._val
end

function Future:_setValue(ok, val)
  if self._isComplete then
    error("future already complete")
  end
  self._ok = ok 
  self._val = val 
  self:_complete()
end

function Future:hasValue()
  return self._isComplete
end

function Future:on(name, callback)
  if self._isComplete then
    callback(self._ok, self._val)
  else
    Emitter.on(self, name, callback)
  end
  return self
end

function Future:_complete()
  self._isComplete = true
  self:emit("then", self._ok, self._val)
end

function Future:transform(transformation)
  local completer = Completer:new()
  self:on("then", function(ok, val)
    local ok, val = transformation(ok, val)
    completer:complete(ok, val)
  end)
  return completer:getFuture()
end

function Future:chain(transformation)
  local completer = Completer:new()
  self:on("then", function(ok, val)
    local future = transformation(ok, val)
    future:on("then", function(ok, val)
      completer:complete(ok, val)
    end)
  end)
  return completer:getFuture();
end

function Completer:initialize()
  self._future = Future:new()
end

function Completer:complete(ok, val)
  self._future:_setValue(ok, val)
end

function Completer:getFuture()
  return self._future
end

local function wait(...)
  local completer = Completer:new()
  local futures = {...}
  local len = #futures
  local results = {}
  
  if len == 0 then
    return Future.immediate(true, results)
  end

  for i, future in ipairs(futures) do
    future:on("then", function(ok, val)
      local idx = i
      results[idx] = {ok, val}
      len = len - 1
      if len == 0 then
        completer:complete(true, results)
      end
    end)
  end

  return completer:getFuture()
end

return {
  Future = Future,
  Completer = Completer,
  wait = wait,
}

