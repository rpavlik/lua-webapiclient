--[[ Module usage:

local jsonapi = require "jsonapi"

This provides access to two table entries:
  jsonapi.createProxy(url) (or eventually jsonapi.createProxy{url = "...", username = "...", password = "..."} )
returns a proxy for accessing JSON-based web services, starting with your given URL prefix.

  jsonapi.universal is a proxy that has no URL prefix, so it can be used with a full URL if you just want a one-off call.

Calls take one of the following forms, given that p is a proxy
  p:httpverb()
  p:httpverb apipath
  p:httpverb(apipath, jsontable)

where httpverb is any http verb (we'll uppercase it for you), apipath will
be appended to the URL prefix for the proxy if given, and jsontable is a table
whose contents will be converted into json and submitted with your request.

All such calls return up to four values, in this order:
  result: the table decoded from the server's json reply, or nil if no (valid) json returned.
  code: the HTTP result code (like 200, 404, etc.)
  httpresponse: the full text of the http response.
  err: If there was an error in parsing the server's json reply, details are here.
]]

-- HTTP access code based on:
-----------------------------------------------------------------------------
-- JSONRPC4Lua: JSON RPC client calls over http for the Lua language.
-- json.rpc Module.
-- Author: Craig Mason-Jones
-- Homepage: http://json.luaforge.net/
-- Version: 0.9.40
-- This module is released under the MIT License (MIT).
-- Please see LICENCE.txt for details.
--
-- REQUIREMENTS:
--  Lua socket 2.0 (http://www.cs.princeton.edu/~diego/professional/luasocket/)
--  json (The JSON4Lua package with which it is bundled)
--  compat-5.1 if using Lua 5.0.
------------------------------------------------------------------

local json = require('json')
local http = require("socket.http")
local ltn12 = require('ltn12')
local mime = require("mime")

local fixupHTTPS = function(request)
  local socketurl = require("socket.url")
  local parsed = socketurl.parse(request.url)
  if parsed.scheme == "https" then
    local https = require "https"
    request.create = https.create
    if parsed.port == nil then
      parsed.port = 443
    end
    request.url = socketurl.build(parsed)
  end
end

local metat = { __index = {} }

metat.__index.get_url = function(self, path)
  local url = {}
  if self.baseurl then
    table.insert(url, self.baseurl)
  end
  if path ~= nil then
    table.insert(url, path)
  end
  if #url == 0 then
    error("Can't perform a request without a path!", 2)
  end
  return table.concat(url)
end

metat.__index.send_request = function(self, verb, path, input)
  local httpResponse, result, code
  local jsonRequest
  if input then
    jsonRequest = json.encode(input)
  end

  -- We use the sophisticated http.request form (with ltn12 sources and sinks) so that
  -- we can set the content-type to text/plain. While this shouldn't strictly-speaking be true,
  -- it seems a good idea (Xavante won't work w/out a content-type header, although a patch
  -- is needed to Xavante to make it work with text/plain)

  local resultChunks = {}

  local request = {
    sink = ltn12.sink.table(resultChunks),
    method = verb,
    url = self:get_url(path)
  }

  fixupHTTPS(request)

  if jsonRequest then
    request.headers = { ['content-type']='text/plain', ['content-length']=string.len(jsonRequest) }
    request.source = ltn12.source.string(jsonRequest)
  end

  httpResponse, code = http.request(request)

  httpResponse = table.concat(resultChunks)

  -- Check the http response code
  if (code<200 or code > 299) then
    error("HTTP ERROR: " .. code .. "\n" .. httpResponse)
  end

  -- And decode the httpResponse and check the JSON RPC result code
  local status, result = pcall(json.decode, httpResponse)
  if not status then
    return nil, code, httpResponse, result
  end

  return result, code, httpResponse
end

local index_to_request = function(self, verb)
  return function(self, ...)
    return self:send_request(verb:upper(), ...)
  end
end

setmetatable(metat.__index, {
  __index = index_to_request
})

local function createProxy(url)
  return setmetatable({["baseurl"] = url}, metat)
end

local universal = setmetatable({}, metat)

return {
  ["createProxy"] = createProxy,
  ["universal"] = universal
}

