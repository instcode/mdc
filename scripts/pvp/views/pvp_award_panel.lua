PvpAwardPanel = PvpView:new{
	jsonFile = 'panel/pvp_award_panel.json',
	panelName = 'pvp-award-in-lua',
}

local RankBtn
local RankSv
local DayBtn
local DaySv

local function onClickRankBtn()
	-- body
	RankSv:setVisible(true)
	DaySv:setVisible(false)
	DaySv:scrollToTop()
	RankBtn:setPressState(WidgetStateSelected);
	RankBtn:setTouchEnable(false);
	DayBtn:setPressState(WidgetStateNormal);
	DayBtn:setTouchEnable(true);
end

local function onClickDayBtn()
    RankSv:setVisible(false)
	DaySv:setVisible(true)
	RankSv:scrollToTop()
	DayBtn:setPressState(WidgetStateSelected);
	DayBtn:setTouchEnable(false);
	RankBtn:setPressState(WidgetStateNormal);
	RankBtn:setTouchEnable(true);
end

local function setRankAward(i,rewardVView)
	local topIco = tolua.cast(rewardVView:getChildByName('top_ico') , 'UIImageView')

	local bgImg = tolua.cast(rewardVView:getChildByName('bg_img') , 'UIImageView')
	if i%2 == 0 then
		bgImg:setVisible(false)
	else
		bgImg:setVisible(true)
	end
	local award = {}
	for j = 1, 4 do
		award[j] = {}
		award[j].awardPhotoIco = tolua.cast(rewardVView:getChildByName('photo_' .. j .. '_ico'), 'UIImageView')
		award[j].awardIco = tolua.cast(award[j].awardPhotoIco:getChildByName('award_ico'), 'UIImageView')
		award[j].numTx = tolua.cast(award[j].awardPhotoIco:getChildByName('award_num_tx'), 'UILabel')
		award[j].nameTx = tolua.cast(award[j].awardPhotoIco:getChildByName('award_name_tx'), 'UILabel')
		award[j].nameTx:setPreferredSize(130,1)
	end
	local award_1 = UserData:getAward(PvpData.RankAwardData[i].Award1)
	local award_2 = UserData:getAward(PvpData.RankAwardData[i].Award2)
	local award_3 = UserData:getAward(PvpData.RankAwardData[i].Award3)
	local award_4 = UserData:getAward(PvpData.RankAwardData[i].Award4)
	awards = {award_1,award_2,award_3,award_4}
	local giftAwards = {PvpData.RankAwardData[i].Award1,PvpData.RankAwardData[i].Award2,PvpData.RankAwardData[i].Award3,PvpData.RankAwardData[i].Award4}
	for k=1, 4 do
		award[k].awardPhotoIco:registerScriptTapHandler(function()
			UISvr:showTipsForAward(giftAwards[k])
		end)
		award[k].numTx:setText(toWordsNumber(tonumber(awards[k].count)))
		award[k].awardIco:setTexture(awards[k].icon)
		award[k].nameTx:setText(GetTextForCfg(awards[k].name))
	end

	-- for l,v in ipairs(PvpData.DayAwardData) do
		-- if i < tonumber(v.Rank) then
		-- 	topIco:setTexture(PvpData.DayAwardData[l - 1 ].Url)
		-- 	return
		-- else
			topIco:setTexture(PvpData.DayAwardData[i].Url)
		-- end
	-- end
end

local function setDayAward(i,rewardVView)
	local topIco = tolua.cast(rewardVView:getChildByName('top_ico') , 'UIImageView')
	topIco:setTexture(PvpData.DayAwardData[i].Url)
	local bgImg = tolua.cast(rewardVView:getChildByName('bg_img') , 'UIImageView')
	if i%2 == 0 then
		bgImg:setVisible(false)
	else
		bgImg:setVisible(true)
	end
	local award = {}
	for j = 1, 3 do
		award[j] = {}
		award[j].awardPhotoIco = tolua.cast(rewardVView:getChildByName('photo_' .. j .. '_ico'), 'UIImageView')
		award[j].awardIco = tolua.cast(award[j].awardPhotoIco:getChildByName('award_ico'), 'UIImageView')
		award[j].numTx = tolua.cast(award[j].awardPhotoIco:getChildByName('award_num_tx'), 'UILabel')
		award[j].nameTx = tolua.cast(award[j].awardPhotoIco:getChildByName('award_name_tx'), 'UILabel')
		award[j].nameTx:setPreferredSize(145,1)
	end
	local award_1 = UserData:getAward(PvpData.DayAwardData[i].Award1)
	local award_2 = UserData:getAward(PvpData.DayAwardData[i].Award2)
	local award_3 = UserData:getAward(PvpData.DayAwardData[i].Award3)
	awards = {award_1,award_2,award_3}
	local giftAwards = {PvpData.DayAwardData[i].Award1,PvpData.DayAwardData[i].Award2,PvpData.DayAwardData[i].Award3}
	for k=1,3 do
		award[k].awardPhotoIco:registerScriptTapHandler(function()
			UISvr:showTipsForAward(giftAwards[k])
		end)
		award[k].numTx:setText(toWordsNumber(tonumber(awards[k].count)))
		award[k].awardIco:setTexture(awards[k].icon)
		award[k].nameTx:setText(GetTextForCfg(awards[k].name))
	end
end

function PvpAwardPanel:createCells()
	RankSv:removeAllChildrenAndCleanUp(true)
	for i=1,#PvpData.RankAwardData do
		local rewardVView = createWidgetByName('panel/pvp_rank_award_1_cell.json')
		setRankAward(i,rewardVView)
		RankSv:addChildToBottom(rewardVView)
	end
	RankSv:scrollToTop()

	DaySv:removeAllChildrenAndCleanUp(true)
	for i=1,#PvpData.DayAwardData do
		local rewardVView = createWidgetByName('panel/pvp_day_award_1_cell.json')	
		setDayAward(i,rewardVView)
		DaySv:addChildToBottom(rewardVView)
	end
	DaySv:scrollToTop()
end

function PvpAwardPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('pvp_award_bg_img','pvp_award_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()
		RankBtn = tolua.cast(root:getChildByName('rank_award_btn') , 'UIButton')
		RankBtn:registerScriptTapHandler(onClickRankBtn)
		DayBtn = tolua.cast(root:getChildByName('day_award_btn') , 'UIButton')
		DayBtn:registerScriptTapHandler(onClickDayBtn)
		local awardTx1 = tolua.cast(RankBtn:getChildByName('award_tx') , 'UILabel')
		awardTx1:setPreferredSize(200,1)
		local awardTx2 = tolua.cast(DayBtn:getChildByName('award_tx') , 'UILabel')
		awardTx2:setPreferredSize(200,1)

		RankSv = tolua.cast(root:getChildByName('rank_sv') , 'UIScrollView')
		RankSv:setClippingEnable(true)
		RankSv:setTouchEnable(true)

		DaySv = tolua.cast(root:getChildByName('day_sv') , 'UIScrollView')
		DaySv:setClippingEnable(true)
		DaySv:setTouchEnable(true)

		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		onClickRankBtn()
		self:createCells()
	end)
end

function PvpAwardPanel:enter()
	self:init()
	return true
end
