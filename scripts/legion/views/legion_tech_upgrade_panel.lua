LegionTechUpgradePanel = LegionView:new{
	jsonFile = 'panel/legion_upgrade_panel.json',
	panelName = 'legion-tech-upgrade-panel',
	data = nil,
	honorNum = nil,
	techLvNow = nil,
	techLvNext = nil,
	techDescNow = nil,
	techDescNext = nil,
	techAddNow = nil,
	techAddNext = nil,
	res_ico  = nil,
	need_res_ico = nil,
	need_res_bg  = nil,
	need_res_num = nil,
	tech_ico = nil,
	tech_name = nil,
}

function LegionTechUpgradePanel:showWithData( data )
	self.data = LegionConfig:getTechDataByKeyandLv(data.id,data.level)
	LegionController.show(self, ELF_SHOW.ZOOM_IN)
end

function LegionTechUpgradePanel:init()
	cclog('LegionTechUpgradePanel:init')
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('tech_skill_bg_img', 'tech_skill_img')

	local function update()
		self.techLvNow:setText('Lv' ..self.data.Level)
		self.techLvNow:setColor(COLOR_TYPE.ORANGE)
		self.techLvNext:setText('Lv' ..(self.data.Level+1))
		self.techLvNext:setColor(COLOR_TYPE.ORANGE)
		self.techDescNow:setText(GetTextForCfg(self.data.Desc2))
		self.techDescNext:setText(GetTextForCfg(self.data.Desc3))
		self.need_res_num:setText(MyLegion.order .. '/' .. self.data.MaterialNum)
		self.tech_name:setText(GetTextForCfg(self.data.Name))
		self.tech_name:setColor(COLOR_TYPE.RED)
		local TechUrlResource = 'uires/ui_2nd/image/' .. self.data.TechUrl
		--cclog('TechUrlResource ====' ..TechUrlResource )
		self.tech_ico:setTexture(TechUrlResource)
		local time =self.data.Time
		
		--self.res_ico:setTexture(PlayerCoreData.getMaterialIco(tonumber(self.data.Material)))
		--self.res_ico:setScale(1)
		--self.need_res_ico:setTexture(PlayerCoreData.getMaterialIco(tonumber(self.data.Material)))
		self.honorNum:setText(MyLegion.order)
	end
	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		self:registerButtonWithHandler(root, 'upgrade_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			--cclog('todo upgrade')
			if tonumber(self.data.MaterialNum) > tonumber(MyLegion.order) then
				GameController.showPrompts(LegionConfig:getLegionLocalText('E_STR_TECH_UPGRADE_ERROR_NEED_ORDER'), COLOR_TYPE.RED)
				--return
			else
				if tonumber(self.data.Level) < tonumber(MyLegion.level) then
					LegionController.sendLegionTechUpgradeRequset(self.data.Id, function (response)
						local code = tonumber(response.code)
						if tonumber(code) == 0 then
							GameController.showPrompts(LegionConfig:getLegionLocalText('E_STR_TECH_UPGRADE_SUCC'), COLOR_TYPE.GREEN)
							LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
							LegionTechPage:update()
						end
					end)
				else
					GameController.showPrompts(LegionConfig:getLegionLocalText('E_STR_TECH_UPGRADE_ERROR_LEVEL_LIMIT'), COLOR_TYPE.RED)
				end
			end

		end)

		self.honorNum = tolua.cast(root:getChildByName('skill_book_num_tx'), 'UILabel')	
		self.res_ico = tolua.cast(root:getChildByName('skill_book_ico'), 'UIImageView')
		local card1 = tolua.cast(root:getChildByName('card_1_ico'),'UIImageView')
		self.techLvNow = tolua.cast(card1:getChildByName('lv_tx'), 'UILabel')
		--self.techLvNow:setText('xxxxxxx')
		self.techDescNow = tolua.cast(card1:getChildByName('info_tx'),'UITextArea')
		self.techAddNow = tolua.cast(card1:getChildByName('add_tx'), 'UILabel')

		local card2 = tolua.cast(root:getChildByName('card_2_ico'),'UIImageView')
		self.techLvNext = tolua.cast(card2:getChildByName('lv_tx'), 'UILabel')
		self.techDescNext = tolua.cast(card2:getChildByName('info_tx'),'UITextArea')
		self.techAddNext = tolua.cast(card2:getChildByName('add_tx'), 'UILabel')

		self.need_res_ico = tolua.cast(root:getChildByName('book_ico'),'UIImageView')
		self.need_res_num = tolua.cast(root:getChildByName('book_num_tx'),'UILabel')
		self.need_res_bg = tolua.cast(root:getChildByName('skill_photo_ico'),'UIImageView')

		self.tech_ico = tolua.cast(root:getChildByName('tech_ico'),'UIImageView')
		self.tech_name = tolua.cast(root:getChildByName('tech_name_tx'),'UILabel')
		self.time_tx = tolua.cast(root:getChildByName('time_tx'),'UILabel')

		update()
	end)

end
function LegionTechUpgradePanel:release()
	LegionPage.release(self)

	self.data = nil
	self.honorNum = nil
	self.techLvNow = nil
	self.techLvNext = nil
	self.techDescNow = nil
	self.techDescNext = nil
	self.techAddNow = nil
	self.techAddNext = nil
	self.res_ico  = nil
	self.need_res_ico = nil
	self.need_res_bg  = nil
	self.need_res_num = nil
	self.tech_ico = nil
	self.tech_name = nil
end