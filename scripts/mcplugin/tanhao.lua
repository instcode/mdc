
local strongTanImg = nil
local openGiftsImg = nil
local signImg = nil
function setStrongVisible(b)
	if strongTanImg then
		strongTanImg:setVisible(b)
	end
end

function setStrongImg(img)
	if not strongTanImg then
		strongTanImg = img
		return true
	end
	return false
end

function setOpenGiftsVisible(b)
	if openGiftsImg then
		openGiftsImg:setVisible(b)
	end
end

function setOpenGiftsImg(img)
	if not openGiftsImg then
		openGiftsImg = img
		return true
	end
	return false
end

function setSignVisible(b)
	if signImg then
		signImg:setVisible(b)
	end
end

function setSignImg(img)
	if not signImg then
		signImg = img
		return true
	end
	return false
end