
-- Yes and no
UiMan = {}

function UiMan.show(sceneObj, showType)
	showType = showType or ELF_SHOW.SMART
	CUIManager:GetInstance():ShowObject(sceneObj, showType)
end

function UiMan.hide(sceneObj, hideType)
	hideType = hideType or ELF_HIDE.SMART_HIDE
	CUIManager:GetInstance():HideObject(sceneObj, hideType)
end

function UiMan.genCloseHandler(sceneObj, shutdownType)
	shutdownType = shutdownType or ELF_HIDE.SMART_HIDE
	return function()
		CUIManager:GetInstance():HideObject(sceneObj, shutdownType)
	end
end

function UiMan.isPanelPresent(name)
	return CUIManager:GetInstance():IsPanelPresent(name)
end
