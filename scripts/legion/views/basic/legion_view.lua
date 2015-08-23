-- 军团所有的界面都由此派生，并提供一些基本的属性和公共方法。
-- 继承后只需要设置'jsonFile', 'panelName'的值和重写init()方法即可

LegionView = {
	sceneObject = nil,
	jsonFile = '',
	panelName = '',
	panel,

	container = nil, 	-- 如果界面含有多个标签页，container为标签页内容的容器
	tags = nil,			-- 标签页的按钮(或者是其他空间)
	pages = nil, 		-- 标签页的内容,见"LegionPage.lua"

	data = nil			-- 如果显示界面需要传入临时数据，使用showWithData(data)方法
}

function LegionView:showWithData( data )
	self.data = data
	LegionController.show(self)
end

function LegionView:new( o )
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- 在create的时候调用
function LegionView:init()
end

function LegionView:create()
	self.sceneObject = SceneObjEx:createObj(self.jsonFile, self.panelName)
	self.panel = self.sceneObject:getPanelObj()
	self:init()
	return self.sceneObject
end

function LegionView:release()
	print('--- LegionView: release() ---')
	self.sceneObject = nil
	self.container = nil
	self.panel = nil
	self.data = nil
	self.tags = nil
	self.pages = nil

	if type(self.pages) == 'table' then
		table.foreach(self.pages, function( k, page )
			page:release()
		end)
	end
end

function LegionView:addPageToPanel( page, container )
	local panel = page:getPanel()
	local pageSz = panel:getContentSize()
	local containerSz = self.container:getContentSize()
	local pos = ccp((containerSz.width - pageSz.width) / 2, containerSz.height - pageSz.height)
	panel:setPosition(pos)

	container:addChild(panel)
end

function LegionView:getScene()
	return self.sceneObject
end

function LegionView:getPanel()
	return self.panel
end

-- 注册button的方法
function LegionView:registerButtonWithHandler( root, name, soundEffect, callback )
	local button = tolua.cast(root:getChildByName(name), 'UIButton')
	
	if soundEffect then
		GameController.addButtonSound(button, soundEffect)
	end

	if callback then
		button:registerScriptTapHandler(callback)
	end
	
	return button
end

-- UIImageView转换成CCEditBox
function LegionView:createCCEditbox( root, name )
	local inputImg = tolua.cast(root:getChildByName(name), 'UIImageView')
	return tolua.cast(UISvr:replaceUIImageViewByCCEditBox(inputImg) , 'CCEditBox')
end

-- 点击标签页切换标签的公共方法
function LegionView:switchPage( index )
	local page = self.pages[index]
	local pagePanel = page:getPanel()
	if not pagePanel then
		pagePanel = page:create()
	end

	table.foreach(self.pages, function ( i, v )
		local p = v:getPanel()
		local visible = i == index

		if visible then
			self.tags[i]:setPressState(WidgetStateSelected)
			self.tags[i]:setTouchEnable(false)
		else
			self.tags[i]:setPressState(WidgetStateNormal)
			self.tags[i]:setTouchEnable(true)
		end

		if p then
			p:setVisible(visible)
		end
	end)
	page:update()
	self:addPageToPanel(page, self.container)
end

-- 把cells加按方向加到scrollview
function LegionView:bindCellsToScrollView( cells, scrollview, direction )
	if direction == nil then
		direction = SCROLLVIEW_DIR_VERTICAL
	end

	if direction == SCROLLVIEW_DIR_VERTICAL then
		table.foreach(cells, function( i, cell )
			scrollview:addChildToBottom(cell:getPanel())
		end)
	elseif direction == SCROLLVIEW_DIR_HORIZONTAL then
		table.foreach(cells, function( i, cell )
			scrollview:addChildToRight(cell:getPanel())
		end)
	else
		return false
	end

	scrollview:setClippingEnable(true)
end

-- 同步datas和cells，index为从第几个开始同步
function LegionView:updateScrollView( datas, cells, index )
	index = index or 1
	local size = #datas
	if size > #cells then
		size = #cells
	end
	
	for i = index, size do
		cells[i]:update(datas[i])
	end
end

function LegionView:update()
end

LEGION_VIEW_POSITION = readOnly{
	TOP_LEFT = 1,
	TOP_MIDDLE = 2,
	TOP_RIGHT = 3,

	MIDDLE_LEFT = 4,
	MIDDLE_MIDDLE = 5,
	MIDDLE_RIGHT = 6,

	BOTTOM_LEFT = 7,
	BOTTOM_MIDDLE = 8,
	BOTTOM_RIGHT = 9
}

-- 按屏幕九宫位置适配
function LegionView:adaptChildToScreen( child, position )
	if position < 1 or position > 9 then
		return false
	end

	local x
	local y

	local winSize = CCDirector:sharedDirector():getWinSize()
	local anchor = child:getAnchorPoint()
	local size = child:getContentSize()

	if position == 1 or position == 4 or position == 7 then
		x = anchor.x * size.height
	elseif position == 2 or position == 5 or position == 8 then
		x = winSize.width * 0.5 - (0.5 - anchor.x) * size.width
	else--if position = 3 or position = 6 or position = 9 then
		x = winSize.width - (1 - anchor.x) * size.width
	end

	if position == 1 or position == 2 or position == 3 then
		y = winSize.height - (1 - anchor.y) * size.height
	elseif position == 4 or position == 5 or position == 6 then
		y = winSize.height * 0.5 - (0.5 - anchor.y) * size.height
	else--if position = 7 or position = 8 or position = 9 then
		y = anchor.y * size.height
	end

	print(string.format("===== Adapted position: (%d, %d) =====", x, y))
	child:setPosition(ccp(x, y))
end