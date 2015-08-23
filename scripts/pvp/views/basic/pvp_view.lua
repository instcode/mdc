-- 军团所有的界面都由此派生，并提供一些基本的属性和公共方法。
-- 继承后只需要设置'jsonFile', 'panelName'的值和重写init()方法即可

PvpView = {
	sceneObject = nil,
	jsonFile = '',
	panelName = '',
	panel,

	container = nil, 	-- 如果界面含有多个标签页，container为标签页内容的容器
	tags = nil,			-- 标签页的按钮(或者是其他空间)
	pages = nil, 		-- 标签页的内容,见"LegionPage.lua"

	data = nil			-- 如果显示界面需要传入临时数据，使用showWithData(data)方法
}

function PvpView:showWithData( data )
	self.data = data
	LegionController.show(self)
end

function PvpView:new( o )
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function PvpView:enter()
end

-- 在create的时候调用
function PvpView:init()
end

function PvpView:create()
	self.sceneObject = SceneObjEx:createObj(self.jsonFile, self.panelName)
	self.panel = self.sceneObject:getPanelObj()
	self:init()
	 return self.sceneObject
end

function PvpView:release()
	print('--- PvpView: release() ---')
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

function PvpView:addPageToPanel( page, container )
	local panel = page:getPanel()
	local pageSz = panel:getContentSize()
	local containerSz = self.container:getContentSize()
	local pos = ccp((containerSz.width - pageSz.width) / 2, containerSz.height - pageSz.height)
	panel:setPosition(pos)

	container:addChild(panel)
end

function PvpView:getScene()
	return self.sceneObject
end

function PvpView:getPanel()
	return self.panel
end

-- 注册button的方法
function PvpView:registerButtonWithHandler( root, name, soundEffect, callback )
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
function PvpView:createCCEditbox( root, name )
	local inputImg = tolua.cast(root:getChildByName(name), 'UIImageView')
	return tolua.cast(UISvr:replaceUIImageViewByCCEditBox(inputImg) , 'CCEditBox')
end

-- 点击标签页切换标签的公共方法
function PvpView:switchPage( index )
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

function PvpView:update()
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
