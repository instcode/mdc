genUpdateNoticePanel = function ( content )
	local function createPanel()

		local function getChild( parent , name , ttype )
			return tolua.cast(parent:getChildByName(name) , ttype)
		end
		
		local sceneObj = SceneObjEx:createObj('panel/update_notice.json' , 'UpdateNoticePanel-in-lua')
		local panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('notice_bg_img' , 'notice_img')

		panel:registerInitHandler(function ()
			local root = panel:GetRawPanel()

			local closeBtn = getChild(root ,'ok_btn' , 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			local contentSV = getChild(root , 'content_sv' , 'UIScrollView')
			contentSV:setClippingEnable(true)
			local svSize = contentSV:getContentSize()

			local label = CCLabelTTF:create(content , '黑体' , 24)
			label:setAnchorPoint( ccp(0,0) )
			label:setDimensions( CCSizeMake(svSize.width , 0) )
			label:setPosition( ccp(0 , 0) )
			label:setHorizontalAlignment(kCCTextAlignmentLeft)
			local labelSize = label:getContentSize()

			local panel = UIPanel:create()
			panel:setAnchorPoint( ccp(0,1) )
			panel:setPosition( ccp( 0 , svSize.height) )
			panel:getValidNode():addChild( label )
			panel:setSize( CCSizeMake(labelSize.width , labelSize.height) )
		
			contentSV:addChild( panel )
			contentSV:scrollToTop()
		end)

		UiMan.show(sceneObj)
	end

	cclog(content)
	createPanel()
end