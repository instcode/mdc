-- 

local function registerOne( notification )
	cclog('----- Registering ' .. notification.PushFunction)
	cclog('----- Type: ' .. notification.Type)

	local pushTime = 0

	if notification.Type == 'HarvestGold' then
		pushTime = NotificationPolicy:getNextGoldReachedMaxTime()
	elseif notification.Type == 'HarvestFood' then
		pushTime = NotificationPolicy:getNextFoodReachedMaxTime()
	elseif notification.Type == 'Business' then
		pushTime = NotificationPolicy:getBusinessMaxTime()
	elseif notification.Type == 'Training Center' then
		pushTime = NotificationPolicy:getLongestTrainingCooldownTime()
	elseif notification.Type == 'FreeSolicit' then
		pushTime = NotificationPolicy:getFreeSolicitTime()
	end

	if pushTime > 0 then
		CNotificationHelper:sharedHelper():registerNotification(tonumber(notification.Id),'', GetTextForCfg(notification.Content), pushTime)
	end
end

function registerAllNotifications()
	cclog('.......... Register Notifications .........')
	CNotificationHelper:sharedHelper():cancelAllNotifications()
	
	local data = GameData:getArrayData('local/builtpush.dat')
	for _, notification in pairs(data) do
		registerOne(notification)
	end
end
