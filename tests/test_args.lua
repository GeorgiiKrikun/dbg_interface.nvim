local DebugArguments = require('dbg_interface.DbgArguments')
local MiniTest = require('mini.test')

-- 1. Initialize the test set
local T = MiniTest.new_set({
    localize = false, -- Set to true if you want tests to run in a separate process
})

-- 2. Define a nested set for organizational clarity
T['DebugArguments'] =  MiniTest.new_set()

T['DebugArguments']['init_py'] = function()
    local args = DebugArguments:new({
        args = {"--hello", "world", "-d", "zalupa33"}
    })
    
    MiniTest.expect.equality(args.alias, "--hello world -d zalupa33")
end

return T



