package = "lua-webapiclient"
version = "scm-1"
description = {
  summary = "A proxy-based interface for REST-style web APIs";
  homepage = "https://github.com/rpavlik/lua-webapiclient";
}
source = {
  url = "git://github.com/rpavlik/lua-webapiclient.git"
}
dependencies = {
   "lua ~> 5.1";
   "luasocket";
   "json4lua";
}
build = {
  type = "builtin";
  modules = {
    jsonapi = "jsonapi.lua";
    https = "https.lua";
  }
}
