-- app.lua

local lapis = require('lapis')
local json_params = require('lapis.application').json_params

local cjson = require('cjson')

local api_url = assert(os.getenv('API_URL'), "Missing API_URL environment variable")
local chat_id = assert(os.getenv('CHAT_ID'), "Missing CHAT_ID environment variable")
local bot_token = assert(os.getenv('BOT_TOKEN'), "Missing BOT_TOKEN environment variable")
local icons = { fire = '\xF0\x9F\x94\xA5', smile = '\xF0\x9F\x98\x83' }
local uri = api_url .. 'bot' .. bot_token .. '/sendMessage'

local app = lapis.Application()

app:get('/', function(self)
	return {
		json = {
			name = "levar",
			version = 0.1
		}
	}
end)

app:post('/', json_params(function(self)

	local alert = self.params
	local status = alert.status == 'firing' and icons.fire or icons.smile

	local httpc = require("resty.http").new()
	httpc:set_proxy_options({
		http_proxy = os.getenv('HTTP_PROXY'),
		https_proxy = os.getenv('HTTPS_PROXY'),
		no_proxy = os.getenv('NO_PROXY')
	})

	local res, err = httpc:request_uri(uri, {
		method = "POST",
		body = cjson.encode({
			chat_id = chat_id,
			parse_mode = 'Markdown',
			text = string.format('*%s* %s\n*Namespace: *%s\n%s',
				alert.commonLabels.alertname,
				status,
				alert.commonLabels.namespace,
				alert.commonAnnotations.summary
			)
		}),
		headers = {["Content-Type"] = "application/json"},
		ssl_verify = false
	})

	httpc:close()

	if not res then
		ngx.log(ngx.ERR, err)
		return {{ json = err }, status = 500 }
	elseif res.status ~= 200 then
		ngx.log(ngx.ERR, res.body)
		return { json = res.body, status = res.status }
	else
		return { json = res }
	end
end))

function app:handle_error(err, trace)
	ngx.log(ngx.ERR, err, trace)
	return { json = {message = "An error happened, please see the logs"}, status = 500 }
end

return app
