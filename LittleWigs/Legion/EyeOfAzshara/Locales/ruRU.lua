local L = BigWigs:NewBossLocale("Eye of Azshara Trash", "ruRU")
if not L then return end
if L then
	L.gritslime = "Песчаная Улитка"
	L.wrangler = "Ловчий из клана Колец Ненависти"
	L.stormweaver = "Заклинательница штормов из клана Колец Ненависти"
	L.crusher = "Мирмидон из клана Колец Ненависти"
	L.oracle = "Оракул из клана Колец Ненависти"
	L.siltwalker = "Ходульник Мак'раны"
	L.tides = "Неутомимая волна"
	L.arcanist = "Колдунья из клана Колец Ненависти"
end

L = BigWigs:NewBossLocale("Lady Hatecoil", "ruRU")
if L then
	L.custom_on_show_helper_messages = "Вспомогательные сообщения для Кольцо молний и Средоточие молний"
	L.custom_on_show_helper_messages_desc = "Включите эту опцию, чтобы добавить вспомогательное сообщение, сообщающее вам, безопасна ли вода или земля, когда босс начнет каст |cff71d5ffКольцо молний|r или |cff71d5ffСредоточие молний|r."

	L.water_safe = "%s (вода безопасна)"
	L.land_safe = "%s (земля безопасна)"
end
