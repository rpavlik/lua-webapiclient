local jsonapi = require "jsonapi"

local github = jsonapi.createProxy("https://api.github.com")

local reply = github:get "/repos/vance-group/vr-jugglua/issues"

for k, v in pairs(reply) do
	print(k,v)
end
