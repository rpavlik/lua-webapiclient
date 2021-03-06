require "lunatest.lunatest"

function create_github()
	local jsonapi = require "jsonapi"
	return jsonapi.createProxy("https://api.github.com")	
end

function test_github_blank()
	local github = create_github()
	local result, code, response, err = github:get()
	assert_nil(result, "Should return nil since it failed.")
	assert_number(code, "Should always return numeric code.")
	assert_equal(code, 204, "Github returns a 204 for this API call.")
	assert_string(response, "Should always return the http response here.")
	assert_string(err, "Should be returning a json4lua parse error with the empty return value here.")
end

function test_github_issues()
	local github = create_github()
	local result, code, response, err = github:get "/repos/vancegroup/vr-jugglua/issues"
	assert_table(result, "Should always return a table")
	assert_gt(0, #result, "Should actually have stuff in this table.")
	assert_number(code, "Should always return numeric code.")
	assert_equal(code, 200, "Github returns a 200 for this API call.")
	assert_string(response, "Should always return the http response here.")
	assert_nil(err, "Should not have an error.")
end

function test_bad_behavior()
	local jsonapi = require "jsonapi"
	assert_error(function() jsonapi.universal:get() end, "Have to provide a URL somehow.")
end

lunatest.run()
