require("utils")
local cjson = require("cjson")

local _M = {}

function _M.run (server_signature)

    local method = ngx.req.get_method()
    local uri = ngx.var.uri
    local access_granted_by_uri = false
    local access_granted_by_method = false

    -- ngx.log(ngx.ERR, string.format("%s",method))
    -- ngx.log(ngx.ERR, string.format("%s",uri))

    -- TODO: add env var parameter ENVIRONMENT so we can enable/disable methods/uris by ENVIRONMENT

    local accepted_uris = {
        { ["has_to_match"] = true, ["uri"] = "/oauth/token" },
        { ["has_to_match"] = true, ["uri"] = "/oauth/revoke" },
        { ["has_to_match"] = false, ["uri"] = "/api/v1/users" },
        { ["has_to_match"] = false, ["uri"] = "/api/v1/assessments" },
        { ["has_to_match"] = false, ["uri"] = "/api/v1/companies" },
    }

    -- TODO: we can add here an object-like structure so to assign which indexes have specific methods
    local accepted_methods = {
        [1] = "OPTIONS",
        [2] = "GET",
        [3] = "POST",
        [4] = "PUT",
        [5] = "DELETE",
    }

    for _, accepted_uri in ipairs(accepted_uris) do
        -- exact URI matching
        if accepted_uri.has_to_match then
            if uri == accepted_uri.uri then
                access_granted_by_uri = true
            end
        -- non-exact URI matching
        else
            if string.startsWith(uri, accepted_uri.uri) then
                access_granted_by_uri = true
            end
        end
    end

    for _, accepted_method in ipairs(accepted_methods) do
        if method == accepted_method then
            access_granted_by_method = true
        end
    end

    if (access_granted_by_uri and access_granted_by_method) then
        return
    else
        ngx.log(ngx.ERR, string.format("Not accepted METHOD and URI convination: %s - %s", method, uri))
        -- ngx.header.content_type = "text/plain"
        -- ngx.status = ngx.HTTP_FORBIDDEN
        -- ngx.say("Forbidden")
        -- return ngx.exit(ngx.HTTP_FORBIDDEN)
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.header.content_type = "application/json; charset=utf-8"
        ngx.say(cjson.encode({ timestamp = os.time(os.date("!*t")), status = ngx.HTTP_FORBIDDEN, error = "Forbidden", message = "Access Denied", path = ngx.var.uri, server = server_signature }))
        return ngx.exit(ngx.HTTP_FORBIDDEN)
    end

end

return _M
