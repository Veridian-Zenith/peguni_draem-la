#!/usr/bin/env lua

-- Virtual Pet Simulator with JSON Saving

math.randomseed(os.time())

-- ======================
-- Configuration Section
-- ======================

-- ANSI Color Codes
local KOLORS = {
    reset = "\27[0m",
    bold = "\27[1m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m",
    bright_red = "\27[91m",
    bright_green = "\27[92m",
    bright_yellow = "\27[93m",
    bright_blue = "\27[94m",
    bright_magenta = "\27[95m",
    bright_cyan = "\27[96m"
}

-- Supported Languages
local LANGS = {
    {
        code = "en",
        name = "English",
        native = "English",
        translations = {
            welcome = "🌟 Welcome to Peguni Draem'la!",
            name_prompt = "Your name: ",
            pet_name_prompt = "Your pet's name: ",
            pet_type_prompt = "Describe your pet (e.g. 'fluffy cat', 'playful dragon'): ",
            location_prompt = "Your home (e.g. 'city apartment', 'forest cabin'): ",
            load_prompt = "Load saved game? (y/n): ",
            action_prompt = "What would you like to do?",
            actions = { "Feed", "Play", "Walk", "Rest", "Groom", "Train", "Explore", "Quit" },
            status = "%s and %s | Day %d | %s",
            stats = "You: %s Energy | %s: %s Hunger, %s Happiness, %s Health",
            messages = {
                fed = "%s is eating happily!",
                played = "You played with %s!",
                walked = "You walked %s outside!",
                rested = "You both rested.",
                groomed = "You groomed %s. They look great!",
                trained = "%s learned something new!",
                explored = "You explored the %s with %s!",
                quit = "Goodbye! See you and your pet soon!",
                saved = "Game saved to pet_data.json!",
                error = "Invalid choice, please try again.",
                load_error = "No saved game found or save file is invalid.",
                continue = "(Press Enter to continue)"
            }
        }
    },
    {
        code = "de",
        name = "German",
        native = "Deutsch",
        translations = {
            welcome = "🌟 Willkommen beim Peguni Draem'la!",
            name_prompt = "Dein Name: ",
            pet_name_prompt = "Name deines Haustieres: ",
            pet_type_prompt = "Beschreibe dein Haustier (z.B. 'flauschige Katze'): ",
            location_prompt = "Dein Zuhause (z.B. 'Stadtwohnung'): ",
            load_prompt = "Gespeichertes Spiel laden? (j/n): ",
            action_prompt = "Was möchtest du tun?",
            actions = { "Füttern", "Spielen", "Gassi gehen", "Ausruhen", "Pflegen", "Trainieren", "Erkunden", "Beenden" },
            status = "%s und %s | Tag %d | %s",
            stats = "Du: %s Energie | %s: %s Hunger, %s Freude, %s Gesundheit",
            messages = {
                fed = "%s frisst glücklich!",
                played = "Du hast mit %s gespielt!",
                walked = "Du bist mit %s Gassi gegangen!",
                rested = "Ihr habt euch beide ausgeruht.",
                groomed = "Du hast %s gepflegt. Sieht super aus!",
                trained = "%s hat etwas Neues gelernt!",
                explored = "Du hast die %s mit %s erkundet!",
                quit = "Auf Wiedersehen!",
                saved = "Spiel in pet_data.json gespeichert!",
                error = "Ungültige Auswahl, bitte versuche es erneut.",
                load_error = "Kein gespeichertes Spiel gefunden oder Speicherdatei ist ungültig.",
                continue = "(Drücke Enter, um fortzufahren)"
            }
        }
    },
    {
        code = "ru",
        name = "Russian",
        native = "Русский",
        translations = {
            welcome = "🌟 Добро пожаловать в Peguni Draem'la!",
            name_prompt = "Ваше имя: ",
            pet_name_prompt = "Имя вашего питомца: ",
            pet_type_prompt = "Опишите питомца (напр. 'пушистый кот'): ",
            location_prompt = "Ваш дом (напр. 'городская квартира'): ",
            load_prompt = "Загрузить сохраненную игру? (д/н): ",
            action_prompt = "Что бы вы хотели сделать?",
            actions = { "Покормить", "Поиграть", "Погулять", "Отдохнуть", "Ухаживать", "Тренировать", "Исследовать", "Выйти" },
            status = "%s и %s | День %d | %s",
            stats = "Вы: %s Энергия | %s: %s Голод, %s Счастье, %s Здоровье",
            messages = {
                fed = "%s с удовольствием ест!",
                played = "Вы поиграли с %s!",
                walked = "Вы погуляли с %s на улице!",
                rested = "Вы оба отдохнули.",
                groomed = "Вы причесали %s. Он/она выглядит отлично!",
                trained = "%s научился чему-то новому!",
                explored = "Вы исследовали %s вместе с %s!",
                quit = "До свидания! Увидимся скоро!",
                saved = "Игра сохранена в pet_data.json!",
                error = "Неверный выбор, попробуйте еще раз.",
                load_error = "Сохраненная игра не найдена или файл поврежден.",
                continue = "(Нажмите Enter, чтобы продолжить)"
            }
        }
    },
    {
        code = "no",
        name = "Norwegian Bokmål",
        native = "Norsk bokmål",
        translations = {
            welcome = "🌟 Velkommen til Peguni Draem'la!",
            name_prompt = "Ditt navn: ",
            pet_name_prompt = "Kjæledyrets navn: ",
            pet_type_prompt = "Beskriv kjæledyret ditt (f.eks. 'fluffy katt'): ",
            location_prompt = "Ditt hjem (f.eks. 'leilighet i byen'): ",
            load_prompt = "Laste inn lagret spill? (j/n): ",
            action_prompt = "Hva vil du gjøre?",
            actions = { "Mate", "Leke", "Gå tur", "Hvile", "Stelle", "Trene", "Utforske", "Avslutte" },
            status = "%s og %s | Dag %d | %s",
            stats = "Du: %s Energi | %s: %s Sult, %s Glede, %s Helse",
            messages = {
                fed = "%s spiser med glede!",
                played = "Du lekte med %s!",
                walked = "Du gikk en tur med %s!",
                rested = "Dere hvilte begge to.",
                groomed = "Du stelte %s. Hen ser flott ut!",
                trained = "%s lærte noe nytt!",
                explored = "Du utforsket %s med %s!",
                quit = "Ha det bra! Vi ses snart!",
                saved = "Spillet er lagret til pet_data.json!",
                error = "Ugyldig valg, vennligst prøv igjen.",
                load_error = "Finner ingen lagret spillfil, eller filen er skadet.",
                continue = "(Trykk Enter for å fortsette)"
            }
        }
    },
    {
        code = "ko",
        name = "Korean",
        native = "한국어",
        translations = {
            welcome = "🌟 가상 펫 시뮬레이터에 오신 것을 환영합니다!",
            name_prompt = "당신의 이름: ",
            pet_name_prompt = "펫의 이름: ",
            pet_type_prompt = "펫을 설명해주세요 (예: '푹신한 고양이'): ",
            location_prompt = "당신의 집 (예: '도시 아파트'): ",
            load_prompt = "저장된 게임을 불러오시겠습니까? (예/아니오): ",
            action_prompt = "무엇을 하시겠습니까?",
            actions = { "먹이 주기", "놀아주기", "산책하기", "휴식하기", "몸단장", "훈련하기", "탐험하기", "종료하기" },
            status = "%s와(과) %s | %d일차 | %s",
            stats = "당신: 에너지 %s | %s: 배고픔 %s, 행복 %s, 건강 %s",
            messages = {
                fed = "%s이(가) 행복하게 먹고 있어요!",
                played = "%s와(과) 함께 놀았어요!",
                walked = "%s와(과) 함께 산책했어요!",
                rested = "둘 다 휴식을 취했습니다.",
                groomed = "%s의 몸단장을 해주었습니다. 아주 멋져요!",
                trained = "%s이(가) 새로운 것을 배웠어요!",
                explored = "%s와(과) 함께 %s을(를) 탐험했어요!",
                quit = "안녕히 가세요! 다음에 또 만나요!",
                saved = "게임이 pet_data.json에 저장되었습니다!",
                error = "잘못된 선택입니다. 다시 시도해주세요.",
                load_error = "저장된 게임을 찾을 수 없거나 파일이 손상되었습니다.",
                continue = "(계속하려면 Enter를 누르세요)"
            }
        }
    }
}

