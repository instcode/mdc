
---------------------------------------
-------------------- eminem
---------------------------------------

require 'ceremony/panel/beauties_events'

local dwidth = 300
local dheight= 510

local function installGirlDivision(pv, pageUpdater)
	pv:setTouchEnable(true)
	local ids = getBeautyIDS()
	local tv = {}

	local _curID = getDivinityState()
	for i=1, #ids do
		local thisID = ids[i]
		local card = createWidgetByName('panel/beauty_card_panel.json')
		if not card then
			error('no card')
		end

		--card:setPosition(ccp(i*dwidth,0))
		local container = UIContainerWidget:create()
		container:setSize(CCSizeMake(dwidth, dheight))
		container:addChild(card)
		pv:addPage(container)

		local isSaved = CBattleAPI:isGirlSaved(thisID)
		local conf = getDivinityConfig(thisID)

		------------------------
		--------------------
		----------------
		local girlImg = tolua.cast(card:getChildByName('girl_img'), 'UIImageView')
		girlImg:setTexture(conf.BeautySculpIcon)

		local lockIco = card:getChildByName('lock_ico')
		lockIco:setVisible(not isSaved)

		local nameIco = tolua.cast(card:getChildByName('name_ico'),'UIImageView')
		nameIco:setTexture(conf.GirlNameStrip)

		local fangdaBtn = card:getChildByName('fangda_btn')
		fangdaBtn:setVisible(false)

		local infoTx = tolua.cast(card:getChildByName('info_tx'),'UILabel')
		infoTx:setPreferredSize(260,1)

		local zhanBtn = card:getChildByName('zhan_btn')
		local reclaimBtn=card:getChildByName('reclaim_btn')

		infoTx:setVisible(not isSaved)
		if isSaved then
			local forMe = tonumber(_curID) == tonumber(thisID)
			zhanBtn:setVisible(not forMe)
			reclaimBtn:setVisible(forMe)
		else
			zhanBtn:setVisible(false)
			reclaimBtn:setVisible(false)
			infoTx:setText(string.format(getLocalString('E_DIVINITY_OPEN_TEXT'), GetTextForCfg(conf.RescuePoint)))
		end
		tv[#tv+1] = { z = zhanBtn, r = reclaimBtn , i = infoTx}
	end

	local function updater()
		local currentID = getDivinityState()
		for i=1,#tv do
			if tv[i].i:isVisible() then
				tv[i].z:setVisible(false)
				tv[i].r:setVisible(false)
			else
				local forMe = currentID == ids[i]
				tv[i].z:setVisible(not forMe)
				tv[i].r:setVisible(forMe)
			end
		end
	end

	for i=1,#ids do
		local thisID = ids[i]
		tv[i].z:registerScriptTapHandler(BeautyEvents.genOnClickEmbattle(thisID
			, tv[i].z, tv[i].r, updater)
		)
		tv[i].r:registerScriptTapHandler(BeautyEvents.genOnClickReclaim(
			tv[i].r, tv[i].z, updater)
		)
	end

	----------
	pv:addScroll2PageEventScript(
		function(idx)
			local index = idx + 1
			pageUpdater(ids[index])
		end
	)
end

local function genPageUpdater(root)
	local skillNameIco = tolua.cast(root:getChildByName('skill_name_ico'),'UIImageView')
	local infoTa = tolua.cast(root:getChildByName('info_ta'), 'UITextArea')
	local skillIco = tolua.cast(root:getChildByName('special_skill_ico'),'UIImageView')
	local attr = {}
	for i=1,4 do
		local icoName = string.format('attr_%d_ico',i)
		local txName  = string.format('attr_%d_tx',i)
		attr[i] = {
			ico = tolua.cast(root:getChildByName(icoName), 'UIImageView'),
			tx  = tolua.cast(root:getChildByName(txName),  'UILabel')
		}
	end
	return function(id)
		local conf = getDivinityConfig(id)
		for i=1,4 do 
			local attribute = string.format('Attribute%d',i)
			local vs = string.split(conf[attribute],':')
			attr[i].ico:setTexture(toTexName(vs[1]))
			attr[i].tx:setText('+'..vs[2])
			attr[i].tx:setColor(ccc3(0,255,0))
		end
		infoTa:setText(GetTextForCfg(conf.SkillDescription))
		skillIco:setTexture(conf.SkillIcon)
		skillNameIco:setTexture(conf.SkillNameIcon)
	end
end


function genBeautyPanelI(girlID)
	girlID = tonumber(girlID)
	local offset = getDivinityIndexOffset(girlID)
	if offset <= 0 then
		return
	end

	local sceneObj = SceneObjEx:createObj('panel/beauty_panel.json', 'beauty-in-lua-I')
	local panel = sceneObj:getPanelObj()
	panel:setAdaptInfo('beauty_bg_img', 'beauty_img')
	panel:registerInitHandler(
		function()
			panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(sceneObj))
			local root = panel:GetRawPanel()

			local pv = UIPageView:create()
			pv:setSize(CCSizeMake(300,510))
			pv:setPosition(ccp(21,26))
			local bg = root:getChildByName('beauty_img')
			bg:addChild(pv)

			local updateHandler = genPageUpdater(root)
			installGirlDivision(pv, updateHandler)

			local offset = getDivinityIndexOffset(girlID)
			if offset > 0 then
				pv:scrollToPage(offset-1)
			end
		end
	)

	UiMan.show(sceneObj)
end