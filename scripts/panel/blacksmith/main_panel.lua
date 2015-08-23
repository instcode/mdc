
local main_panel = {}
local data = require('ceremony/panel/blacksmith/data'):mainPanel()

function main_panel:inst()
	local o = {

	}

	setmetatable(o, self)
	self.__index = self
	return o
end

-- 打开界面
function main_panel:open()
	-- 初始化界面
	local sceneObj = SceneObjEx:createObj('panel/blacksmith_bg_panel.json' , 'blacksmith-bg-in-lua')
	local panelObj = sceneObj:getPanelObj()
	panelObj:setAdaptInfo('blacksmith_bg_img' , 'blacksmith_img')

	panelObj:registerInitHandler(function (  )
		-- init call back function
		local root = panelObj:GetRawPanel()
		local elements = data.elements

		elements.closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		elements.closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		elements.closeBtn:setWidgetZOrder( 9999 )
		GameController.addButtonSound(elements.closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		elements.strengthenBtn = tolua.cast(root:getChildByName('title_1_btn'), 'UIButton')
		elements.strengthenBtn:setWidgetZOrder(9999)
		elements.closeBtn:registerScriptTapHandler(function (  )
			-- todo:
			-- switch to strengthen card
		end)
		GameController.addButtonSound(elements.strengthen , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		elements.forgeBtn = tolua.cast(root:getChildByName('title_2_btn'), 'UIButton')
		elements.forgeBtn:setWidgetZOrder(9999)
		elements.forgeBtn:registerScriptTapHandler(function (  )
			-- todo:
			-- switch to forge card
		end)
		GameController.addButtonSound(elements.forgeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		elements.inlayBtn = tolua.cast(root:getChildByName('title_3_btn'), 'UIButton')
		elements.inlayBtn:setWidgetZOrder(9999)
		elements.inlayBtn:registerScriptTapHandler(function (  )
			-- todo:
			-- switch to forge card
		end)
	end)

	UiMan.show(sceneObj)
end

return main_panel



