worldboss = {}

function worldboss.isActive()
	return false
end

function worldboss.enter()
	Message.sendPost('get','worldboss','{}',function (jsonData)
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		local data = jsonDic['data']
		wBossData:updateData(data)

		if data.boss then
			genWorldBossBattlePanel()
		else
			genWbossMainPanel()
		end
	end)
end