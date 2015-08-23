LegionWarTipsPanel = LegionView:new{
	jsonFile = 'panel/legion_tips_panel.json',
	panelName = 'legion-tips-panel'
}


function LegionWarTipsPanel:showWithData( data )
	self.data = data
	if self.data.name and self.data.job then
		LegionWarController.show(self, ELF_SHOW.ZOOM_IN)
	else
		cclog('failed to show LegionWarTipsPanel ... ')
	end
end

local attr = {
	Attack = 'LEGION_ALL_ROLE_ATTACK_BUFF',
	Health = 'LEGION_ALL_ROLE_HEALTH_BUFF',
	Defence = 'LEGION_ALL_ROLE_DEFENCE_BUFF',
	Mdefence = 'LEGION_ALL_ROLE_MDEFENCE_BUFF'
}

function LegionWarTipsPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('tips_bg_img', 'tips_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local bgImg = tolua.cast(root:getChildByName('tips_bg_img'), 'UIImageView')
		bgImg:registerScriptTapHandler(function()
			LegionWarController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
			end)
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionWarController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local nameTx = tolua.cast(root:getChildByName('name_tx') , 'UILabel')
		nameTx:setText(self.data.name or '')

		local URL_MAP = {
			emperor = { ico = 'uires/ui_2nd/com/panel/army_war/king_ico.png', img = 'uires/ui_2nd/image/hero/king_big.png'},
			general = { ico = 'uires/ui_2nd/com/panel/army_war/jiang_ico.png', img = 'uires/ui_2nd/image/hero/lvbu_big.png'},
			premier = { ico = 'uires/ui_2nd/com/panel/army_war/cheng_ico.png', img = 'uires/ui_2nd/image/hero/simayi_big.png'}
		}

		local crownIco = tolua.cast(root:getChildByName('crown_ico') , 'UIImageView')
		crownIco:setTexture( URL_MAP[self.data.job].ico or '')

		local roleIco = tolua.cast(root:getChildByName('role_img') , 'UIImageView')
		roleIco:setTexture( URL_MAP[self.data.job].img or '')

		local bg = tolua.cast(root:getChildByName('xian_ico') , 'UIImageView')

		local conf = GameData:getMapData( 'legionwarbuff.dat' )[self.data.job]

		local tab = {}
		for k, v in pairs (conf) do
			if attr[k] then
				if tonumber(v) > 0 then
					table.insert( tab , {attrtype = k , percent = v})
				end
			end
		end

		local parth = bg:getContentSize().height / (#tab + 1)

		for i = 1 , #tab do
			local item = self:makeItem( tab[i]['attrtype'] , tab[i]['percent'] )
			item:setPosition( ccp( bg:getContentSize().width / 3 + 80, i * parth) )
			bg:addChild(item)
		end
	end)
end

function LegionWarTipsPanel:makeItem( attrtype , percent )
	local text_1 = UILabel:create()
	text_1:setAnchorPoint( ccp(1 , 0.5) )
	text_1:setFontSize(22)
	text_1:setText( LegionConfig:getLegionLocalText('LEGION_ALL_ASSIGN_ROLE_DESC') )

	local text_2 = UILabel:create()
	text_2:setAnchorPoint( ccp(0 , 0.5) )
	text_2:setFontSize(22)
	print(attrtype)
	text_2:setText( string.format( LegionConfig:getLegionLocalText(attr[attrtype]) , tonumber(percent) ) )
	text_2:setPosition( ccp(0 , 0) )
	text_2:setColor( ccc3(0,255,0) )

	text_1:addChild(text_2)

	return text_1
end

function LegionWarTipsPanel:release()
	LegionView.release(self)
end