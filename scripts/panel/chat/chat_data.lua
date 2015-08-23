ChatData = {
	vecOldData = {{}, {}, {}, {}},
	vecNewData = {{}, {}, {}, {}},
	privateVecOldData = {},
	privateVecNewData = {},
	updatePrivateChat = nil
}

CHAT_CHANNEL = readOnly{
	WORLD = 1,
	LEGION = 2,
	LOUDSPEAKER = 3,
	WORLDBULLETIN = 4
}

function getChatData()
	return ChatData
end

function getPrivateVecNewData()
	return ChatData.privateVecNewData
end

function onChatUpdated(jsonData)
	local jsonDic = json.decode(jsonData)
	local chatTipsVis = false
	if jsonDic.ims ~= nil then
		local imsNum = #jsonDic.ims
		for i = 1, imsNum do
			local worldData = {
				time = UserData:getServerTime(),
				name = jsonDic.ims[imsNum - i + 1].name,
				content = jsonDic.ims[imsNum - i + 1].content,
				uid = jsonDic.ims[imsNum - i + 1].uid or 0,
				vip = jsonDic.ims[imsNum - i + 1].vip or 0
			}
			table.insert(ChatData.vecNewData[CHAT_CHANNEL.WORLD], worldData)
		end
		if imsNum > 0 then
			chatTipsVis = true
		end
	end

	if jsonDic.headlines ~= nil then
		local headlinesNum = #jsonDic.headlines
		for i = 1, headlinesNum do
			local shoutData = {
				time = UserData:getServerTime(),
				name = jsonDic.headlines[headlinesNum - i + 1].name,
				content = jsonDic.headlines[headlinesNum - i + 1].content,
				uid = jsonDic.headlines[headlinesNum - i + 1].uid or 0,
				vip = jsonDic.headlines[headlinesNum - i + 1].vip or 0
			}
			if shoutData.uid == 0 then
				table.insert(ChatData.vecNewData[CHAT_CHANNEL.WORLDBULLETIN], shoutData)
			else
				chatTipsVis = true
				table.insert(ChatData.vecNewData[CHAT_CHANNEL.LOUDSPEAKER], shoutData)
			end
		end
	end

	if jsonDic.legiontalks ~= nil then
		local legionNum = #jsonDic.legiontalks
		for i = 1, legionNum do
			local legionData = {
				time = UserData:getServerTime(),
				name = jsonDic.legiontalks[legionNum - i + 1].name,
				content = jsonDic.legiontalks[legionNum - i + 1].content,
				uid = jsonDic.legiontalks[legionNum - i + 1].uid or 0,
				vip = jsonDic.legiontalks[legionNum - i + 1].vip or 0
			}
			table.insert(ChatData.vecNewData[CHAT_CHANNEL.LEGION], legionData)
		end
		if legionNum > 0 then
			chatTipsVis = true
		end
	end

	if jsonDic.chats ~= nil then
		local msgNum = #jsonDic.chats
		local index = 0
		for i = 1, msgNum do
			index = msgNum - i + 1
			local msgData = {
				time = jsonDic.chats[index].time,
				name = jsonDic.chats[index].name,
				content = jsonDic.chats[index].content,
				uid = jsonDic.chats[index].uid or 0,
				vip = jsonDic.chats[index].vip or 0
			}
			if ChatData.privateVecNewData[tostring(msgData.uid)] == nil then
				ChatData.privateVecNewData[tostring(msgData.uid)] = {}
			end
			table.insert(ChatData.privateVecNewData[tostring(msgData.uid)], msgData)
		end
		if ChatData.updatePrivateChat ~= nil then
			ChatData.updatePrivateChat()
		end
		if msgNum > 0 then
			if setFriendTipsVisible ~= nil then
				setFriendTipsVisible(true)
			end
		end
	end

	local friend = jsonDic.friend or 0
	local food = jsonDic.food or 0
	if friend == 1 or food == 1 then
		if setFriendTipsVisible ~= nil then
			setFriendTipsVisible(true)
		end 
	end

	if food == 1 then
		setFriendsGetBtnStatus(true)
	end

	local chat = require('ceremony/panel/chat/chat_panel')
	if chat.isOpen then
		chat:updateChat(chat.currentChannel)
	else
		if chatTipsVis then
			if setChatTipsVisible ~= nil then
				setChatTipsVisible(true)
			end
		end
	end
end

function checkLoudSpeaker()
	local ls = ChatData.vecNewData[CHAT_CHANNEL.LOUDSPEAKER]
	if #ls > 0 then
		local lsData = table.remove(ls)
		CMainSceneMgr:GetInst():updateLoudSpeaker(lsData.name, lsData.content)
		table.insert(ChatData.vecOldData[CHAT_CHANNEL.LOUDSPEAKER], lsData)
		return
	end

	local wb = ChatData.vecNewData[CHAT_CHANNEL.WORLDBULLETIN]
	if #wb > 0 then
		local wbData = table.remove(wb)
		local content = formatStringForMsg(wbData.content)
		CMainSceneMgr:GetInst():updateLoudSpeaker(wbData.name, content)
	end
end