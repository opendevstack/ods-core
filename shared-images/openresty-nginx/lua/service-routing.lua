local uri = ngx.var.uri
local service_X_target = string.format("%s:%s", os.getenv("BE_SERVICE_X_HOST"), os.getenv("BE_SERVICE_X_PORT"))
local service_Y_target = string.format("%s:%s", os.getenv("BE_SERVICE_Y_HOST"), os.getenv("BE_SERVICE_Y_PORT"))
local target = "none"

-- ngx.log(ngx.ERR, string.format("%s",service_X_target))
-- ngx.log(ngx.ERR, string.format("%s",service_Y_target))
-- ngx.log(ngx.ERR, string.format("%s",target))

local routing_uris = {
    { ["uri"] = "/oauth/token", ["target"] = service_X_target },
    { ["uri"] = "/api/v1/data", ["target"] = service_X_target },
    { ["uri"] = "/api/v1/more", ["target"] = service_X_target },
    { ["uri"] = "/api/v1/special", ["target"] = service_Y_target },
}

for _, routing_uri in ipairs(routing_uris) do
    if string.startsWith(uri, routing_uri.uri) then
        target = routing_uri.target
    end
end

-- ngx.log(ngx.ERR, string.format("%s",target))

return target
