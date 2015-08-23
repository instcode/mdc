
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
-------------------TODO 

require 'ceremony/panel/beauties_events'

local cardWidth = 300
local girlId = 0

local function genUpdater(sv)
	sv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
	sv:setTouchEnable(true)
	sv:setClippingEnable(true)
	local gids = getBeautyIDS()
	local girlSelIndex = 1
	local girlSavedIndex = 0
	local tv = {}
	for i=1, #gids do
		local thisID = tonumber(gids[i])
		local cfg = getDivinityConfig(thisID, 1)
		local card = createWidgetByName('panel/beauty_card_panel.json')
		card:setPosition(ccp(cardWidth * (i-1), 0))
		sv:addChild(card)

		local cardPushBtn = card:getChildByName('beauty_card_btn')
		cardPushBtn:registerScriptTapHandler(
			function()
				genBeautyPanelI(thisID)
			end
		)

		--Decorate for everyone
		local girlImage = tolua.cast(card:getChildByName('girl_img'), 'UIImageView')
		girlImage:setTexture(cfg.BeautySculpIcon)

		local isSaved = CBattleAPI:isGirlSaved(thisID)
		local lockIco = card:getChildByName('lock_ico')
		local zhanBtn = card:getChildByName('zhan_btn')
		local reclaimBtn=card:getChildByName('reclaim_btn')
		local nameStripIco = tolua.cast(card:getChildByName('name_ico'), 'UIImageView')

		nameStripIco:setTexture(cfg.GirlNameStrip)
		lockIco:setVisible(not isSaved)
		if isSaved then
			--TODO
			local curId = getDivinityState()
			local isForMe = tonumber(curId) == thisID
			if isForMe then
				girlSavedIndex = i
			end
			zhanBtn:setVisible(not isForMe)
			reclaimBtn:setVisible(isForMe)
		else
			zhanBtn:setVisible(false)
			reclaimBtn:setVisible(false)
			print(thisID .. ' is not saved')
		end

		if girlId == thisID then
			girlSelIndex = i
		end

		------
		local ampBtn = tolua.cast(card:getChildByName('fangda_btn'), 'UIButton')
		ampBtn:setTouchEnable(false)
		--[[
		ampBtn:registerScriptTapHandler(
			function()
				genBeautyPanelI(thisID)
			end
		)
		--]]

		local infoTx = tolua.cast(card:getChildByName('info_tx'), 'UILabel')
		infoTx:setPreferredSize(260,1)
		infoTx:setText(string.format(getLocalString('E_DIVINITY_OPEN_TEXT'), GetTextForCfg(cfg.RescuePoint)))
		infoTx:setVisible(not isSaved)
		tv[#tv+1] = {z=zhanBtn, r=reclaimBtn}
	end

	if girlId > 0 then
		if girlSelIndex > #gids-2 then
			girlSelIndex = #gids-2
		end
		local one = tolua.cast(sv:getChildren():objectAtIndex(girlSelIndex-1), 'UIWidget')
		if one ~= nil then
			local pos = one:getRelativeLeftPos()
			sv:moveChildren(-pos)
		end
	else
		if girlSavedIndex > 0 then
			if girlSavedIndex > #gids-2 then
				girlSavedIndex = #gids-2
			end
			local one = tolua.cast(sv:getChildren():objectAtIndex(girlSelIndex-1), 'UIWidget')
			if one ~= nil then
				local pos = one:getRelativeLeftPos()
				sv:moveChildren(-pos)
			end
		end
	end
	
	local handler = function()
		local now = getDivinityState()
		for i=1,#gids do
			local thisID = gids[i]
			local isSaved = CBattleAPI:isGirlSaved(thisID)
			if isSaved then
				local forMe = tonumber(now) == tonumber(gids[i])
				tv[i].z:setVisible(not forMe)
				tv[i].r:setVisible(forMe)
			end
		end
	end

	for i=1,#tv do
		tv[i].z:registerScriptTapHandler(BeautyEvents.genOnClickEmbattle(gids[i], tv[i].z, tv[i].r, handler))
		tv[i].r:registerScriptTapHandler(BeautyEvents.genOnClickReclaim(tv[i].r, tv[i].z, handler))
	end
	return handler
end

function genBeautyPanelZ(id)
	girlId = id
	local sceneObj = SceneObjEx:createObj('panel/beauty_bg_panel.json', 'beauty-in-lua')
	local panel = sceneObj:getPanelObj()
	panel:setAdaptInfo('beauty_bg_img', 'beauty_img')

	panel:registerInitHandler(
		function()
			panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(sceneObj))
			local root = panel:GetRawPanel()
			local sv = tolua.cast(root:getChildByName('card_sv'),'UIScrollView')
			local onShow = genUpdater(sv)
			panel:registerOnShowHandler(onShow)
		end
	)
	UiMan.show(sceneObj)
end