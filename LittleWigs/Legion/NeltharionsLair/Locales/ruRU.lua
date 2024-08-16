﻿local L = BigWigs:NewBossLocale("Neltharions Lair Trash", "ruRU")
if not L then return end
if L then
	L.breaker = "Крушитель из племени Камня Силы"
	--L.hulk = "Vileshard Hulk"
	--L.gnasher = "Rockback Gnasher"
	--L.trapper = "Rockbound Trapper"
	L.emberhusk = "Emberhusk Dominator"
	L.vicious_manafang = "Ползун из чумных осколков"
end

L = BigWigs:NewBossLocale("Rokmora", "ruRU")
if L then
	L.warmup_text = "Рокмора активна"
	L.warmup_trigger = "Наваррогг?! Предатель, ты привел к нам чужаков?!"
	L.warmup_trigger_2 = "Меня устроят оба варианта! Рокмора, убей их!"
end

L = BigWigs:NewBossLocale("Ularogg Cragshaper", "ruRU")
if L then
	L.totems = "Тотемы"
	L.bellow = "{193375} (Тотемы)" -- Bellow of the Deeps (Totems)
end
