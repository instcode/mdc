
LegionController = {}

function LegionController.entrance()
	LegionConfig:load()
	LegionWarConfig:load()

	-- 入口
	local openLv = tonumber(GameData:getGlobalValue('LegionOpenLevel'))
	local playerLv = PlayerCoreData.getPlayerLevel()

	if openLv > playerLv then
		local msg = string.format(LegionConfig:getLegionLocalText('LEGION_OPEN_LEVEL_NOT_REACHED'), openLv)
		GameController.showMessageBox(msg, MESSAGE_BOX_TYPE.OK)
		return
	end

	-- Fix bug 666: 不知道哪个界面把scrollview给禁用了，fuck
	UIScrollView:setScrollViewEnabled(true)

	print('MyLegion.lid: ' .. MyLegion.lid)
	LegionController.sendLegionGetRequest(function ( res )
		if MyLegion.lid > 0 then
			LegionController.show(LegionMainPanel, ELF_SHOW.SLIDE_IN)
		else
			LegionController.sendLegionSearchRequest('', function ( res )
				if tonumber(res.code) == 0 then
					LegionController.show(LegionCreateRootPanel, ELF_SHOW.SLIDE_IN)
					LegionJoinPage:setSearchResult(res.data)
				end
			end)
		end
	end)
end


function LegionController.show( view, style )
	style = style or ELF_SHOW.NORMAL
	CUIManager:GetInstance():ShowObject(view:create(), style)
end

function LegionController.close( view, style )
	local objScene = view:getScene()
	if objScene == nil then
		return
	end

	style = style or ELF_HIDE.HIDE_NORMAL
	CUIManager:GetInstance():HideObject(objScene, style)
	view:release()
end

-- Network Communications --
local function updateLegionData( data )
	if data.legion ~= nil then
		MyLegion:update(data.legion)
	else
		MyLegion.lid = 0
		MyLegion.leave_time = tonumber(data.leave_time) or 0
		MyLegion.applicant_id = data.applicant_id or {}
	end

	if data.progress then
		LegionWar.progress = data.progress
	end

	if data.legion_war then
		MyLegion.buff = data.legion_war
	else
		MyLegion.buff = {}
	end
end


--[[ 创建军团，参数：
	name: '',	// 军团名
	notice: '',	// 军团公告
	icon: 0,	// 徽章ID
	ltype: 0,	// 加入类型
	limit: 0	// 限制等级
]]
function LegionController.sendLegionCreateRequest( name, notice, icon, ltype, limit, callback )
	if name == nil or name == '' then
		cclog('--- Legion name needed!!! ---')
		return
	end

	args = {
		name = name,
		notice = notice or '',
		icon = icon or 0,
		type = ltype or 0,
		level_limit = limit or 1
	}

	Message.sendPost('create', 'legion', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			updateLegionData(res.data)
			if callback then callback(res) end
		end
	end)
end

--[[ 搜索军团，参数：
	name: '', 	// 军团名称
	page: 1, 	// 页数
]]
function LegionController.sendLegionSearchRequest( name, callback )
	args = {
		name = name or '',
	}

	Message.sendPost('search', 'legion', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			if callback then callback(res) end
		end	
	end)
end

--[[ 加入军团，参数：
	lid: 0	// 军团id
]]
function LegionController.sendLegionJoinRequest( lid, callback )
	args = { lid = lid }

	Message.sendPost('join', 'legion', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			MyLegion.applicant_id = res.data.applicant_id
			if res.data.legion ~= nil then
				MyLegion:update(res.data.legion)
			end
			if callback then callback(res) end
		end
	end)
end

--[[ 取消加入军团申请，参数：
	applicant_list: 0	// 申请对象id
]]
function LegionController.sendLegionCancelJoinRequest( lid, callback )
	args = { lid = lid }
	Message.sendPost('revoke_request', 'legion', json.encode(args), function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			MyLegion.applicant_id = res.data.applicant_id
			if callback then callback(json.decode(response)) end
		end
	end)
end

--[[同意加入军团，参数：
	uid: 0 	// 玩家id
]]
function LegionController.sendLegionApproveJoinRequest( uid, callback )
	args = { uid = uid }

	Message.sendPost('approve', 'legion', json.encode(args), function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			MyLegion:removeApplicantByUID(uid)
			local member = res.data.member
			local tab = {
				id = uid,
				honor = member.honor,
				level = member.level,
				name = member.name,
				fight_force = member.fight_force or 0,
				fight = member.fight or 0,
				position = 'member',
				kill = member.kill or 0,
				last_login = member.last_login,
				donate_count = member.donate_count or 0,
				donate_date = member.donate_date or 0,
				pray_count = member.pray_count or 0,
				pray_date = member.pray_date or 0
			}
			MyLegion:insertMembers( tab )

			if callback then callback(res) end
		end
	end)
end

--[[拒绝加入军团，参数：
	uid: 0	// 玩家id
]]
function LegionController.sendLegionRejectJoinRequest( uid, callback )
	args = { uid = uid }

	Message.sendPost('reject', 'legion', json.encode(args), function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			MyLegion:removeApplicantByUID(uid)
			if callback then callback(res) end
		end
	end)
end

--[[ 更新军团，拉取军团数据
]]
function LegionController.sendLegionGetRequest( callback )
	Message.sendPost('get', 'legion', '{}', function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			updateLegionData(res.data)
			if callback then callback(res) end
		end
	end)
