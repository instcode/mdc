LegionShopPage = LegionPage:new{
	jsonFile = 'panel/legion_shop_bg_panel.json',
	panelName = 'legion-shop-panel',

	shopData = {}
}

local function getChild(p , n , t)
	return tolua.cast(p:getChildByName(n) , t)
end

function LegionShopPage:init()
	local shopSv = getChild(self.panel , 'shop_sv', 'UIScrollView')
	shopSv:setClippingEnable(true);
	shopSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
	shopSv:removeAllChildrenAndCleanUp(true)

	self:makeData()

	table.foreach(self.shopData , function(_ , value)
		local item = createWidgetByName('panel/legion_shop_cell.json')
		if not item then
			print('failed to create legion_shop_cell!')
		else
			local photoImg = getChild(item , 'photo_img' , 'UIImageView')
			photoImg:registerScriptTapHandler(function ()
				UISvr:showTipsForAward(value['Award1'])
			end)
			local photo = getChild(item , 'photo_ico' , 'UIImageView')
			local nameTx = getChild(item , 'name_tx' , 'UILabel')
			--local descTx = getChild(item , 'info_ta' , 'UITextArea')
			local priceTx = getChild(item , 'number_tx' , 'UILabel')
			local priceIcon = getChild(item , 'gong_ico' , 'UIImageView')
			nameTx:setPreferredSize(200,1)

			local itemId = value.Id
			local reward = UserData:getAward(value['Award1'])
			reward['sellprice'] = tonumber(value['Price'])
			if reward.type == 'material' then
				reward['desc'] = PlayerCoreData.getMaterialDesc( tonumber(reward.id) )
				reward['count'] = PlayerCoreData.getMaterialCount( tonumber(reward.id) )
			elseif reward.type == 'card' then
				reward['desc'] = string.format( getLocalString('E_STR_EXCHANGE_ROLE_DESC') , reward['name'] )
				reward['count'] = PlayerCoreData.getRoleCardCountById( tonumber(reward.id) )
			end

			self:registerButtonWithHandler(item , 'exchange_tbtn' , BUTTON_SOUND_TYPE.CLICK_EFFECT , function ()
				if reward.type == 'material' then
					reward['count'] = PlayerCoreData.getMaterialCount( tonumber(reward.id) )
				elseif reward.type == 'card' then
					reward['count'] = PlayerCoreData.getRoleCardCountById( tonumber(reward.id) )
				end
				openLegionExchangePanel(reward , function (id , num )
					print('id = ' .. id .. ' , num = ' .. num )
					LegionController.sendLegionShopExchangeRequset(itemId , num , function ( response )
						if response.code == 0 then
							LegionMainPanel:update()
						end
					end)
				end)
			end)

			photo:setTexture(reward.icon)
			nameTx:setText(reward.name)
			nameTx:setColor(reward.color)
			--descTx:setText(reward.desc)
			priceTx:setTextFromInt(reward.sellprice)
			priceIcon:setTexture(MyLegion:getHonorIcon())

			--shopSv:addChildToBottom(item)
			shopSv:addChildToRight(item)
		end
	end)
	shopSv:scrollToTop()
end

function LegionShopPage:makeData()
	self.shopData = {}

	local conf = GameData:getArrayData('shopexchange.dat')
	for _, v in pairs(conf) do
		if v.Key == 'legion' then
			table.insert(self.shopData , v)
		end
	end
end

function LegionShopPage:release()
	print('LegionShopPage release ... ')
	LegionPage.release(self)

	self.shopData = nil
end