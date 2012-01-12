
--An example of usage
local jsonapi = require "jsonapi"
require "std"


local github = jsonapi.createProxy("https://api.github.com")

local issues, code, response = github:get "/repos/vance-group/vr-jugglua/issues"

prettytostring(issues)
for k, v in pairs(reply) do
	print(k,v)
end