-- ======================
-- JSON Utility Functions
-- ======================

local function tabeli_tu_jsona(tabela, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    local json_parts = {}

    for k, v in pairs(tabela) do
        local key
        if type(k) == "string" then
            key = "\"" .. k .. "\""
        else
            key = tostring(k)
        end

        local value
        if type(v) == "table" then
            value = tabeli_tu_jsona(v, indent + 1)
        elseif type(v) == "string" then
            value = "\"" .. v:gsub("\"", "\\\""):gsub("\n", "\\n") .. "\""
        elseif type(v) == "boolean" then
            value = v and "true" or "false"
        else
            value = tostring(v)
        end
        table.insert(json_parts, spaces .. "  " .. key .. ": " .. value)
    end

    return "{\n" .. table.concat(json_parts, ",\n") .. "\n" .. spaces .. "}"
end

local function sava_tu_jsona(dataa, fayl_nema)
    local fayl, era = io.open(fayl_nema, "w")
    if not fayl then return false, era end

    local json_string = tabeli_tu_jsona(dataa)
    fayl:write(json_string)
    fayl:close()
    return true
end

local function loda_fro_jsona(fayl_nema)
    local fayl = io.open(fayl_nema, "r")
    if not fayl then return nil end

    local kontent = fayl:read("*a")
    fayl:close()

    local chunk, era = load("return " .. kontent)
    if not chunk then
        return nil
    end

    local success, dataa = pcall(chunk)
    if success then
        return dataa
    else
        return nil
    end
end

-- ======================
-- Draem Save/Load Functions
-- ======================

local function savaDraem(draem)
    local savaDataa = {
        peguni = draem.peguni,
        draem = draem.draem,
        environment = draem.environment,
        language = draem.language,
        timestamp = os.time()
    }
    return sava_tu_jsona(savaDataa, "pet_data.json")
end

local function lodaDraem()
    local dataa = loda_fro_jsona("pet_data.json")
    if not dataa then return nil end

    if not (dataa.peguni and dataa.draem and dataa.environment and dataa.language) then
        return nil
    end

    for _, lang in ipairs(LANGS) do
        if lang.code == dataa.language then
            return dataa, lang
        end
    end
    return dataa, nil
end

-- ======================
-- Draem Logic Functions
-- ======================

local function shoaLang()
    print(KOLORS.bright_yellow .. "Please select a language:" .. KOLORS.reset)
    for i, lang in ipairs(LANGS) do
        print(string.format("%d. %s (%s)", i, lang.name, lang.native))
    end

    local choisa
    while true do
        io.write(KOLORS.cyan .. "> " .. KOLORS.reset)
        choisa = tonumber(io.read())
        if choisa and choisa >= 1 and choisa <= #LANGS then
            return LANGS[choisa]
        else
            print(KOLORS.red .. "Invalid selection. Please try again." .. KOLORS.reset)
        end
    end
end

local function nevaDraem(lang)
    local T = lang.translations
    print(KOLORS.bright_green .. T.welcome .. KOLORS.reset)

    local function getInput(prompt)
        io.write(KOLORS.cyan .. prompt .. KOLORS.reset)
        return io.read()
    end

    local peguniNema = getInput(T.name_prompt)
    local draemNema = getInput(T.pet_name_prompt)
    local draemType = getInput(T.pet_type_prompt)
    local homeLokasion = getInput(T.location_prompt)

    return {
        peguni = { name = peguniNema, energy = 100 },
        draem = { name = draemNema, type = draemType, hunger = 50, happiness = 50, health = 100 },
        environment = { location = homeLokasion, day = 1 },
        language = lang.code
    }
end

local performa

local function klampa(val, min, max)
    return math.max(min, math.min(max, val))
end

local function draeim(draem, lang)
    local T = lang.translations
    local running = true

    while running do
        print("\n\n")

        print(KOLORS.bold .. KOLORS.bright_magenta .. string.rep("=", 60) .. KOLORS.reset)
        print(string.format(T.status, draem.peguni.name, draem.draem.name, draem.environment.day, draem.environment.location))
        print(string.format(T.stats, draem.peguni.energy, draem.draem.name, draem.draem.hunger, draem.draem.happiness, draem.draem.health))
        print(KOLORS.bold .. KOLORS.bright_magenta .. string.rep("=", 60) .. KOLORS.reset)

        print(KOLORS.yellow .. T.action_prompt .. KOLORS.reset)
        for i, aksion in ipairs(T.actions) do
            io.write(string.format("%s%d. %s%s  ", KOLORS.bright_cyan, i, aksion, KOLORS.reset))
        end
        print("\n")

        io.write(KOLORS.cyan .. "> " .. KOLORS.reset)
        local choisa = tonumber(io.read())

        if choisa and choisa >= 1 and choisa <= #T.actions then
            local aksionNema = T.actions[choisa]
            running = performa(aksionNema, draem, lang)

            draem.draem.hunger = klampa(draem.draem.hunger + 5, 0, 100)
            draem.draem.happiness = klampa(draem.draem.happiness - 2, 0, 100)
            draem.peguni.energy = klampa(draem.peguni.energy - 5, 0, 100)
        else
            print(KOLORS.red .. T.messages.error .. KOLORS.reset)
            print(KOLORS.white .. T.messages.continue .. KOLORS.reset)
            io.read()
        end
    end
end

performa = function(aksion, draem, lang)
    local T_msg = lang.translations.messages
    local T_akt = lang.translations.actions
    local pet = draem.draem

    if aksion == T_akt[1] then -- Feed
        print(string.format(T_msg.fed, pet.name))
        pet.hunger = klampa(pet.hunger - 30, 0, 100)
        pet.happiness = klampa(pet.happiness + 5, 0, 100)
    elseif aksion == T_akt[2] then -- Play
        print(string.format(T_msg.played, pet.name))
        pet.happiness = klampa(pet.happiness + 20, 0, 100)
        pet.hunger = klampa(pet.hunger + 10, 0, 100)
        draem.peguni.energy = klampa(draem.peguni.energy - 10, 0, 100)
    elseif aksion == T_akt[3] then -- Walk
        print(string.format(T_msg.walked, pet.name))
        pet.happiness = klampa(pet.happiness + 15, 0, 100)
        pet.health = klampa(pet.health + 5, 0, 100)
        draem.peguni.energy = klampa(draem.peguni.energy - 15, 0, 100)
    elseif aksion == T_akt[4] then -- Rest
        print(T_msg.rested)
        draem.peguni.energy = klampa(draem.peguni.energy + 40, 0, 100)
        pet.hunger = klampa(pet.hunger + 5, 0, 100)
    elseif aksion == T_akt[5] then -- Groom
        print(string.format(T_msg.groomed, pet.name))
        pet.health = klampa(pet.health + 15, 0, 100)
        pet.happiness = klampa(pet.happiness + 5, 0, 100)
    elseif aksion == T_akt[6] then -- Train
        print(string.format(T_msg.trained, pet.name))
        pet.happiness = klampa(pet.happiness + 10, 0, 100)
        draem.peguni.energy = klampa(draem.peguni.energy - 10, 0, 100)
    elseif aksion == T_akt[7] then -- Explore
        print(string.format(T_msg.explored, draem.environment.location, pet.name))
        pet.happiness = klampa(pet.happiness + 15, 0, 100)
        draem.peguni.energy = klampa(draem.peguni.energy - 20, 0, 100)
    elseif aksion == T_akt[8] then -- Quit
        if savaDraem(draem) then
            print(KOLORS.bright_green .. T_msg.saved .. KOLORS.reset)
        end
        print(KOLORS.bright_yellow .. T_msg.quit .. KOLORS.reset)
        return false
    end

    print(KOLORS.white .. T_msg.continue .. KOLORS.reset)
    io.read()
    return true
end

-- ======================
-- Main Program
-- ======================

local function maina()
    local selectedaLang = shoaLang()
    local savedDraem, savedLang = lodaDraem()

    if savedDraem and savedLang then
        io.write(KOLORS.bright_cyan .. savedLang.translations.load_prompt .. KOLORS.reset)
        local lodaChoisa = io.read():lower()
        -- This check covers "yes" in English, German/Norwegian, Russian, and Korean
        if lodaChoisa == "y" or lodaChoisa == "j" or lodaChoisa == "д" or lodaChoisa == "예" then
            draeim(savedDraem, savedLang)
            return
        end
    elseif savedDraem and not savedLang then
          print(KOLORS.yellow .. "Save file found, but its language is no longer supported. Starting new game." .. KOLORS.reset)
    else
        print(KOLORS.yellow .. selectedaLang.translations.messages.load_error .. KOLORS.reset)
    end

    local nevaDraemDataa = nevaDraem(selectedaLang)
    draeim(nevaDraemDataa, selectedaLang)
end

-- Start the draem
maina()
