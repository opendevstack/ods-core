require("utils")

local _M = {}

function _M.run ()

    local authorization = ngx.var.http_authorization

    -- ngx.log(ngx.DEBUG,  string.format("\t received auth --> %s", authorization))

    if isEmpty(authorization) then
        ngx.log(ngx.DEBUG, "Empty authorization header")
        return
    end

    if not isBasic(authorization) then
        ngx.log(ngx.DEBUG, "Not basic auth - authorization=", authorization)
        return
    end

    local basicb64 = string.sub(authorization, 7)
    if isEmpty(basicb64) then
        ngx.log(ngx.DEBUG, "Empty basic auth - authorization=", authorization)
        return
    end

    local basic = ngx.decode_base64(basicb64)
    if isEmpty(basic) then
        ngx.log(ngx.DEBUG, "Couldn't decode base64 - basicb64=", basicb64)
        return
    end

    local user = getUserFromBasic(basic)
    if isEmpty(user) then
        ngx.log(ngx.DEBUG, "Couldn't extract user from basic auth - basic=", basic)
        return
    end

    local client_id = os.getenv("BE_GATEWAY_SERVICE_CLIENT_ID")
    if user == client_id then
    else
        ngx.log(ngx.ERR, "user value does not match expected value for clientID, received value is: ", user)
        return
    end

    local client_secret = os.getenv("BE_GATEWAY_SERVICE_CLIENT_SECRET")
    local userPass = string.format("%s:%s", client_id, client_secret)
    local basicEnc64 = ngx.encode_base64(userPass)
    local basicHeader = string.format("Basic %s", basicEnc64)

    -- ngx.log(ngx.DEBUG,  string.format("\t rewrited auth --> %s", basicHeader))

    ngx.req.set_header("Authorization", basicHeader)

end

return _M
