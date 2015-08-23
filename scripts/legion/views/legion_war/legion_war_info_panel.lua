--赛况界面--

LegionWarInfoPanel = LegionView:new{
	jsonFile = 'panel/legion_war_info_panel.json',
	panelName = 'legion-war-info-panel',

	resultSv = nil,
	tags = nil,
	curTags = nil
}

function LegionWarInfoPanel:showWithData( data )
	self.data = data
	LegionController.show(self , ELF_SHOW.SLIDE_IN)
end

function LegionWarInfoPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('di_ico', 'di_ico_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		self.resultSv = tolua.cast(root:getChildByName('saikuang_sv') , 'UIScrollView')
		self.resultSv:setClippingEnable(true)

		self.tags = {}
		for i = 1 , 2 do
			local btn = tolua.cast(root:getChildByName('left_' .. i .. '_btn') , 'UIButton')
			btn:registerScriptTapHandler( function ()
				self:switchPage( i )
			end)
			GameController.addButtonSound( btn , BUTTON_SOUND_TYPE.CLICK_EFFECT )
			table.insert(self.tags , btn)

			local nameTx = tolua.cast(btn:getChildByName('name_tx') , 'UILabel')
			nameTx:setPreferredSize(185,1)

			if i == 1 then
				if ( tonumber(self.data.progress) == 1 and self.data.waring == false ) or 
					self.data.progress == 'register' or self.data.progress == 'after_register' then
					nameTx:setText(LegionConfig:getLegionLocalText('LEGION_FINAL_WAR_DESC'))
				end
			end
		end

		-- 默认选中第一个标签页
		self:switchPage( 1 )
	end)
end

function LegionWarInfoPanel:updateSv()
	self.resultSv:removeAllChildrenAndCleanUp(true)

	if self.curTags == 1 then
		self:makeOnePage()
	elseif self.curTags == 2 then
		self:makeTwoPage()
	end
end

function LegionWarInfoPanel:makeOnePage()
	local legionWins = self.data.legion_wins
	if legionWins then
		-- add items
		if #legionWins >= 1 then
			local progress = tonumber(self.data.progress)
			local waring = self.data.waring
			local notice
			if progress then
				if (progress == 9 and waring == false) or (progress == 3 and waring == true) then
					notice = 'LEGION_ONE_TURN_DESC'
				elseif (progress == 3 and waring == false) or (progress == 1 and waring == true) then
					notice = 'LEGION_TWO_TURN_DESC'
				elseif progress == 1 and waring == false then
					notice = 'LEGION_FINAL_WAR_RESULT_DESC'
				end
				
			elseif self.data.progress == 'register' or self.data.progress == 'after_register' then
				notice = 'LEGION_LAST_FINAL_WAR_RESULT_DESC'
			end
			if notice then
				self.resultSv:addChildToBottom( self:makeTitleTurnCell( LegionConfig:getLegionLocalText(notice) ) )
			end
		end

		-- table.sort( legionWins , function ( a , b )
		-- 	return a[2] > b[2]
		-- end)

		-- add turn title
		for rank = 1 , #legionWins do
			self.resultSv:addChildToBottom( self:makeOnePageCell( legionWins[rank] , rank ) )
		end
	end

	self.resultSv:scrollToTop()
end

function LegionWarInfoPanel:makeTwoPage()
	local turnIndex = 0

	local wins = self.data.wins

	for turn = 1 , #wins do
		-- add turn title
		turnIndex = turnIndex + 1
		local notice
		if turnIndex == 1 then
			notice = 'LEGION_ONE_TURN_DESC'
		elseif turnIndex == 2 then
			notice = 'LEGION_TWO_TURN_DESC'
		elseif turnIndex == 3 then
			notice = 'LEGION_THREE_TURN_DESC'
		end
		self.resultSv:addChildToBottom( self:makeTitleTurnCell( LegionConfig:getLegionLocalText(notice) ) )
		-- add items
		local turnData = wins[turn]

		for rank = 1 , #turnData do
			self.resultSv:addChildToBottom( self:makeTwoPageCell( turnData[rank] , turn , rank ) )
		end
	end

	if turnIndex > 0 then
		local str
		if turnIndex == 1 or turnIndex == 2 then
			str = self.data.inwar and 'LEGION_BATTLE_PROMOTION_SUCCESS' or 'LEGION_WEED_OUT_DESC'
			self.resultSv:addChildToBottom( self:makeTitleTurnCell( LegionConfig:getLegionLocalText(str) ) )
		elseif turnIndex == 3 then 
			str = self.data.inwar and 'LEGION_PROMOTE_EMPEROR' or 'LEGION_WEED_OUT_DESC'
			self.resultSv:addChildToBottom( self:makeTitleTurnCell( LegionConfig:getLegionLocalText(str) ) )
		end
	end

	self.resultSv:scrollToTop()
end

