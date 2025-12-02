--!strict

-- Rate Limiter


---------- Types ----------

export type Debounce = (func: () -> nil, duration: number?) -> nil
export type Throttle = (func: () -> nil, duration: number?) -> nil


---------- Local functions ----------

local createThrottle
local createDebounce


----- Throttle -----

-- Creates a wrapped function that when called, throttles future calls for the specified duration.
createThrottle = function(defaultDuration: number)
    local throttled = false
    return function(func: () -> nil, duration: number?)
        if not throttled then
            throttled = true
            func()
            task.wait(duration or defaultDuration)
            throttled = false
        end
    end
end


----- Debounce -----

-- Creates a wrapped function that when called, waits for the specified duration before running the provided function.
-- If the wrapped function is called again while waiting, the original call is cancelled and the duration is resetted.
createDebounce = function(defaultDuration: number)
    local thread: thread?
    return function(func: () -> nil, duration: number?)
        if thread then
            task.cancel(thread)
        end
        thread = task.delay(duration or defaultDuration, func)
    end
end


---------- Module ----------

local Module = {}


----- Module fields -----

Module.createThrottle = createThrottle
Module.createDebounce = createDebounce


---------- Return module ----------

return Module
