

--Fuck local off, this is global
BeautyEvents = {}

local function genOnEmbattleResponse(btn0, btn1, id, prompt, error)
	return function(response)
		local resp = json.decode(response)
		if resp.code == 0 then
			btn0:setVisible(false)		--Exclusive
			btn1:setVisible(true)
			setDivinityState(id, 1)
			GameController.showPrompts(getLocalStringValue(prompt))
		else
			print('error setting embattle divinity')
			print('retcode is ' ..tostring(resp.code))
			GameController.showPrompts(error)
		end
	end
end

function BeautyEvents.genOnClickEmbattle(targetID, btn, reclaimBtn, cb)
	return function()
		print('embattle ' .. tostring(targetID) .. ' !')
		local onResp = genOnEmbattleResponse(btn, reclaimBtn, targetID
			,'E_STR_DIVINITY_EMBATTLING_DONE','Embattle error')
		print('site 100')
		Message.sendPost('set_girl', 'battle', json.encode(
			{skill = 1, id = targetID}),
			function(resp)
				onResp(resp)
				if type(cb) == 'function' then
					cb()
				end
			end
		)
	end
end

function BeautyEvents.genOnClickReclaim(btn, battleBtn, cb)
	return function()
		print('on-click reclaim for anyone')
		local onResp = genOnEmbattleResponse(btn, battleBtn, -1
			, 'E_STR_DIVINITY_RECALL_DONE','Reclaim error')
		print('site 100A')
		Message.sendPost('set_girl', 'battle', json.encode({skill=1, id=-1}),
			function(resp)
				onResp(resp)
				if type(cb) == 'function' then
					cb()
				end
			end
		)
	end
end