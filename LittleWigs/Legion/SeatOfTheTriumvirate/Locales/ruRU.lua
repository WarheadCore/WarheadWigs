﻿local L = BigWigs:NewBossLocale("Viceroy Nezhar", "ruRU")
if not L then return end
if L then
	--L.tentacles = "Tentacles"
	--L.guards = "Guards"
	--L.interrupted = "%s interrupted %s (%.1fs left)!"
end

L = BigWigs:NewBossLocale("L'ura", "ruRU")
if L then
	L.warmup_text = "Л'ура активна"
	L.warmup_trigger = "Такой хаос" --"Такой хаос... такая боль. Я еще не чувствовала ничего подобного."
	L.warmup_trigger_2 = "Она должна умереть" --"Впрочем, неважно. Она должна умереть."
	L.warmup_trigger_3 = "Осторожно"
	L.warmup_trigger_4 = "Берегись"
end

L = BigWigs:NewBossLocale("Zuraal", "ruRU")
if L then
	L.custom_on_autotalk = "Авторазговор"
	L.custom_on_autotalk_desc = "Мгновенный выбор опции запуска боя в диалоге."
	L.gossip_available = "Доступный диалог"
	L.alleria_gossip_trigger = "За мной!" -- Allerias yell after the first boss is defeated
	L.warmup_text_2 = "Аллерия активна"
	L.warmup_trigger_5 = "За мной!"

	L.alleria = "Аллерия Ветрокрылая"
end

L = BigWigs:NewBossLocale("Seat of the Triumvirate Trash", "ruRU")
if L then
	L.custom_on_autotalk = "Авторазговор"
	L.custom_on_autotalk_desc = "Мгновенный выбор опции запуска боя в диалоге."
	L.gossip_available = "Доступный диалог"
	L.alleria_gossip_trigger = "За мной!" -- Allerias yell after the first boss is defeated
	L.warmup_text_2 = "Аллерия активна"
	L.warmup_trigger_5 = "За мной!"
	L.warmup_trigger_6 = "Из храма исходит великое отчаяние. Л'ура..."

	L.alleria = "Аллерия Ветрокрылая"
	--L.subjugator = "Shadowguard Subjugator"
	--L.voidbender = "Shadowguard Voidbender"
	--L.conjurer = "Shadowguard Conjurer"
	--L.weaver = "Grand Shadow-Weaver"
end
