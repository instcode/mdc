GodMain = {}

-- 兵种 类型
SoldierNames = {
	"dao.png",
	"qiang.png",
	"qibing.png",
	"mou.png",
	"hong.png"
}

function GodMain.isTimeOver()
	local giveGodAwardConf = GameData:getArrayData('god.dat')
	local time = UserData:getServerTime() - PlayerCoreData.getCreatePlayerTime()
	local leftTime = tonumber(giveGodAwardConf[3].AccountCreateTimePass) - time
	if leftTime < 0 then
		return true
	end
	return false
end
function GodMain.giveGodMain()
	local sceneObj
	local panel
	local data
	local attackNum
	local defenseNumTx
	local magicDefenseNumTx
	local soldierNumTx
	local soldierTypeIco
	local roleNameTx
	local roleImg
	local rightSv
	local dataRole
	local currRole = 0
	local attrIcoArr = {}

	local QUANIMG = 'uires/ui_2nd/com/panel/signin/quan.png'
	local roleLevelConf = GameData:getArrayData('rolelevel.dat')
	local giveGodAwardConf = GameData:getArrayData('god.dat')
    local giveheroConf = GameData:getArrayData('givehero.dat')

    local function getRole(i,roleImg,frameImg,light,getRoleBtn)
    	args = {
			id = tonumber(i)
		}
    	Message.sendPost('get_god','god',json.encode(args),function(jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code == 0 then
				data = response.data.god
				setGodData(response.data.god)
				local awards = response.data.awards
				local awardStr = json.encode(awards)
				UserData.parseAwardJson(awardStr)
				-- 显示招到的武将
				CPublicPanelMgr:GetInst():ShowGodRoleLua(tonumber(giveheroConf[i].GodRid), true)
				light:setVisible(false)
				roleImg:setGray()
				frameImg:setGray()
				frameImg:setVisible(true)
				getRoleBtn:setVisible(false)
			end
		end)
	end

    local function updateLeftPanel()
    	roleId = giveheroConf[currRole].GodRid
		roleCard = Role.getDataById(roleId)
    	for i = 1, 4 do
			local attackNum = 0
			if i == 1 then
				attackNum = roleCard.Attack
				attrIcoArr[1]:setTexture(Role.getResourceByIdAndResType(roleId, RESOURCE_TYPE.WEAPON_ICON_SMALL))
			elseif i == 2 then
				attackNum = roleCard.Defence
			elseif i == 3 then
				attackNum = roleCard.MagicDefence
			else
				attackNum = roleLevelConf[1]['Soldier' .. roleCard.Soldier]
			end
			attrTxArr[i]:setText(toWordsNumber(tonumber(attackNum)))
			attrTxArr[i]:setColor(COLOR_TYPE.RED)
		end

		roleNameTx:setText(GetTextForCfg(giveheroConf[currRole].Name))
		roleNameTx:setColor(ccc3(255,0,0))

		roleImg:setTexture(Role.getResourceByIdAndResType(roleId, RESOURCE_TYPE.BIG))

		soldierType = PlayerCoreData.getSoldierTypeByID( roleId )
		-- uires/ui_2nd/com/panel/common/dao.png
		str = string.format('%s%s','uires/ui_2nd/com/panel/common/',SoldierNames[tonumber(soldierType)])
		soldierTypeIco:setTexture(str)
    end

    local function updateCellPanel(i,rewardView)

		local cardImg = tolua.cast(rewardView:getChildByName('card_img') , 'UIImageView')
    	local godNameImg = tolua.cast(rewardView:getChildByName('god_name_img') , 'UIImageView')
    	local frameImg = tolua.cast(rewardView:getChildByName('frame_img') , 'UIImageView')
    	local roleImg = tolua.cast(rewardView:getChildByName('role_ico') , 'UIImageView')
    	local barBgImg = tolua.cast(rewardView:getChildByName('bar_bg_img') , 'UIImageView')
    	local starBar = tolua.cast(barBgImg:getChildByName('star_bar') , 'UILoadingBar')
    	local ratioTx = tolua.cast(rewardView:getChildByName('ratio_tx') , 'UILabel')
		local starNumTx = tolua.cast(rewardView:getChildByName('star_num_tx') , 'UILabel')
		local getRoleBtn = tolua.cast(rewardView:getChildByName('get_role_btn'), 'UITextButton')
		starBar:setPercent(50)

		roleId = giveheroConf[i].GodRid
		roleCard = Role.getDataById(roleId)

		--  设置光圈
	    local light = CUIEffect:create()
		light:Show("yellow_light",0)
		light:setScale(0.8)
		contentSize = frameImg:getContentSize()
		light:setPosition( ccp(0.0 , 0.0))
		light:setAnchorPoint(ccp(0.5,0.5))
		frameImg:getContainerNode():addChild(light)
		light:setTag(100)
		light:setZOrder(100)
		light:setVisible(true)

		starNumTx:setText(giveheroConf[i].GodRequiredStar)
    	godNameImg:setTexture(giveheroConf[i].NameIco)
		
		if tonumber(data.star) < tonumber(giveheroConf[i].GodRequiredStar) then
			ratioTx:setText(data.star..'/'..tostring(giveheroConf[i].GodRequiredStar))
			per = tonumber(data.star)*100/tonumber(giveheroConf[i].GodRequiredStar)
			starBar:setPercent(per)
		else
			ratioTx:setText(tostring(giveheroConf[i].GodRequiredStar)..'/'..tostring(giveheroConf[i].GodRequiredStar))
			starBar:setPercent(100)
		end
		
		godNameImg:setAnchorPoint(ccp(0,0))
		roleImg:setTexture(Role.getResourceByIdAndResType(roleId, RESOURCE_TYPE.ICON))
		frameImg:setTexture(Role.GetRoleIcoBgImg(ROLE_QUALITY.SRED))

		if tonumber(data.got_god[i]) == 1 then
			getRoleBtn:setNormalButtonGray(true)
			getRoleBtn:setTouchEnable(false)
			getRoleBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			light:setVisible(false)
			roleImg:setGray()
			frameImg:setGray()
			frameImg:setVisible(true)
			getRoleBtn:setVisible(false)
		elseif tonumber(data.star) >= tonumber(giveheroConf[i].GodRequiredStar) then
			getRoleBtn:setVisible(true)
			frameImg:setVisible(false)
		end

		getRoleBtn:registerScriptTapHandler(function()
			getRole(i,roleImg,frameImg,light,getRoleBtn)
		end)
		cardImg:registerScriptTapHandler(function()
			currRole = i
			updateLeftPanel()
		end)
    end
    
    local function createCellPanel()
    	for i=1,#giveheroConf do
			local rewardView = createWidgetByName('panel/god_role_card_cell.json')
			updateCellPanel(i,rewardView)
			rightSv:addChildToBottom(rewardView)
    	end
		rightSv:scrollToTop()
		if currRole > 1 and currRole < #giveheroConf - 3 then
			local one = tolua.cast(rightSv:getChildren():objectAtIndex(currRole), 'UIWidget')
			if one ~= nil then
				local pos = one:getRelativeBottomPos()
				rightSv:moveChildren(-pos + 100)
			end
		elseif currRole > #giveheroConf - 3 then
			-- rightSv:scrollToBottom()
			local one = tolua.cast(rightSv:getChildren():objectAtIndex(#giveheroConf - 2), 'UIWidget')
			if one ~= nil then
				local pos = one:getRelativeBottomPos()
				rightSv:moveChildren(-pos + 140)
			end
		end
    end
	-- 初始化界面元素
	local function init()
	
		local root = panel:GetRawPanel()
		-- 关闭
		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		attackNumTx = tolua.cast(root:getChildByName('attack_num_tx'), 'UILabel')
		defenseNumTx = tolua.cast(root:getChildByName('defense_num_tx'), 'UILabel')
		magicDefenseNumTx = tolua.cast(root:getChildByName('magic_defense_num_tx'), 'UILabel')
		soldierNumTx = tolua.cast(root:getChildByName('soldier_num_tx'), 'UILabel')
		roleNameTx = tolua.cast(root:getChildByName('role_name_tx'), 'UITextArea')
		attackIco = tolua.cast(root:getChildByName('attack_ico'),'UIImageView')
		soldierTypeIco = tolua.cast(root:getChildByName('soldier_type_ico'),'UIImageView')
		roleImg = tolua.cast(root:getChildByName('role_img'),'UIImageView')
		rightBgImg = tolua.cast(root:getChildByName('right_bg_img'),'UIImageView')
		rightSv = tolua.cast(rightBgImg:getChildByName('right_sv'),'UIScrollView')
		rightSv:setClippingEnable(true)

		attrIcoArr = {attackIco}
		attrTxArr = {attackNumTx,defenseNumTx,magicDefenseNumTx,soldierNumTx}
		currRole = 0

    	repeat
    		currRole = currRole + 1
    		if 0 == tonumber(data.got_god[currRole]) then
    			break
    		end
    	until currRole >= #giveheroConf
		createCellPanel()
		updateLeftPanel()
	end
	
	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/god_role_panel1.json','god-role-panel-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('role_bg_img','mainframe_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end
	
	local function getResponse()
		Message.sendPost('get','god','{}',function(jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code == 0 then
				-- AccumuPayData = response.data.accumulate_pay
			 --    -- 创建主界面
				data = response.data.god
				setGodData(response.data.god)
				createPanel()
			end
		end)
	end

	getResponse()
end