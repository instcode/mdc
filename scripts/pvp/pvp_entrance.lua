function pvpEntrance()
	require_modules('ceremony.pvp.pvp_dep')
	PvpData:loadConf()
	PvpController:getPvpInfo(function(res)
		if res.data.progress == PROGRESS.RANK or res.data.progress == PROGRESS.OVER then
			PvpMainPanel:enter(res)
		-- elseif res.data.progress == PROGRESS.OVER then
		else
			PvpKnockoutPanel:enter(res)
		end
	end)
end