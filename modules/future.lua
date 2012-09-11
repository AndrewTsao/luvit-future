-- Luvit port of Dart Future
-- Future must not stop, all callbacks be called with protected.

local Object = require("core").Object
local traceback = require("debug").traceback

local Future = Object:extend() 
local Completer = Object:extend()

function Future:initialize()
  -- _ok
  -- _val
  -- _isComplete
  -- _callbacks
end

function Future.immediate(ok, val)
  local future = Future:new()
  future:_setValue(ok, val)
  return future
end

function Future:_setValue(ok, val)
  if self._isComplete then
    error("future already complete")
  end
  self._ok = ok 
  self._val = val 
  self:_complete()
end

local function try(callback, ok, val)
  local _, err = xpcall(callback, traceback, ok, val)
  if not _ then
    _, err = xpcall(callback, traceback, false, err)
  end
  return _, err
end

function Future:on(callback)
  if self._isComplete then
    local _, err = try(callback, self._ok, self._val)
    if not _ then print('[FUTURE]:', err) end
  else
    local callbacks = self._callbacks or {}
    callbacks[#callbacks+1] = callback
    self._callbacks = callbacks
  end
  return self
end

function Future:_complete()
  self._isComplete = true
  local ok, val = self._ok, self._val
  
  local callbacks = self._callbacks
  if not callbacks or #callbacks == 0 then return end
  
  -- callback won't changed listeners dynamically. otherwise, enumerate callbacks failed.
  for k, callback in ipairs(callbacks) do
    local _, err = try(callback, ok, val)
    if not _ then print(err) end
  end
end

function Future:transform(transformation)
  local completer = Completer:new()
  self:on(function(ok, val)
    local nok, nval
    local _, err = try(function(ok, val)
      nok, nval = transformation(ok, val)
    end, ok, val)
    if not _ then
      completer:complete(_, err)
    else
      completer:complete(nok, nval)
    end
  end)
  return completer:getFuture()
end

function Future:chain(transformation)
  local completer = Completer:new()
  self:on(function(ok, val)
    local future
    local _, err = try(function (ok, val)
      future = transformation(ok, val)
    end, ok, val)

    if not _ then
      future = Future.immediate(false, err)
    end

    future:on(function(ok, val)
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
    future:on(function(ok, val)
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

