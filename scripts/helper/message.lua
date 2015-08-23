Message = {}

function Message.sendPost( act, mod, argsJson, response )
	local url = CGlobalData:GetInst():getGameServerUrl()
	CMessageMgr:GetInst():RequestPost2(url, act, mod, argsJson, response)
end


function Message.requestFeedBackPost(content, response)
	CMessageMgr:GetInst():RequestGetFeedBackScriptHandler(content, response)
end