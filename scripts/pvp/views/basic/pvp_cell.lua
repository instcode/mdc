PvpCell = PvpPage:new{
}

-- 此方法由上层直接调用，作用是根据data刷新当前cell，按需重写
function PvpCell:update( data )
	if data then
		self.data = data
	end
end