

-- The closure is for current file scope
local currentSelected = 0
local function setCurrentSelected(id)
	if 'number' ~= type(id) then
		return 
	end
	currentSelected = id
	print('now you selected ' .. tostring(id))
end

local function genViewUpdater(root)
	-- Chosen one
	local chosenImage = tolua.cast(root:getChildByName('chosen_girl_img'),'UIImageView')
	local chosenNameStripIco = tolua.cast(root:getChildByName('chosen_name_ico'), 'UIImageView')

	-- 技能图标
	local skillIco = tolua.cast(root:getChildByName('skill_ico'), 'UIImageView')
	local skillNameIco = tolua.cast(root:getChildByName('skill_name_ico'), 'UIImageView')
	local skillInfoTa = tolua.cast(root:getChildByName('skill_info_ta'), 'UITextArea')

	--Lock
	local lockIco = tolua.cast(root:getChildByName('lock_ico'), 'UIImageView')

	-- zhan_btn
	local zhanBtn     = tolua.cast(root:getChildByName('zhan_btn'), 'UIButton')
	local reclaimBtn  = tolua.cast(root:getChildByName('reclaim_btn'), 'UIButton')
	local passinfoPl  = tolua.cast(root:getChildByName('passinfo_pl'), 'UIPanel')
	local battleAreaTx= tolua.cast(root:getChildByName('battlearea_tx'), 'UILabel')

	--属性数值(Label)以及Ico(Image)
	local attribX = {}
	for i=1,4 do
		attribX[i] = {
			ico = tolua.cast(root:getChildByName(string.format('attribute%d_ico',i)),'UIImageView'),
			tx  = tolua.cast(root:getChildByName(string.format('attribute%d_tx',i)),'UILabel'),
			name = string.format('Attribute%d',i)
		}
	end

	local function updateAttributes(config)
		for i=1,#attribX do
			local item = config[attribX[i].name]
			local sp = string.split(item,':')
			local texName = toTexName(sp[1])

			--
			attribX[i].ico:setTexture(texName)
			attribX[i].tx:setText('+' .. tostring(sp[2]))
			attribX[i].tx:setColor(ccc3(0,255,0))
		end
	end

	return function(id)
		-- 现在只有一个妞只有一个技能, 编号为1
		--print('much later for now')
		print('updating for '..tostring(id))
		local saved = CBattleAPI:isGirlSaved(id)
		local cfg = getDivinityConfig(id, 1)
		skillInfoTa:setText(GetTextForCfg(cfg.SkillDescription))
		skillIco:setTexture(cfg.SkillIcon)
		skillNameIco:setTexture(cfg.SkillNameIcon)

		-- Main theme
		chosenNameStripIco:setTexture(cfg.GirlNameStrip)
		chosenImage:setTexture(cfg.BeautySculpIcon)

		-- 4 combos
		updateAttributes(cfg)
		setCurrentSelected(id)
		local curId = getDivinityState()
		print('current embattle id is ' .. tostring(curId))

		lockIco:setVisible(not saved)
		if saved then
			--Exclusive
			reclaimBtn:setVisible(id==curId)
			zhanBtn:setVisible(id~=curId)
			passinfoPl:setVisible(false)
		else
			zhanBtn:setVisible(false)
			reclaimBtn:setVisible(false)
			passinfoPl:setVisible(true)
			--Update where to save this one
			--battleAreaTx:setText('"YES"')
			battleAreaTx:setText(GetTextForCfg(cfg.RescuePoint))
		end
	end
end

