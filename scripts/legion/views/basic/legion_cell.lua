LegionCell = LegionPage:new{
}

-- 此方法由上层直接调用，作用是根据data刷新当前cell，按需重写
function LegionCell:update( data )
	if data then
		self.data = data
	end
end