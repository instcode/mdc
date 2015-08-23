-- 军团数据结
MyLegion = {
	lid = 0,		-- 军团id
	applicant_id = {},	-- 申请公会的id
	leave_time = 0,		-- 离开公会的日期

	name = '',		-- 军团名称
	notice = '',	-- 军团公告
	icon = 0,		-- 军团徽章id
	join_type = 0,	-- 军团加入类型：0任何人，1需要申请
	level_limit = 0,	-- 限制等级
	managers = {},	-- 管理员职位列表
	members = {},			-- 成员列表
	applicant_list = {},	-- 申请列表
	rank_list = {},	-- 军团排行列表
	level = 0,		-- 军团等级
	point = 0,		-- 军团积分 == 军团经验
	order = 0,		-- 军团令
	position = '',   -- 我的职务
	techs = nil,	-- 科技
	buff = {}		-- 头衔 , 到期时间
}

function initLegionID(jsonData)
	local data = json.decode(jsonData)
	if data.id then
		MyLegion.lid = data.id
	end
	if data.tech then
		MyLegion:updateTechs(data.tech)
	end
end

function getLegionID()
	return MyLegion.lid
end


-- 军团个人头衔buff(皇帝，将军，丞相)
function initLegionBuff(jsonData)
	if jsonData then
		local data = json.decode(jsonData)
		if data.title and data.time then
			local tab = {}
			tab['buff'] = data.title or ''
			tab['time'] = tonumber(data.time) or 0
			MyLegion.buff = tab
		end
	else
		MyLegion.buff = {}
	end
end

function getLegionTechEffectForAttr(attrtype )
	if MyLegion.techs == nil or MyLegion.lid == nil or MyLegion.lid < 1 then
		return 0
	end
	local number =0
	if tostring(attrtype) == 'attack' then
		number =1
	elseif tostring(attrtype) == 'defence' then
		number =2
	elseif tostring(attrtype) == 'mdefence' then
		number =3
	elseif tostring(attrtype) == 'health' then
		number =4
	end
	 if tonumber(number) <1 or tonumber(number) >7 then
	 	return 0
	 end
	local techid = tonumber(number) or 0
	local key = tonumber(MyLegion.techs[techid])
	local data = {}
	local tech = GameData:getArrayData('legiontech.dat')
	table.foreach(tech, function ( _, v )
		if techid == tonumber(v.Id) and key == tonumber(v.Level) then
			data = v
		end
	end)
	local attr =data.Param
	--cclog("--------------------------attr====" .. attr)
	return tonumber(attr)
end

function getLegionBuffForAttr( attrtype )
	if MyLegion.buff and MyLegion.buff.title and MyLegion.buff.time then
		local st = UserData:getServerTime()
		if st > MyLegion.buff.time or MyLegion.buff.title == '' then		-- buff过期或者头衔为空
			return 0
		end

		local conf = GameData:getMapData( 'legionwarbuff.dat' )[MyLegion.buff.title]
		if conf == nil then
			return 0
		end

		local map = {
			attack = 'Attack',
			defence = 'Defence',
			mdefence = 'Mdefence',
			health = 'Health'
		}

		local key = map[attrtype]
		if key == nil then
			return 0
		end

		if conf[key] then
			cclog('leigonBuff = ' .. key .. ' , percent = ' .. conf[key])
			return tonumber(conf[key])
		else
			return 0
		end
	else
		return 0
	end
end

function MyLegion:updateBase(data)
	MyLegion.lid = data.lid
	MyLegion.applicant_id = data.applicant_id
	MyLegion.leave_time = data.leave_time
end

function MyLegion:update( data )
	-- update basic data
	if data == nil then
		return
	end

	ModelHelper.updateKeyIfChanged(self, 'lid', data.lid)
	ModelHelper.updateKeyIfChanged(self, 'name', data.name)
	ModelHelper.updateKeyIfChanged(self, 'notice', data.notice)
	ModelHelper.updateKeyIfChanged(self, 'icon', data.icon)
	ModelHelper.updateKeyIfChanged(self, 'join_type', data.type)
	ModelHelper.updateKeyIfChanged(self, 'level_limit', data.level_limit)
	ModelHelper.updateKeyIfChanged(self, 'level', data.level)
	ModelHelper.updateKeyIfChanged(self, 'point', data.point)
	ModelHelper.updateKeyIfChanged(self, 'order', data.order)

	-- update tables.
	self:updateMembers(data.members)
	self:updateManagers(data.managers)
	self:updateApplicants(data.applicant_list)
	self:updateTechs(data.tech)
end

function MyLegion:updateMember(uid, date)
	for k, v in pairs(self.members) do
		if tonumber(uid) == tonumber(v.id) then
			ModelHelper.updateKeyIfChanged(v, 'donate_date', date.donate_date)
			ModelHelper.updateKeyIfChanged(v, 'donate_count', date.donate_count)
			ModelHelper.updateKeyIfChanged(v, 'honor', date.honor)
			ModelHelper.updateKeyIfChanged(v, 'order', date.order)
			ModelHelper.updateKeyIfChanged(v, 'pray_count', date.pray_count)
			ModelHelper.updateKeyIfChanged(v, 'pray_date', date.pray_date)
			ModelHelper.updateKeyIfChanged(v, 'position', date.position)
			break
		end
	end
end

