local L = BigWigs:NewBossLocale("Court of Stars Trash", "zhTW")
if not L then return end
if L then
	L.Guard = "暮衛守衛"
	L.Construct = "守護者傀儡"
	L.Enforcer = "魔縛執行者"
	L.Hound = "燃燒軍團獵犬"
	--L.Mistress = "Shadow Mistress"
	L.Gerenth = "『鄙惡者』葛任斯"
	L.Jazshariu = "賈茲夏魯"
	L.Imacutya = "伊瑪庫緹雅"
	L.Baalgar = "『警戒者』包爾加"
	L.Inquisitor = "警戒的審判官"
	L.BlazingImp = "熾炎小鬼"
	L.Energy = "束縛能量"
	L.Manifestation = "秘法化身"
	L.Wyrm = "法力龍鰻"
	L.Arcanist = "暮衛祕法師"
	L.InfernalImp = "熾炎小鬼"
	L.Malrodi = "祕法化身"
	L.Velimar = "威利瑪"
	L.ArcaneKeys = "祕法鑰匙"
	L.clues = "線索"

	L.InfernalTome = "煉獄秘典"
	L.MagicalLantern = "魔法燈籠"
	L.NightshadeRefreshments = "夜影餐點"
	L.StarlightRoseBrew = "星輝玫瑰酒"
	L.UmbralBloom = "暗影之花"
	L.WaterloggedScroll = "浸水的卷軸"
	L.BazaarGoods = "市集商品"
	L.LifesizedNightborneStatue = "等身大小的夜裔雕像"
	L.DiscardedJunk = "拋棄的雜物"
	L.WoundedNightborneCivilian = "受傷的夜裔平民"
	L.FelOrb = "邪能宝珠"
	L.ArcanePowerConduit = "奥术能量导管"
	L.FlaskoftheSolemnNight = "庄严静夜合剂"

	L.announce_buff_items = "通告增益物品"
	L.announce_buff_items_desc = "通告此地城所有可用的增益物品，並通告誰可以使用。"

	L.available = "%s|cffffffff%s|r可用" -- Context: item is available to use
	L.usableBy = "使用者：%s" -- Context: item is usable by someone

	L.custom_on_use_buff_items = "立即使用增益物品"
	L.custom_on_use_buff_items_desc = "啟用此選項後，自動確認使用物品前的對話選項並使用物品，這不包含二王前使用會引來守衛的物品。"

	L.spy_helper = "間諜事件助手"
	L.spy_helper_desc = "在一個訊息視窗內顯示隊伍得到間諜的線索，並通告線索給其他隊員。"

	L.clueFound = "找到第%d/5條線索：|cffffffff%s|r"
	L.spyFound = "間諜被%s找到了！"
	L.spyFoundChat = "我找到間諜了，快來！"
	L.spyFoundPattern = "別太快下定論。" -- Now now, let's not be hasty [player]. Why don't you follow me so we can talk about this in a more private setting...

	L.hints = {
		"斗篷",
		"沒有斗蓬",
		"腰袋",
		"藥水瓶",
		"長袖",
		"短袖",
		"手套",
		"沒有手套",
		"男性",
		"女性",
		"淺色上衣",
		"深色上衣",
		"無藥水瓶",
		"書本",
	}

	--[[ !!! IMPORTANT NOTE TO TRANSLATORS !!! ]]--
	--[[ The following translations have to exactly match the gossip text of the Chatty Rumormongers. ]]--

	-- Cape
	L["聽說這個間諜很喜歡穿斗篷。"] = 1
	L["剛剛有人說，間諜稍早進來時還穿著斗篷。"] = 1

	-- No Cape
	L["我聽說間諜過來這裡之前把斗篷忘在皇宮了。"] = 2
	L["我剛聽說這個間諜討厭斗篷，所以絕對不穿斗篷。"] = 2

	-- Pouch
	L["我朋友說間諜喜歡黃金，所以腰帶上的隨身包裝滿黃金。"] = 3
	L["聽說間諜喜歡炫富，腰上的錢包裝滿金幣。"] = 3
	L["我聽說那位間諜總是帶著一個魔法小包。"] = 3
	L["我聽說那名間諜的腰帶上有個口袋，口袋的刺繡非常精緻。"] = 3

	-- Potions
	L["聽說那個間諜帶了藥水…以防萬一。"] = 4
	L["我非常肯定那個間諜在腰帶上繫了藥水。"] = 4
	L["聽說有間諜帶了藥水過來耶，不知道為什麼？"] = 4
	L["別說是我講的…那個間諜現在偽裝成鍊金師了，腰帶上繫著藥水瓶。"] = 4

	-- Long Sleeves
	L["我剛剛碰巧看到那個間諜今晚穿著長袖衣服。"] = 5
	L["聽說今晚那個間諜穿了長袖衣服。"] = 5
	L["剛剛有人說，間諜今晚為了能遮住手臂，才穿長袖的。"] = 5
	L["我朋友跟我說，那位間諜穿著長袖。"] = 5

	-- Short Sleeves
	L["聽說那個間諜喜歡今晚涼爽的天氣，所以不穿長袖。"] = 6
	L["我朋友剛剛告訴我，她看到了，間諜沒穿長袖。"] = 6
	L["有人說那個間諜討厭長袖衣服。"] = 6
	L["我剛聽說那個間諜今晚穿短袖，這樣動作比較靈活。"] = 6

	-- Gloves
	L["有傳聞說那個間諜一直戴著手套。"] = 7
	L["我聽說那個間諜總是戴著手套。"] = 7
	L["有人說那位間諜總是穿著手套，因為手上有明顯的疤痕。"] = 7
	L["聽說那個間諜習慣把手藏起來。"] = 7

	-- No Gloves
	L["有人說那個間諜從來不戴手套。"] = 8
	L["我聽到的是那個間諜根本不喜歡戴手套。"] = 8
	L["聽說那名間諜盡量不戴手套，因為總有需要動作靈活的時候。"] = 8
	L["你知道嗎…我剛在後房發現多的手套。那個間諜現在一定光著手。"] = 8

	-- Male
	L["剛剛有人說看到他和大博學者一起走進去。"] = 9
	L["我剛聽人家說間諜是男的。"] = 9
	L["我聽說間諜混進來了，而且長得很帥。"] = 9
	L["有個樂手說他一直在問關於這個地區的問題。"] = 9

	-- Female
	L["有人看到她和艾莉珊德一起走進來。"] = 10
	L["聽說有個女人一直在打探這個地區的事情…"] = 10
	L["有人說間諜是女的。"] = 10
	L["他們說間諜混進來了，而且她非常美貌。"] = 10

	-- Light Vest
	L["那位間諜特別喜歡淺顏色的外衣。"] = 11
	L["我剛聽說那個間諜今晚會穿著淺色的外衣。"] = 11
	L["人家說那個間諜今晚絕對不會穿深色外衣。"] = 11

	-- Dark Vest
	L["聽說今晚那個間諜的外衣顏色很深。"] = 12
	L["間諜喜歡顏色比較深的外衣…就像夜晚一樣。"] = 12
	L["有個說法是那位間諜為了混入人群，特別避免淺色的衣著。"] = 12
	L["間諜絕對比較喜歡深色衣服。"] = 12

	-- No Potions
	L["我聽說那個間諜什麼藥水都沒帶。"] = 13
	L["有個樂手告訴我，她看到間諜把最後一瓶藥水丟了，所以現在身上應該沒有藥水。"] = 13

	-- Book
	L["我聽說那個間諜在腰帶上掛著一本書，裡頭寫滿了各種秘密。"] = 14
	L["聽說那個間諜是喜歡讀書的人，不管到哪裡都會帶著一本書。"] = 14
end

L = BigWigs:NewBossLocale("Advisor Melandrus", "zhTW")
if L then
	--L.warmup_trigger = "Yet another failure, Melandrus. Consider this your chance to correct it. Dispose of these outsiders. I must return to the Nighthold."
end
