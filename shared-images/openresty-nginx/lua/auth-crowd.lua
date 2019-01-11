require("utils")

local _M = {}

function _M.run ()
    -- grab auth header
    local auth_header = ngx.req.get_headers().authorization

    -- check that the header is present, and if not sead authenticate header
    if not auth_header or auth_header == '' or not string.match(auth_header, '^[Bb]asic ') then
        local hWWWAuth = string.format('Basic realm="%s"', os.getenv("CROWD_REALM_NAME"))
        ngx.log(ngx.DEBUG,  string.format("no auth header provided --> basic realm set to: %s", hWWWAuth))

        ngx.header['WWW-Authenticate'] = hWWWAuth
        ngx.header.content_type = "text/plain"
        ngx.status = ngx.HTTP_UNAUTHORIZED
        ngx.say("UNAUTHORIZED")
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    -- decode authenication header and verify its good
    local userpass = string.splitBy(ngx.decode_base64(string.splitBy(auth_header, ' ')[2]), ':')

    if not userpass or #userpass ~= 2 then
        ngx.log(ngx.ERR,  string.format("No auth provided. Bad request."))
        ngx.header.content_type = "text/plain"
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say("BAD_REQUEST")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    ngx.log(ngx.DEBUG,  string.format("received auth --> %s:**** (length: %s)", userpass[1],table.getn(userpass)))

    -- authenticate against crowd
    local http = require("resty.http")
    local httpc = http.new()
    local path = string.format("/rest/usermanagement/1/authentication?username=%s", userpass[1])
    local fullpath = string.format("%s%s", os.getenv("CROWD_URL"), path)
    local userPass = string.format("%s:%s", os.getenv("CROWD_SERVICE"), os.getenv("CROWD_PASSWORD"))
    local userPassEnc64 = ngx.encode_base64(userPass)
    local authBasicHeader = string.format("Basic %s", userPassEnc64)
    local payload = string.format('{"value":"%s"}', userpass[2])

    ngx.log(ngx.DEBUG,  string.format("crowd auth --> %s -- auth: %s", fullpath, authBasicHeader))

    local res, err = httpc:request_uri(fullpath, {
        method = "POST",
        body = payload,
        headers = {
            ["Authorization"] = authBasicHeader,
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
            ["Content-Length"] = payload:len(),
        },
        keepalive_timeout = 60,
        keepalive_pool = 10
    })

    -- error out if not successful
    if not res then
        ngx.log(ngx.ERR,  string.format("No response. Crowd Auth error: %s", err))
        ngx.header.content_type = "text/plain"
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say("FORBIDDEN")
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end
    if res.status ~= 200 then
        ngx.log(ngx.ERR,  string.format("Crowd Auth error. HTTP status code: %s", res.status))
        ngx.header.content_type = "text/plain"
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say("FORBIDDEN")
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    -- no error out, so let's proceed with the proxy
    ngx.log(ngx.DEBUG,  string.format("crowd res --> %s -- err: %s", res.status, err))
end

return _M