function MyLegion:updateMembers( members )
	if not members then
		return
	end
	self.members = {}

	table.foreach(members, function ( mid, data )
		local member = {
			id = tonumber(mid),
			honor = data.honor,
			level = data.level,
			name = data.name,
			fight_force = data.fight_force,
			fight = data.fight,
			position = 'member',
			kill = data.kill or 0,
			last_login = data.last_login,
			donate_count = data.donate_count or 0,
			donate_date = data.donate_date or 0,
			pray_count  = data.pray_count or 0,
			pray_date = data.pray_date or 0,
		}

		table.insert(self.members, member)
	end)

	self.position = 'member'
end

function MyLegion:updateTechs( techs )
	if not techs then
		return
	end
	self.techs = {}
	for i = 1, LegionConfig:getTechDataMaxID() do
		self.techs[i] = 0
	end
	table.foreach(techs, function ( id, level )
		self.techs[tonumber(id)] = level
	end)
end

function MyLegion:getTechEffectByID(id)
	
	local count =0
	local sid =tonumber(id)
	if sid >0 and sid <= tonumber(LegionConfig:getTechDataMaxID()) then
		local techdata =LegionConfig:getTechDataByKeyandLv(id,self.techs[sid])
		count =techdata.Param
	end
	return tonumber(count)
end
-- 添加成员
function MyLegion:insertMembers( member )
	table.insert(self.members, member)
end
-- 删除成员
function MyLegion:removeMember(uid)
	for k, v in pairs(self.members) do
		if tonumber(uid) == tonumber(v.id) then
			table.remove(self.members, k)
			break
		end
	end
end

function MyLegion:updateApplicants( applicants )
	if not applicants then
		return
	end
	self.applicant_list = {}
	
	table.foreach(applicants, function ( uid, data )
		local applicant = {
			id = tonumber(uid),
			fightForce = data.fight_force,
			level = data.level,
			name = data.name
		}
		table.insert(self.applicant_list, applicant)
	end)
end

function MyLegion:removeApplicantByUID( uid )
	table.foreach(self.applicant_list, function ( i, v )
		if v.id == uid then
			self.applicant_list[i] = nil
			return
		end
	end)
end

function MyLegion:updateRankList(ranklist)
	if not ranklist then
		return
	end
	self.rank_list = {}
	for k, v in pairs(ranklist) do
		local info = {
			rank = tonumber(k),
			icon = tonumber(v.icon),
			level = tonumber(v.level),
			members_count = tonumber(v.members_count),
			name = tostring(v.name),
			point = v.point
		}
		table.insert(self.rank_list, info)
	end
end

function MyLegion:updateManagers( managers )
	if not managers then
		return
	end

	table.foreach(managers, function ( mid, data )
		local uid = tonumber(mid)
		local myId = PlayerCoreData.getUID()

		for i, member in pairs(self.members) do
			if member.id == uid then
				member.position = data

				if member.id == myId then
					self.position = data
				end
				
				break
			end
		end
	end)
end

-- 获取我的数据
function MyLegion:getMyData()
	if self.members then
		for _, v in pairs(self.members) do
			if v.id == PlayerCoreData.getUID() then
				return v
			end
		end
	end

	return nil
end

-- 军团长禅让
function MyLegion:changeCommander(uid)
	local count = 0
	for k, v in pairs(self.members) do
		if tonumber(v.id) == tonumber(PlayerCoreData.getUID()) then
			v.position = 'member'
			count = count + 1
		end
		if tonumber(uid) == tonumber(v.id) then
			v.position = 'commander'
			count = count + 1
		end
		if count == 2 then
			break
		end
	end
	self.position = 'member'
end

-- 判断当天可捐献
function MyLegion:isCanDonateToday()
	local donateDate = tostring(self:getMyData()['donate_date'])

	if donateDate == '0' then
		return true
	end

	local time1 = UserData:convertTime(2 , donateDate)
	local time2 = Time.beginningOfToday()

	if time1 < time2 then
		return true
	elseif time1 == time2 then
		local techAddTimes = MyLegion:getTechEffectByID(7)
		local maxTimes = LegionConfig:getValueForKey('InitialGoldContributeTime') + techAddTimes
		local donateTimes = tonumber(self:getMyData()['donate_count'])
		return donateTimes < maxTimes
	end
	return false
end

-- 判断当天可祈福
function MyLegion:isCanPrayToday()
	local prayDate = tostring(self:getMyData()['pray_date'])

	if prayDate == '0' then
		return true
	end

	local time1 = UserData:convertTime(2 , prayDate)
	local time2 = Time.beginningOfToday()

	if time1 < time2 then
		return true
	elseif time1 == time2 then
		local maxTimes = LegionConfig:getValueForKey('PrayTime')
		local prayTimes = tonumber(self:getMyData()['pray_count'])
		return prayTimes < maxTimes
	end
	return false
end

-- 军团徽章
function MyLegion:getLegionBadge()
	return 'uires/ui_2nd/com/panel/legion/' .. self.icon .. '_jun.png'
end
-- 贡献图标
function MyLegion:getHonorIcon()
	return 'uires/ui_2nd/com/panel/army_war/gong_ico.png'
end

-- 贡献图标(带底)
function MyLegion:getHonorImg()
	return 'uires/ui_2nd/com/panel/army_war/gong_img.png'
end

