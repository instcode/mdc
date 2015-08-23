-- LegionPage继承于LegionView，通过直接创建UIPanel
LegionPage = LegionView:new{
}

function LegionPage:create()
	if not self.jsonFile then
		print('=== self.jsonFile is nil!!!! ===')
		return
	end

	self.panel = createWidgetByName(self.jsonFile)
	self:init()
	return self.panel
end