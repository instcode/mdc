
-- 只import在主城界面显示的panel

require 'ceremony/mcplugin/currencyframe'
require 'ceremony/mcplugin/leftbottomframe'
require 'ceremony/mcplugin/playerinfoframe'
require 'ceremony/mcplugin/tanhao'
require 'ceremony/panel/first_pay_award'
require 'ceremony/panel/bulletin_board'
require 'ceremony/panel/buyfood_panel'
require 'ceremony/panel/buygold_panel'
require 'ceremony/panel/cashpanel'
require 'ceremony/panel/activityhallpanel'
require 'ceremony/panel/give_god'
require 'ceremony/panel/setting'
require 'ceremony/panel/strong'
require 'ceremony/panel/news'
require 'ceremony/panel/beautiesz'
require 'ceremony/panel/beautiesi'
require 'ceremony/panel/achievement'
require 'ceremony/panel/activity'
require 'ceremony/panel/gifts_panel'
require 'ceremony/panel/chip_panel'
require 'ceremony/panel/rechargeandpay'

--This one is fixed point for C++
function installPlugIns(host, name, sideBarVisible)
	createCurrencyFrame(host, name, sideBarVisible)
	print('installation for McPlugIns done.')
end

function installLeftBottom(host , name , ispackup)
	createLeftBottomFrame(host , name , ispackup)
	print('installation for leftBottom done.')
end

function installPlayerInfo(host , name , sideBarVisible, showSdk)
	createPlayerInfoFrame(host , name , sideBarVisible, showSdk)
	print('installation for playerInfo done.')
end
--
print('installer loaded')