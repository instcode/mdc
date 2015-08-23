OBzh = {
	isGet = false
}
function OBzh:isOpen()
	local activity = UserData:getLuaActivityData()
	if not activity then
		return false
	end
	local twOb = activity.tw_ob
	if not twOb then
		return false
	end
	if not twOb.role_got or twOb.role_got == 1 then
		return false
	end
	if self.isGet == true then
		return false
	end
	return true
end

function OBzh:getAwards(sceneObj)
	Message.sendPost('get_tw_ob_role', 'activity', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			-- print(res.data.awards)
			UserData.parseAwardJson(json.encode(res.data.awards))
			GameController.showPrompts(getLocalStringValue('E_STR_GET_SUCCEED'), COLOR_TYPE.GREEN)
		else
			GameController.showPrompts(getLocalStringValue('E_STR_ARENA_GOT_REWARD'), COLOR_TYPE.RED)
		end
		self.isGet = true
		CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
	end)
end

function OBzh:openObGetAwards()
	local sceneObj = nil
	local panel = nil

    local function init()
    	root = panel:GetRawPanel()
    	closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		getAwardsBtn = tolua.cast(root:getChildByName('get_awards_btn') , 'UIButton')
		getAwardsBtn:registerScriptTapHandler(function ()
			if CCApplication:sharedApplication():getTargetPlatform() == kTargetAndroid then
				local clientVersion
				local isOK = pcall(function ()
					clientVersion = PlayerCoreData.getClientBaseVersion()
				end)
				if isOK then
					self:getAwards(sceneObj)
				else
					--不能领奖
					GameController.showMessageBox(getLocalStringValue('E_STR_OB_CANNOT_GETAWARD'), MESSAGE_BOX_TYPE.OK)
				end
			else
				self:getAwards(sceneObj)
			end

		end)
		GameController.addButtonSound(getAwardsBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
    end

    local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/ob_zh_get_awards.json', 'ob-get-award-lua')
	    panel = sceneObj:getPanelObj()
	    panel:setAdaptInfo('ob_award_bg_img', 'ob_award_img')

		panel:registerInitHandler(init)
		UiMan.show(sceneObj)
	end

	createPanel()
end