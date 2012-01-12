-- from mailing list code http://lua-users.org/lists/lua-l/2009-02/msg00270.html


local socket = require "socket"
local ssl = require "ssl"

local params = {
    mode = "client",
    protocol = "tlsv1",
    cafile = "/etc/ssl/certs/ca-certificates.crt",
    verify = "peer",
    options = "all",
}

local try = socket.try
local protect = socket.protect

local function create()
    local t = {c=try(socket.tcp())}

    function idx (tbl, key)
        print("idx " .. key)
        return function (prxy, ...)
                   local c = prxy.c
                   return c[key](c,...)
               end
    end


    function t:connect(host, port)
        print ("proxy connect ", host, port)
        try(self.c:connect(host, port))
        print ("connected")
        self.c = try(ssl.wrap(self.c,params))
        print("wrapped")
        try(self.c:dohandshake())
        print("handshaked")
        return 1
    end

    return setmetatable(t, {__index = idx})
end


return { ["create"] = create }
