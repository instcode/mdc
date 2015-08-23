

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
	-- 技能图标
	local skillIco = tolua.cast(root:getChildByName('user_ico'), 'UIImageView')
	local skillNameTx=tolua.cast(root:getChildByName('skill_name_tx'), 'UILabel')
	local infoTa = tolua.cast(root:getChildByName('info_ta'), 'UITextArea')

	-- zhan_btn
	local zhanBtn = tolua.cast(root:getChildByName('zhan_btn'), 'UIButton')
	local reclaimBtn=tolua.cast(root:getChildByName('reclaim_btn'), 'UIButton')
	local passinfoPl = tolua.cast(root:getChildByName('passinfo_pl'), 'UIPanel')
	local battleAreaTx=tolua.cast(root:getChildByName('battlearea_tx'), 'UILabel')

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
			attribX[i].tx:setText(tostring(sp[2]))
		end
	end

	return function(id)
		-- 现在只有一个妞只有一个技能, 编号为1
		--print('much later for now')
		local saved = CBattleAPI:isGirlSaved(id)
		local cfg = getDivinityConfig(id, 1)
		infoTa:setText(GetTextForCfg(cfg.SkillDescription))
		skillIco:setTexture(cfg.SkillIcon)
		skillNameTx:setText(GetTextForCfg(cfg.SkillName))

		-- 4 combos
		updateAttributes(cfg)
		setCurrentSelected(id)
		local curId = getDivinityState()

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

