local timer = require("timer")
local Future = require("future").Future
local Completer = require("future").Completer
local wait = require("future").wait

-- local function getTimeoutFuture(timeout)
--   local completer = Completer:new()
--   timer.setTimeout(timeout, function()
--     completer:complete(true, timeout)
--   end)
--   return completer:getFuture()
-- end
-- 
-- getTimeoutFuture(100)
-- :on(function(ok, val)
--   if ok then
--     p(val)
--   else
--     p("error!", val)
--   end
-- end)
-- :transform(function(ok, val)
--   if not ok then
--     return ok, val
--   end
--   return ok, val + 100
-- end)
-- :chain(function(ok, val)
--   if not ok then
--     return Future.immediate(false, val) 
--   end
--   local completer = Completer:new()
--   timer.setTimeout(100, function()
--     completer:complete(true, val + 100)
--   end)
--   return completer:getFuture()
-- end)
-- :on(function(ok, val)
--   assert(ok == true)
--   assert(val == 300)
-- end)
-- 
-- f = Future.immediate(true, 'immediate')
-- f:on(function(ok, val)
--   assert(ok == true)
--   assert(val == 'immediate')
-- end)
-- 
-- -- wait futures
-- f = wait(getTimeoutFuture(100), getTimeoutFuture(200))
-- f:on(function(ok, val)
--   assert(ok == true)
--   assert(#val == 2)
-- end)
-- 
-- f = wait()
-- f:on(function(ok, val)
--   assert(ok == true)
--   assert(#val == 0)
-- end)

print('sss')
local a = Future.immediate(false, 'hoho')
a:on(p)
a:on(function(ok, val)
  if ok then
    error('not breakable')
  end
end):transform(function(ok, val)
  if ok then error('transform error') end
  return ok, val .. "transformed" 
end):on(print)