end

--[[ 获取军团的申请列表
]]
function LegionController.sendLegionApplicantListRequest( callback )
	Message.sendPost('applicant_list', 'legion', '{}', function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			MyLegion:updateApplicants(res.data.applicant_list)
			if callback then callback(res) end
		end
	end)
end

--[[ 获取军团排行的列表
]]
function LegionController.sendLegionRankListRequest( callback )
	Message.sendPost('rank', 'legion', '{}', function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			MyLegion:updateRankList(res.data.legions)
			if callback then callback(res) end
		end
	end)
end

--[[ 退出军团 
]]
function LegionController.sendLegionQuitRequest( callback )
	Message.sendPost('dismiss', 'legion', '{}', function ( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			if callback then callback(res) end
		end
	end)
end

--[[ 踢人: 参数
	uid: 玩家id
]]
function LegionController.sendLegionKickRequest( uid, callback )
	args = { uid = uid }

	Message.sendPost('kick', 'legion', json.encode(args), function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			MyLegion:update(res.data)
			MyLegion:removeMember(uid)
			if callback then callback(json.decode(response)) end
		end
	end)
end

--[[ 设置职位: 参数
	uid: 玩家id
	position:职位
]]
function LegionController.sendLegionChangePosition(uid, position, callback)
	args = { 
		uid = uid,
		position = position
	}

	Message.sendPost('position', 'legion', json.encode(args), function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			local data = { position = position }
			MyLegion:updateMember(uid, data)
			if callback then callback(res) end
		end
	end)
end

--[[ 设置军团，参数：
	notice: '',	// 军团公告
	icon: 0,	// 徽章ID
	ltype: 0,	// 加入类型
	limit: 0	// 限制等级
]]
function LegionController.sendLegionSettingRequest( notice, icon, ltype, limit, callback )
	args = {
		notice = notice or '',
		icon = icon or 0,
		type = ltype or 0,
		level_limit = limit or 1
	}

	Message.sendPost('setting', 'legion', json.encode(args), function( response )
		cclog( response )
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			-- updateLegionData(res.data)
			MyLegion.notice = args.notice
			MyLegion.icon = args.icon
			MyLegion.join_type = args.type
			MyLegion.level_limit = args.level_limit
			if callback then callback(res) end
		end
	end)
end

--[[ 商城购买: 参数
	id: 读取shopexchange.dat
	count: 数量
]]
function LegionController.sendLegionShopExchangeRequset( mid , mcount , callback )
	args = {id = mid , count = mcount}

	Message.sendPost('buy' , 'legion' , json.encode(args) , function ( response )
		cclog( response )
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			-- updateLegionData(res.data)
			local data = res.data
			local awards = data.awards
			if awards then
				UserData.parseAwardJson( json.encode(awards) )

				GameController.showAwardsFlowText( awards )

				--MyLegion:updateMyMemberData( data )
				MyLegion:updateMember(PlayerCoreData.getUID(), data)
			end
			if callback then callback(res) end
		end
	end)
end

--[[ 捐献: 参数
	id: 材料id
	count: 数量
	type: 类型
]]
function LegionController.sendLegionDonateRequset( mid , mtype , mcount , callback )
	
	if mtype == 'gold' then
		args = {
			gold = 1
		}
	elseif mtype == 'material' then
		args = {
			material = {id = mid , count = mcount}
		}
	else
		print('donate type error ... ')
		return
	end

	Message.sendPost('donate' , 'legion' , json.encode(args) , function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			-- updateLegionData(res.data)
			local data = res.data

			if data.awards then
				UserData.parseAwardJson( json.encode(data.awards) )
			end
			if data.gold then
				PlayerCoreData.addGoldDelta( tonumber(data.gold) )

				local time = Time.beginningOfToday()
				local tab = os.date('*t' , time)
				local y = tostring(tab.year)
				local m = string.format('%02d' , tab.month)
				local d = string.format('%02d' , tab.day)

				data['donate_date'] = y .. m .. d
			end
			
			ModelHelper.updateKeyIfChanged(MyLegion, 'order', data.order)

			MyLegion:updateMember(PlayerCoreData.getUID(), data)
			if callback then callback(res) end
		end
	end)
end

function LegionController.sendLegionTechUpgradeRequset( tid , callback )
	args = { tech_id = tid }

	Message.sendPost('tech_upgrade' , 'legion' , json.encode(args) , function ( response )
		cclog( response )
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			-- updateLegionData(res.data)
			local id = tonumber(tid)
			MyLegion.techs[id] =MyLegion.techs[id] + 1
			MyLegion.order =res.data.order
			if callback then callback(res) end
		end
	end)
end

--[[ 禅让公会: 参数
	uid: 0 	// 玩家id
]]
function LegionController.sendLegionTransferRequest( uid, callback )
	args = { uid = uid }

	Message.sendPost('transfer', 'legion', json.encode(args), function ( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			MyLegion:changeCommander(uid)
			if callback then callback(res) end
		end
	end)
end

--[[ 祈福
]]
function LegionController.sendLegionPrayRequest( callback )
	Message.sendPost('pray', 'legion', '{}', function ( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			local data = res.data
			local awards = data.awards
			if awards then
				UserData.parseAwardJson( json.encode(awards) )
				MyLegion:updateMember(PlayerCoreData.getUID(), data)
				if callback then callback(res) end
			end
		end
	end)
end