function genEvents(widget, index, total, panelSize, dwid, widgetSet, activator, stopper, notifier)
	local isPushed = false
	local startPos

	local max = 0.5 * panelSize.width + (index-1) * dwid
	local min = max - (total-1) * dwid
	local posxx = {}

	if type(activator) ~= 'function' then
		error('we need an activator')
	end
	if type(stopper) ~= 'function' then
		error('we need a stopper')
	end
	if type(notifier) ~= 'function' then
		error('we need a notifier')
	end

	local function calcX(i)
		--return 0.5 * panelSize.width + (i-1) * dwid 
		return posxx[i]
	end

	local function onPushDown()
		stopper()
		--print('pushed down for '..tostring(index))
		isPushed = true
		startPos = widget:getTouchStartPos()
		--print('start x at ' .. tostring(startPos.x))
		posxx = {}
		for i=1,#widgetSet do
			posxx[#posxx+1] = widgetSet[i]:getPosition().x
		end
	end

	local function updatePos()
		local movPos = widget:getTouchMovePos()
		--print('mov pos.x = '..tostring(movPos.x))

		local diff = movPos.x - startPos.x
		--print('diff is first '..tostring(diff))

		--local nextX = startPos.x + diff
		local nextX = calcX(index) + diff
		if nextX < min then nextX = min end
		if nextX > max then nextX = max end

		diff = nextX - calcX(index)
		--print('diff is fixed to ' .. tostring(diff))
		local half = panelSize.width * 0.5
		for i=1, #widgetSet do
			local newX = calcX(i) + diff
			widgetSet[i]:setPosition(ccp( newX, 0.5 * panelSize.height))

			--[[]]
			local scale = math.max(1 - math.abs(newX - half) / half, 0.1)
			widgetSet[i]:setScale(scale)
			widgetSet[i]:setOpacity(scale * 255)
		end
	end

	local function onMov()
		updatePos()
	end

	local function onRelease()
		updatePos()
		isPushed = false
		local widget, index = activator()
		notifier(widget:getActionTag())
	end

	return onPushDown, onMov, onRelease
end

local function genUpdater(widgetAll, panelSize, adjustPos)
	local isActive = false
	local w = panelSize.width
	local half = w * 0.5
	local offsetMov, movCount = 0, 0
	if type(adjustPos) ~= 'function' then
		error('adjust pos is not set')
	end

	return function()
		if isActive then
			movCount = movCount - 1
			if movCount <= 0 then
				isActive = false
			end
			adjustPos(offsetMov)
		end
	end, 
	function()		-- Activator
		local found = false
		local min, real = 0, 0
		local half = w * 0.5
		local widgetSelect, index
		for i=1,#widgetAll do
			local thisWidget = widgetAll[i]
			local pos = thisWidget:getPosition()
			local x = pos.x
			if not found or math.abs(half - x) < min then
				found = true
				min = math.abs(half - x)
				real = half - x
				widgetSelect = thisWidget
				index = i
			end
		end
		if found then
			--print('triggered')
			isActive = true
			movCount = 9			-- The less the better
			offsetMov = real / movCount
		end
		return widgetSelect, index
	end,
	function()   -- Stopper
		isActive = false
	end
end

local function genPositionSetter(widgets, panelSize)
	-- [[]]
	-- 
	-- 
	local half = panelSize.width * 0.5
	return function(offsetX)
		for i=1,#widgets do
			local pos = widgets[i]:getPosition()
			local newX = pos.x + offsetX
			widgets[i]:setPosition(CCPointMake(newX, pos.y))

			local scale = math.max(1 - math.abs(newX - half) / half, 0.1)
			widgets[i]:setScale(scale)
			widgets[i]:setOpacity(scale * 255)
		end
	end
end

local function installImages(root, viewSelectOn)
	local ids = getBeautyIDS()
	local panel = tolua.cast(root:getChildByName('image_area_pl'), 'UIPanel')
	panel:setClippingEnable(false)
	local size = CCSizeMake( panel:getWidth(), panel:getHeight() )
	local horizontalSpan = size.width * 0.3

	local widgetAll = {}
	for i=1,#ids do
		local saved = CBattleAPI:isGirlSaved(ids[i])

		local cfg = getDivinityConfig(ids[i])
		assert(cfg, 'must be there')
		local view = UIImageView:create()
		view:setTexture(cfg.BeautySculpIcon)
		view:setAnchorPoint(ccp(0.5,0.5))
		view:setActionTag(tonumber(ids[i]))
		view:setPosition(ccp(size.width * 0.5 + (i-1) * horizontalSpan, size.height * 0.5))
		panel:addChild(view)
		widgetAll[#widgetAll+1] = view
		view:setTouchEnable(true)

		--名字条跟随人
		local nameStrip = UIImageView:create()
		nameStrip:setTexture(cfg.GirlNameStrip)
		view:addChild(nameStrip)
		nameStrip:setPosition(ccp(-120,120))
		nameStrip:setAnchorPoint(ccp(0.5, 0.5))

		--锁
		local lockIco = UIImageView:create()
		lockIco:setTexture('uires/ui_2nd/com/panel/beauty/suo.png')
		view:addChild(lockIco)
		lockIco:setPosition(ccp(90,-100))
		lockIco:setAnchorPoint(ccp(0.5,0.5))
		lockIco:setScale(0.5)

		if not saved then
			--view:setGray()
			lockIco:setVisible(true)
		else
			lockIco:setVisible(false)
		end
	end

	local positionSetter = genPositionSetter(widgetAll, size)
	local updater, activator, stopper = genUpdater(widgetAll, size, positionSetter)

	local count = #widgetAll
	for i=1, count do
		local thisWidget = widgetAll[i]
		local pushE, movE, reE = genEvents(thisWidget
			, i
			, count
			, size
			, size.width * 0.3
			, widgetAll
			, activator
			, stopper
			, viewSelectOn)

		thisWidget:registerPushDownHandler(pushE)
		thisWidget:registerMovHandler(movE)
		thisWidget:registerScriptTapHandler(reE)
		thisWidget:registerScriptCancelHandler(reE)
	end

	--root: the root widget
	root:registerUpdateHandler(
		function()
			--print('this is update')
			-- remains for debug
			updater()
		end
	)
	root:setUpdateEnable(true)

	--To select one, any one is ok !
	-- As if it is activated once
	if currentSelected <= 0 then
		local widget, index = activator()
		viewSelectOn(widget:getActionTag())
	end

	return positionSetter, horizontalSpan
end

local function genOnEmbattleResponse(btn0, btn1, id, prompt)
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
		end
	end
end

local function genOnClickEmbattle(btn, reclaimBtn)
	return function()
		print('embattle ' .. tostring(currentSelected) .. ' !')
		Message.sendPost('set_girl', 'battle', json.encode(
			{skill = 1, id = currentSelected}),
			genOnEmbattleResponse(btn, reclaimBtn, currentSelected,'E_STR_DIVINITY_EMBATTLING_DONE')
		)
	end
end

local function genOnClickReclaim(btn, battleBtn)
	return function()
		print('on-click reclaim for anyone')
		Message.sendPost('set_girl', 'battle', json.encode({skill=1, id=-1}),
			genOnEmbattleResponse(btn, battleBtn, -1, 'E_STR_DIVINITY_RECALL_DONE')
		)
	end
end

function genBeautyPanel(preferredID)
	setCurrentSelected(preferredID)
	local scene = SceneObjEx:createObj('panel/beauty_bg_panel1.json', 'beauty-in-lua', true)
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

			local posSetter, hspan = installImages(root, viewUpdater)
			panel:registerScriptTapHandler('zhan_btn', genOnClickEmbattle(zhanBtn, reclaimBtn))
			panel:registerScriptTapHandler('reclaim_btn', genOnClickReclaim(reclaimBtn, zhanBtn))

			----[[
			--TODO
			print('current selected is ' .. tostring(currentSelected))
			if currentSelected > 0 then
				local offset = getDivinityIndexOffset(currentSelected)
				--print('offset is ' .. tostring(offset))
				posSetter( -(offset-1) * hspan )
				viewUpdater(currentSelected)
			end
			--]]

			print('beauty panel init done. with id = '..tostring(preferredID))
		end
	)
	UiMan.show(scene)
end