function LegionWarInfoPanel:makeTitleTurnCell( str )
	local panel = UIPanel:create()
	panel:setAnchorPoint( ccp(0 , 0) )
	panel:setSize( CCSizeMake(590 , 99) )

	local turnTx = UILabel:create()
	turnTx:setAnchorPoint( ccp(0.5 , 0.5) )
	turnTx:setFontSize( 28 )
	turnTx:setText( str )
	turnTx:setPosition( ccp(590 / 2 , 99 / 2) )
	turnTx:setPreferredSize(550,1)

	panel:addChild(turnTx)

	return panel
end

local RANK_URL = {
	'uires/ui_2nd/com/panel/trena/1.png',
	'uires/ui_2nd/com/panel/trena/2.png',
	'uires/ui_2nd/com/panel/trena/3.png'
}

-- data = ['军团',积分, 勋章], rank : 排名
function LegionWarInfoPanel:makeOnePageCell( data , rank )
	local cell = createWidgetByName('panel/legion_war_info_1_cell.json')
	if cell then
		local legionNameTx = tolua.cast( cell:getChildByName('legion_name_tx') , 'UILabel')
		local scoreTx = tolua.cast( cell:getChildByName('score_tx') , 'UILabel')
		local scoreNameTx = tolua.cast( cell:getChildByName('score_name_tx') , 'UILabel')
		local legionIco = tolua.cast( cell:getChildByName('legion_ico') , 'UIImageView')
		local rankIco = tolua.cast( cell:getChildByName('ranking_ico') , 'UIImageView')
		local rankTx = tolua.cast( cell:getChildByName('rank_tx') , 'UILabel')

		legionNameTx:setText( data[1] or '')
		scoreTx:setText( tostring(data[2] or 0) )
		legionIco:setTexture('uires/ui_2nd/com/panel/legion/' .. data[3] .. '_jun.png')

		if rank <= 3 then
			rankIco:setTexture( RANK_URL[rank] )
			rankTx:setText('')
		else
			rankIco:setVisible(false)
			rankTx:setText( tostring(rank) )
		end

		if MyLegion.name == data[1] then
			legionNameTx:setColor( ccc3(0,255,0) )
			scoreNameTx:setColor( ccc3(0,255,0) )
			scoreTx:setColor( ccc3(0,255,0) )
		end

	else
		print( 'failed to create legion_war_info_1_cell ...' )
	end

	return cell
end
-- data : ['军团',积分, 勋章] , turn : 第几轮 , rank : 排名
function LegionWarInfoPanel:makeTwoPageCell( data , turn , rank )
	local cell = createWidgetByName('panel/legion_war_info_2_cell.json')
	if cell then
		local legionNameTx = tolua.cast( cell:getChildByName('legion_name_tx') , 'UILabel')
		local scoreTx = tolua.cast( cell:getChildByName('score_num_tx') , 'UILabel')
		local legionIco = tolua.cast( cell:getChildByName('legion_ico') , 'UIImageView')
		local rankIco = tolua.cast( cell:getChildByName('ranking_ico') , 'UIImageView')
		local scoreNameTx = tolua.cast( cell:getChildByName('score_tx') , 'UILabel')
		local rankTx = tolua.cast( cell:getChildByName('rank_tx') , 'UILabel')
		local expTx = tolua.cast( cell:getChildByName('exp_num_tx') , 'UILabel')
		local stoneTx = tolua.cast( cell:getChildByName('stone_num_tx') , 'UILabel')

		legionNameTx:setText( data[1] or '')
		scoreTx:setText( tostring(data[2] or 0) )
		legionIco:setTexture('uires/ui_2nd/com/panel/legion/' .. data[3] .. '_jun.png')

		local turns = { 9 , 3 , 1 }

		if rank <= 3 then
			rankIco:setTexture( RANK_URL[rank] )
			rankTx:setText('')

			local conf = LegionWarConfig:getRewardData( turns[turn] , rank )
			expTx:setText( '+' .. tostring(conf.LegionExp) )
			stoneTx:setText( '+' .. tostring(conf.Order) )

			if MyLegion.name == data[1] then
				legionNameTx:setColor( ccc3(0,255,0) )
				scoreNameTx:setColor( ccc3(0,255,0) )
				scoreTx:setColor( ccc3(0,255,0) )
				expTx:setColor( ccc3(0,255,0) )
				stoneTx:setColor( ccc3(0,255,0) )
			end

		else
			rankIco:setVisible(false)
			rankTx:setText( tostring(rank) )
			expTx:setText( '0' )
			stoneTx:setText( '0' )
		end
	else
		print( 'failed to create legion_war_info_2_cell ...' )
	end

	return cell
end

function LegionWarInfoPanel:switchPage( index )

	for k , v in pairs (self.tags) do
		if k == index then
			self.tags[k]:setTouchEnable(false)
			self.tags[k]:setPressState(WidgetStateSelected)
		else
			self.tags[k]:setTouchEnable(true)
			self.tags[k]:setPressState(WidgetStateNormal)
		end
	end

	self.curTags = index

	self:updateSv()
end

function LegionWarInfoPanel:release()
	LegionView.release(self)

	self.tags = nil
	self.curTags = nil
	self.resultSv = nil
end
