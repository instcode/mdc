-- 加入军团页面

LegionJoinPage = LegionPage:new{
	jsonFile = 'panel/legion_join_panel.json',
	panelName = 'legion-join-panel',

	page = nil,
	datas = nil,
	cells = nil,
	currPageEditbox = nil,
	legionNumPerPage = nil,
	gotoPage = nil,
	leftBtn = nil,
	rightBtn = nil,
	searchName = nil,
	legions = nil,
	maxPage = nil,
	gotoPageEditbox = nil
}

function LegionJoinPage:init()
	print('--- LegionJoinPage: init() ---')
	self.datas = {}
	self.cells = {}
	local MIN_PAGE = 1
	self.searchName = ""
	self.legionNumPerPage = 0
	self.gotoPage = 1
	self.page = 1

	local searchPl = tolua.cast(self.panel:getChildByName('search_pl'), 'UIPanel')
	local fangdaIco = tolua.cast(self.panel:getChildByName('fangda_ico'), 'UIImageView')
	local searchEditbox = self:createCCEditbox(self.panel, 'input_bg_ico')
	searchEditbox:setFontSize(24)
	local infoBgImg = tolua.cast(self.panel:getChildByName('info_bg_img'), 'UIImageView')

	for i = 1, 3 do
		local cell = LegionJoinCell.createCell()
		cell:getPanel():setPosition(ccp(-370,170 - i * 100))
		infoBgImg:addChild(cell:getPanel())
		cell:getPanel():setVisible(false)
		table.insert(self.cells, cell)
	end
	self.currPageEditbox = self:createCCEditbox(self.panel, 'su_bg_ico')
	self.currPageEditbox:setInputMode(kEditBoxInputModeNumeric)
	self.currPageEditbox:setHAlignment(kCCTextAlignmentCenter)
	self.currPageEditbox:setTextFromInt(1)
	self.currPageEditbox:setFontSize(40)
	self.currPageEditbox:setTouchEnabled(false)

	self.gotoPageEditbox = self:createCCEditbox(self.panel, 'su_1_bg_ico')
	self.gotoPageEditbox:setInputMode(kEditBoxInputModeNumeric)
	self.gotoPageEditbox:setHAlignment(kCCTextAlignmentCenter)
	self.gotoPageEditbox:setTextFromInt(1)
	self.gotoPageEditbox:setFontSize(40)
	self.gotoPageEditbox:registerScriptEditBoxHandler(function (eventType)
		if eventType == 'ended' then
			local num = self.gotoPageEditbox:getTextFromInt()
			if num < MIN_PAGE then
				self.gotoPageEditbox:setTextFromInt(self.gotoPage)
			elseif 	num > self.maxPage then
				self.gotoPageEditbox:setTextFromInt(self.maxPage)
			else
				self.gotoPageEditbox:setTextFromInt(num)
			end
		elseif eventType == 'began' then
			self.gotoPage = self.gotoPageEditbox:getTextFromInt()
		end
	end)

	self.leftBtn = tolua.cast(self.panel:getChildByName('left_btn'), 'UIButton')
	self.rightBtn = tolua.cast(self.panel:getChildByName('right_btn'), 'UIButton')
	GameController.addButtonSound(self.leftBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	GameController.addButtonSound(self.rightBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	self.leftBtn:disable()
	-- 点击下一页
	self.leftBtn:registerScriptTapHandler( function ()
		CNumEditorAct:getInst():numDecOnce(self.leftBtn, self.currPageEditbox, self.rightBtn, MIN_PAGE)
		self:requestNextPage()
	end)
	-- 点击上一页
	self.rightBtn:registerScriptTapHandler( function ()
		CNumEditorAct:getInst():numAddOnce(self.leftBtn, self.currPageEditbox, self.rightBtn, 9999)
		self:requestNextPage()
	end)

	-- 点击搜索
	fangdaIco:registerScriptTapHandler(function ()
		self.searchName = searchEditbox:getText()
		self.page = 1
		LegionController.sendLegionSearchRequest(self.searchName, function (response)
			local code = tonumber(response.code)
			if code == 0 then
				LegionJoinPage:setSearchResult(response.data)
				self.currPageEditbox:setTextFromInt(self.page)
				self.leftBtn:disable()
			end 
		end)
	end)

	local goBtn = tolua.cast(self.panel:getChildByName('go_tbtn'), 'UIButton')
	GameController.addButtonSound(goBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	-- 点击跳转
	goBtn:registerScriptTapHandler(function ()
		local ct = self.gotoPageEditbox:getTextFromInt()
		if ct < 0 then 
			return 
		end
		if ct > self.maxPage then
			GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_SEARCH_TURN_OVER_PAGE'), MESSAGE_BOX_TYPE.OK)
			return
		end
		self.page = ct
		self:updatePanel()
		self.currPageEditbox:setTextFromInt(self.page)
	end)
end

function LegionJoinPage:requestNextPage()
	local ct = self.currPageEditbox:getTextFromInt()
	if ct < 0 then 
		return 
	end
	self.page = ct
	self:updatePanel()
	self.currPageEditbox:setTextFromInt(self.page)
end

function LegionJoinPage:setSearchResult(data)
	self.legions = {}
	for k, v in pairs(data.legions) do
		table.insert(self.legions, v)
		v.lid = tonumber(k)
	end
	self.maxPage = math.ceil(#self.legions/3)
	-- 已申请的军团排在最前面，已申请的军团超过两个就按id排序，未申请的军团按照等级由高到低顺序排列，等级相同按照ID由小到大排列
	table.sort(self.legions, function (a, b)
		local isApplicant1 = false
		local isApplicant2 = false
		for k, v in pairs(MyLegion.applicant_id) do
			if a.lid == tonumber(v) then
				isApplicant1 = true
			end
			if b.lid == tonumber(v) then
				isApplicant2 = true
			end
		end
		if isApplicant1 and isApplicant2 then
			return tonumber(a.lid) < tonumber(b.lid)
		else
			if isApplicant1 then
				return true
			else
				if isApplicant2 then
					return false
				else
					if tonumber(a.level) == tonumber(b.level) then
						return tonumber(a.lid) < tonumber(b.lid)
					else
						return tonumber(a.level) > tonumber(b.level)
					end
				end
			end
		end
	end)
	self:updatePanel()
end

-- 更新搜索页面
function LegionJoinPage:updatePanel()
	self.datas = {}
	local index = 1
	for i = 1, 3 do
		if self.legions[(self.page-1)*3+i] ~= nil then
			table.insert(self.datas, self.legions[(self.page-1)*3+i])
			if index <= #self.cells then	
				self.cells[index]:getPanel():setVisible(true)
				index = index + 1
			end
		else
			break
		end
	end
	-- 如果当前cell不足3个，那么隐藏多的cell
	for i = index, 3 do
		self.cells[i]:getPanel():setVisible(false)
	end
	-- 更新cell
	self:updateScrollView(self.datas, self.cells)
	-- 更新button状态
	self.legionNumPerPage = index - 1
	if self.legionNumPerPage == 0 then
		self.rightBtn:disable()
	elseif self.legionNumPerPage < 3 then
		self.leftBtn:active()
		self.rightBtn:disable()
	else
		self.rightBtn:active()
		self.leftBtn:active()
	end
	if self.page == 1 then
		self.leftBtn:disable()
	elseif self.page >= self.maxPage then
		self.rightBtn:disable()
	end
end

-- 申请或者取消申请后重新刷新下界面
function LegionJoinPage:refreshPanel()
	self:updateScrollView(self.datas, self.cells)
	-- 已申请的军团排在最前面，已申请的军团超过两个就按id排序，未申请的军团按照等级由高到低顺序排列，等级相同按照ID由小到大排列
	table.sort(self.legions, function (a, b)
		local isApplicant1 = false
		local isApplicant2 = false
		for k, v in pairs(MyLegion.applicant_id) do
			if a.lid == tonumber(v) then
				isApplicant1 = true
			end
			if b.lid == tonumber(v) then
				isApplicant2 = true
			end
		end
		if isApplicant1 and isApplicant2 then
			return tonumber(a.lid) < tonumber(b.lid)
		else
			if isApplicant1 then
				return true
			else
				if isApplicant2 then
					return false
				else
					if tonumber(a.level) == tonumber(b.level) then
						return tonumber(a.lid) < tonumber(b.lid)
					else
						return tonumber(a.level) > tonumber(b.level)
					end
				end
			end
		end
	end)
end
	
function LegionJoinPage:release()
	LegionPage.release(self)
	self.page = nil
	self.datas = nil
	self.cells = nil
	self.currPageEditbox = nil
	self.legionNumPerPage = nil
	self.gotoPage = nil
	self.leftBtn = nil
	self.rightBtn = nil
	self.searchName = nil
	self.legions = nil
	self.maxPage = nil
	self.gotoPageEditbox = nil
end
