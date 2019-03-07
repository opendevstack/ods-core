local cjson = require("cjson")

local _M = {}

function _M.run ()
    -- ngx.log(ngx.ERR, string.format("status %s",ngx.status))
    -- ngx.log(ngx.ERR, string.format("ngx.arg[1] %s",ngx.arg[1]))
    -- ngx.log(ngx.ERR, string.format("ngx.arg[2] %s",ngx.arg[2]))

    if (ngx.status == 500 and not (ngx.arg[1] == nil or ngx.arg[1] == '')) then
        local json_response = cjson.decode(ngx.arg[1])

        if json_response.exception then
            json_response.exception = nil
            ngx.arg[1] = cjson.encode(json_response)
        end
    end

    -- NOTE: setting this to false will pass a second time in this module, so we need to set this to true :)
    ngx.arg[2] = true

end

return _M
