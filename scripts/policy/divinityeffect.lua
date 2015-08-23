
--
-- Initiated by eminem

local GEConf = {
	position 		= { CCPointMake(0,0),     CCPointMake(580,0) },
	bigPosition     = { CCPointMake(0,-30),	  CCPointMake(600,0) },
	textPosition	= { CCPointMake(450,20),  CCPointMake(130,20)},
	textOffset      = { CCPointMake(1200,0),  CCPointMake(-800,0)}
}

local function createSeq(...)
	local n = select('#',...)
	if 1 == n then 
		return ...
	end

	local ar = CCArray:create()
	for i=1,n do
		local v = select(i,...)
		ar:addObject(v)
	end
	return CCSequence:create(ar)
end

----[[
function setupDivinityContents(host, girlID, skillID, isHome)
	local sideIndex = 1
	if not isHome then
		sideIndex = 2
	end

	local JSONFile  = 'animation/effect/spines/export/skill.json'
	local ATLASFile = 'animation/effect/spines/export/skill.atlas'

	local node = CCSkeletonAnimation:createWithFile(JSONFile, ATLASFile)
	node:setAnimation('animation', false)
	host:addChild(node)
	node:setPosition(GEConf.position[sideIndex])

	local girlImage = getDivinityField(girlID, skillID, 'BeautySculpIcon')
	if girlImage then
		local image = CCSprite:create(girlImage)
		image:setOpacity(0)
		image:runAction( 
			createSeq(
				CCFadeTo:create(0.6, 255),
				CCDelayTime:create(0.3),	
				CCFadeTo:create(1.3, 0)
			)
		)
		image:setPosition(GEConf.bigPosition[sideIndex])
		image:runAction(CCMoveBy:create(1.3,ccp(0,130)))
		host:addChild(image)
	end

	local textPath = getDivinityField(girlID, skillID, 'SkillTextDescription')
	if textPath then
		local text = CCSprite:create(textPath)
		text:setScale(4)
		text:setOpacity(0)
		local a = 0.3
		local b = 0.3

		text:runAction(CCSpawn:createWithTwoActions(
			CCScaleTo:create(a,2,2),
			CCFadeTo:create(a, 255)))
		text:runAction(createSeq(CCDelayTime:create(1.0),
			CCSpawn:createWithTwoActions(CCMoveBy:create(b, GEConf.textOffset[sideIndex]), CCFadeTo:create(b,30))))
		text:setPosition(GEConf.textPosition[sideIndex])
		host:addChild(text)
	end

	host:runAction(createSeq(CCFadeTo:create(0.3,255),
		CCDelayTime:create(1.4),
		CCFadeTo:create(0.3,0))
		)

	--print('yes, you saw me ')
	return 3.6
end
--]]

--[[
function setupDivinityContents(host, girlID, skillID, isHome)
	local mid = 'right'
	if isHome then
		mid = 'left'
	end

	local JSONFile  = 'animation/effect/spines/export/'..mid..'/skill.json'
	local ATLASFile = 'animation/effect/spines/export/'..mid..'/skill.atlas'

	local node = CCSkeletonAnimation:createWithFile(JSONFile, ATLASFile)
	node:setAnimation('animation', false)
	--node:setSkin(string.format('%02d', getDivinityIndexOffset(girlID)))
	node:setSkin('01')
	host:addChild(node)
	node:setPosition(ccp(500,0))

	return 3.6
end
--]]