local function installImages(root, viewSelectOn)
	local ids = getBeautyIDS()
	local strip = tolua.cast(root:getChildByName('static_strip_ico'), 'UIImageView')
	local size = strip:getContentSize()
	local svSize = CCSizeMake(size.width * 0.7, size.height)
	local sv = UIScrollView:create()
	sv:setSize(svSize)
	sv:setClippingEnable(true)
	sv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
	sv:setTouchEnable(true)
	strip:addChild(sv)
	sv:setPosition( ccp(svSize.width * -0.5, svSize.height * -0.5))
	--sv:setPosition(CCPointZero)

	local stdFrameSize = CCSizeMake(81, 81)
	local stdSize = CCSizeMake(65, 65)
	local hspan = 4
	local framePath = 'uires/ui_2nd/com/panel/common/frame_pink.png'

	local widgetAll = {}
	for i=1,#ids do
		local saved = CBattleAPI:isGirlSaved(ids[i])
		local cfg = getDivinityConfig(ids[i])
		assert(cfg, 'must be there')
		local frame = UIImageView:create()
		frame:setTexture(framePath)
		frame:setActionTag(ids[i])
		frame:setTouchEnable(true)
		frame:setAnchorPoint(ccp(0,0))
		frame:setPosition(ccp((i-1) * (stdFrameSize.width + hspan), 0))

		local csz = frame:getContentSize()
		local isSaved = CBattleAPI:isGirlSaved(ids[i])
		local _view = UIImageView:create()
		_view:setTexture(cfg.BeautySmallIcon)
		_view:setPosition(CCPointMake(csz.width * 0.5, csz.height * 0.5))

		local _lock = UIImageView:create()
		_lock:setTexture('uires/ui_2nd/com/panel/beauty/suo.png')
		_lock:setScale(0.3)
		_view:addChild(_lock)
		_lock:setPosition(ccp(20,5))
		_lock:setAnchorPoint(ccp(0.5,0))
		_lock:setWidgetZOrder(120)

		if not isSaved then _view:setGray() end
		_lock:setVisible(not isSaved)
		frame:addChild(_view)
		widgetAll[#widgetAll+1] = frame

		--Attaching
		sv:addChild(frame)
	end
	assert(#widgetAll == #ids, 'must be of the same length')
	local count = #widgetAll
	for i=1, count do
		local thisWidget = widgetAll[i]
		thisWidget:registerScriptTapHandler(
			function()
				viewSelectOn(ids[i])
			end
		)
	end
end

local function genOnEmbattleResponse(btn0, btn1, id, prompt, error)
	return function(response)
		local resp = json.decode(response)
		if resp.code == 0 then
			btn0:setVisible(false)		--Exclusive
			btn1:setVisible(true)
			setDivinityState(id, 1)
			GameController.showPrompts(getLocalStringValue(prompt))
		else
			print('error setting embattle divinity')
			print('retcode is ' ..tostring(resp.code))
			GameController.showPrompts(error)
		end
	end
end

local function genOnClickEmbattle(btn, reclaimBtn)
	return function()
		print('embattle ' .. tostring(currentSelected) .. ' !')
		Message.sendPost('set_girl', 'battle', json.encode(
			{skill = 1, id = currentSelected}),
			genOnEmbattleResponse(btn, reclaimBtn, currentSelected,'E_STR_DIVINITY_EMBATTLING_DONE','Embattle error')
		)
	end
end

local function genOnClickReclaim(btn, battleBtn)
	return function()
		print('on-click reclaim for anyone')
		Message.sendPost('set_girl', 'battle', json.encode({skill=1, id=-1}),
			genOnEmbattleResponse(btn, battleBtn, -1, 'E_STR_DIVINITY_RECALL_DONE','Reclaim error')
		)
	end
end

function genBeautyPanelX(preferredID)
	preferredID = preferredID or 1004001
	setCurrentSelected(preferredID)
	local scene = SceneObjEx:createObj('panel/beauty_panel_x.json', 'beauty-in-lua', true)
	local panel = scene:getPanelObj()
	panel:setAdaptInfo('beauty_bg_img', 'beauty_img')

	panel:registerInitHandler(
		function()
			panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(scene))
			local root = panel:GetRawPanel()
			local viewUpdater = genViewUpdater(root)

			local zhanBtn = tolua.cast(root:getChildByName('zhan_btn'),'UIButton')
			local reclaimBtn=tolua.cast(root:getChildByName('reclaim_btn'), 'UIButton')
			reclaimBtn:setTouchEnable(true)

			installImages(root, viewUpdater)
			panel:registerScriptTapHandler('zhan_btn', genOnClickEmbattle(zhanBtn, reclaimBtn))
			panel:registerScriptTapHandler('reclaim_btn', genOnClickReclaim(reclaimBtn, zhanBtn))

			----[[
			--TODO
			print('current selected is ' .. tostring(currentSelected))
			if currentSelected > 0 then
				--local offset = getDivinityIndexOffset(currentSelected)
				--print('offset is ' .. tostring(offset))
				--posSetter( -(offset-1) * hspan )
				print('updating now...' .. tostring(currentSelected))
				viewUpdater(currentSelected)
			end
			--]]

			print('beauty panel init done. with id = '..tostring(preferredID))
		end
	)
	UiMan.show(scene)
end

