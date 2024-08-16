local L = BigWigs:NewBossLocale("Cordana Felsong", "ruRU")
if not L then return end
if L then
	L.kick_combo = "Комбо удар"

	L.light_dropped = "%s выронил Свет."
	L.light_picked = "%s поднял Свет."

	L.warmup_text = "Кордана Оскверненная Песнь активна"
	L.warmup_trigger = "Я уже получила то, за чем пришла. Но осталась, чтобы покончить с вами… раз и навсегда!"
	L.warmup_trigger_2 = "И вы угодили в мою ловушку. Посмотрим, на что вы способны в темноте."
	L.warmup_trigger_3 = "Как предсказуемо! Я знала, что вы придете."
end

L = BigWigs:NewBossLocale("Glazer", "ruRU")
if L then
	--L.radiation_level = "%s: %d%%"
end

L = BigWigs:NewBossLocale("Tirathon Saltheril", "ruRU")
if L then
	L.warmup_trigger = "И я служу своему народу: изгнанным и отверженным."
	L.warmup_trigger2 = "Я пожертвовал телом и душой. Мой народ отверг меня."
end

L = BigWigs:NewBossLocale("Vault of the Wardens Trash", "ruRU")
if L then
	L.soulrender = "Терзательница душ Глевианна"
	L.infester = "Скверноподданный заразитель"
	L.myrmidon = "Скверноподданный мирмидон"
	L.fury = "Зараженный Скверной яростный боец"
	L.mother = "Темная мать"
	L.illianna = "Иллиана Танцующая с Клинками"
	L.mendacius = "Повелитель ужаса Мендаций"
	L.grimhorn = "Злобнорог Поработитель"
end
