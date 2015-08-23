LegionWarRoundResultCell = LegionCell:new{
	jsonFile = 'panel/legion_war_round_result_cell.json'
}


function LegionWarRoundResultCell:createCell()
	local cell = LegionWarRoundResultCell:new{data = datA}
	cell:create()
	return cell
end