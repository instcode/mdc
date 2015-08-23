LegionDonatePanel = LegionView:new{
	jsonFile = 'panel/legion_donation_bg_panel.json',
	panelName = 'lgion-donate-panel',
	donateSv = nil,
	honorTx = nil
}

local function getChild(p , n , t)
	return tolua.cast(p:getChildByName(n) , t)
end

function LegionDonatePanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('di_ico', 'donation_bg_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		donateSv = getChild(root , 'res_sv', 'UIScrollView')
		donateSv:setClippingEnable(true)
		donateSv:setDirection(SCROLLVIEW_DIR_VERTICAL)

		honorTx = getChild(root , 'donation_num_tx' , 'UILabel')
		local honorIco = getChild(root , 'donation_ico' , 'UIImageView')
		honorIco:setTexture(MyLegion:getHonorIcon())

		self:update()
	end)
end

function LegionDonatePanel:update()
	donateSv:removeAllChildrenAndCleanUp(true)

	honorTx:setTextFromInt(MyLegion:getMyData().honor)

	local data = self:makeData()
	table.foreach(data , function (_, v)
		local item = createWidgetByName('panel/legion_donation_cell.json')
		if not item then
			print('failed to create legion_donation_cell!')
		else
			local photo = getChild(item , 'goods_ico' , 'UIImageView')
			local numTx = getChild(item , 'number_tx' , 'UILabel')
			local nameTx = getChild(item , 'res_name_tx' , 'UILabel')
			local descTx = getChild(item , 'info_ta' , 'UITextArea')
			local priceTx = getChild(item , 'price_num_tx' , 'UILabel')
			local priceIcon = getChild(item , 'price_ico' , 'UIImageView')
			local remainTimesTx = getChild(item , 'times_tx' , 'UILabel')
			self:registerButtonWithHandler(item , 'donation_tbtn' , BUTTON_SOUND_TYPE.CLICK_EFFECT , function ()
				if v.id == 'gold' then
					if PlayerCoreData.getGoldValue() < LegionConfig:getValueForKey('GoldContributeNum') then
						GameController.showPrompts(getLocalString("E_STR_NOT_ENOUGH_GOLD") , COLOR_TYPE.RED)
					else
						if MyLegion:isCanDonateToday() then
							LegionController.sendLegionDonateRequset( 1 , 'gold' , 1 , function ( response )
								if response.code == 0 then
									GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_DONATE_SUCCESS_DESC') , COLOR_TYPE.GREEN )
									self:update()
									LegionMinePage:update()
								end
							end)
						else
							GameController.showPrompts( LegionConfig:getLegionLocalText('LEGION_USEUP_GOLD_DONATE_TIMES') , COLOR_TYPE.RED )
						end
					end
				else
					openLegionDonatePanel(v , function (id , num )
						print('id = ' .. id .. ' , num = ' .. num)
						LegionController.sendLegionDonateRequset( id , 'material' , num , function ( response )
							if response.code == 0 then
								GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_DONATE_SUCCESS_DESC'))
								self:update()
								LegionMinePage:update()
							end
						end)
					end)
				end
			end)

			photo:setTexture(v['icon'])
			numTx:setText(toWordsNumber(v['count']))
			nameTx:setText(v['name'])
			nameTx:setColor(v['color'])
			descTx:setText(v['desc'])
			priceTx:setTextFromInt(v['sellprice'])
			priceIcon:setTexture(MyLegion:getHonorIcon())
			if v['remaintimesdesc'] then
				remainTimesTx:setText( v['remaintimesdesc'] )
				remainTimesTx:setColor( ccc3(0,255,0) )
			else
				remainTimesTx:setText( '' )
			end

			donateSv:addChildToBottom(item)
		end
	end)

	local lastPanel = UIPanel:create()
	lastPanel:setAnchorPoint(ccp(0,0))
	lastPanel:setSize(CCSizeMake(610 , 80))

	-- 感叹号
	local plaintIco = UIImageView:create()
	plaintIco:setTexture('uires/ui_2nd/com/panel/playerguide/plaint.png')
	plaintIco:setScale(0.9)
	plaintIco:setAnchorPoint(ccp(0,0))
	plaintIco:setPosition(ccp(20 , 10))
	lastPanel:addChild(plaintIco)

	-- 提示文字
	local noticeTx = UILabel:create()
	noticeTx:setPreferredSize(550,1)
	noticeTx:setFontSize(26)
	noticeTx:setAnchorPoint(ccp(0,0))
	noticeTx:setText(LegionConfig:getLegionLocalText('LEGION_DONATE_MATERIAL_DESC'))
	noticeTx:setPosition(ccp(60 , 0 ))
	lastPanel:addChild(noticeTx)
	
	donateSv:addChildToBottom(lastPanel)

	donateSv:scrollToTop()
end

function LegionDonatePanel:makeData()
	local tab = {}

	-- 默认第一项为金币...
	-- if MyLegion:isCanDonateToday() then
		local techAddTimes = MyLegion:getTechEffectByID(7)
		local maxTimes = LegionConfig:getValueForKey('InitialGoldContributeTime') + techAddTimes
		local remainTimes = 0
		local donateDate = tostring(MyLegion:getMyData()['donate_date'])
		local donateCount = tonumber(MyLegion:getMyData()['donate_count'])

		local time1 = UserData:convertTime(2 , donateDate)
		local time2 = Time.beginningOfToday()

		if time1 < time2 then
			remainTimes = maxTimes
		else
			remainTimes = maxTimes - donateCount
			if remainTimes < 0 then
				remainTimes = 0
			end
		end

		local defaultTab = {}
		defaultTab['id'] = 'gold'
		defaultTab['name'] = getLocalString('E_STR_GOLD')
		defaultTab['color'] = COLOR_TYPE.WHITE
		defaultTab['count'] = LegionConfig:getValueForKey('GoldContributeNum')
		defaultTab['icon'] = 'uires/ui_2nd/image/item/gold_icon.png'
		defaultTab['sellprice'] = LegionConfig:getValueForKey('GoldContributeHonor')
		defaultTab['desc'] = string.format(LegionConfig:getLegionLocalText('E_STR_LEGION_DONATE_GOLD') , toWordsNumber(LegionConfig:getValueForKey('GoldContributeNum')) )
		defaultTab['remaintimesdesc'] = remainTimes .. '/' .. maxTimes
		table.insert(tab , defaultTab)
	-- end

	-- 其他读取material表
	local conf = GameData:getArrayData('material.dat')
	table.foreach(conf , function (_, v)
		if tonumber(v['Donate']) > 0 then
			local obj = Material:findById(tonumber(v.Id))
			-- 80 科技令ID
			if obj and obj:getId() == 80 and obj:getCount() > 0 then
				local itemTab = {}
				itemTab['id'] = obj:getId()
				itemTab['name'] = obj:getName()
				itemTab['color'] = obj:getNameColor()
				itemTab['count'] = obj:getCount()
				itemTab['icon'] = obj:getResource()
				itemTab['desc'] = obj:getDesc()
				itemTab['sellprice'] = tonumber(v['LegionHonor'])
				table.insert(tab , itemTab)
			end
		end
	end)
	return tab
end

function LegionDonatePanel:release()
	print('LegionDonatePanel release ...')
	LegionView.release(self)
	self.donateSv = nil
	self.honorTx = nil
end