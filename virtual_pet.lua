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

-- File where save data is stored
local SAVE_FILE = "pet_data.json"

-- Order of actions for menus and logic
local ACTION_ORDER = { "feed", "play", "walk", "rest", "groom", "train", "explore", "quit" }

-- Stat change constants (encapsulate gameplay numbers)
local DELTA = {
    hunger_per_turn = 5,
    happiness_loss_per_turn = 2,
    energy_loss_per_turn = 5,

    feed = {hunger = -30, happiness = 5},
    play = {hunger = 10, happiness = 20, energy = -10},
    walk = {health = 5, happiness = 15, energy = -15},
    rest = {energy = 40, hunger = 5},
    groom = {health = 15, happiness = 5},
    train = {happiness = 10, energy = -10},
    explore = {happiness = 15, energy = -20},
}

-- Some sample Vaesktöng phrases (phrase / pronunciation / meaning)
local VAESKTONG_PHRASES = {
    {phrase = "Und I vaelta?", pron = "und ee vay-tah?", meaning = "Where did it go?"},
    {phrase = "Das verger rog.", pron = "das ver-geh roch", meaning = "Now it’s gone."},
    {phrase = "Peguni vet stör?", pron = "peh-goo-nee veht shtur?", meaning = "Did you notice?"},
    {phrase = "Noka draem tu noth?", pron = "no-kah draym too noth", meaning = "Has the silence gone or been replaced?"},
}

local function maybe_show_conlang()
    if math.random() < 0.25 then -- 25% chance each turn
        local item = VAESKTONG_PHRASES[math.random(#VAESKTONG_PHRASES)]
        print(KOLORS.bright_yellow .. item.phrase .. "   (" .. item.meaning .. ")" .. KOLORS.reset)
    end
end

-- Supported Languages
local LANGS = {
    {
        code = "va",
        name = "Vaesktöng (conlang)",
        native = "Vaesktöng",
        translations = {
            welcome = "🌟 Peguni Draem'la!",
            name_prompt = "Und I vaelta? ",
            pet_name_prompt = "Peguni draem nime? ",
            pet_type_prompt = "Fyar draem (e.g. 'fluffy cat'): ",
            location_prompt = "Und I lok? ",
            load_prompt = "Loda draem? (y/n): ",
            action_prompt = "Varela? ",
            actions = {
                feed = "Feed",
                play = "Play",
                walk = "Walk",
                rest = "Rest",
                groom = "Groom",
                train = "Train",
                explore = "Explore",
                quit = "Quit"
            },
            status = "%s und %s | Day %d | %s",
            stats = "You: %s Energy | %s: %s Hunger, %s Happiness, %s Health",
            messages = {
                feed = "Das verger rog.",
                play = "Peguni vet stör?",
                walk = "Noka draem tu noth?",
                rest = "Das verger rog.",
                groom = "Peguni vet stör?",
                train = "Peguni vet stör?",
                explore = "Und I vaelta?",
                quit = "Goodbye!",
                saved = "Game saved to %s!",
                error = "Invalid choice, please try again.",
                load_error = "No saved game found or save file is invalid.",
                continue = "(Press Enter to continue)"
            }
        }
    },
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
            actions = {
                feed = "Feed",
                play = "Play",
                walk = "Walk",
                rest = "Rest",
                groom = "Groom",
                train = "Train",
                explore = "Explore",
                quit = "Quit"
            },
            status = "%s and %s | Day %d | %s",
            stats = "You: %s Energy | %s: %s Hunger, %s Happiness, %s Health",
            messages = {
                feed = "%s is eating happily!",
                play = "You played with %s!",
                walk = "You walked %s outside!",
                rest = "You both rested.",
                groom = "You groomed %s. They look great!",
                train = "%s learned something new!",
                explore = "You explored the %s with %s!",
                quit = "Goodbye! See you and your pet soon!",
                saved = "Game saved to %s!",
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
            actions = {
                feed = "Füttern",
                play = "Spielen",
                walk = "Gassi gehen",
                rest = "Ausruhen",
                groom = "Pflegen",
                train = "Trainieren",
                explore = "Erkunden",
                quit = "Beenden"
            },
            status = "%s und %s | Tag %d | %s",
            stats = "Du: %s Energie | %s: %s Hunger, %s Freude, %s Gesundheit",
            messages = {
                feed = "%s frisst glücklich!",
                play = "Du hast mit %s gespielt!",
                walk = "Du bist mit %s Gassi gegangen!",
                rest = "Ihr habt euch beide ausgeruht.",
                groom = "Du hast %s gepflegt. Sieht super aus!",
                train = "%s hat etwas Neues gelernt!",
                explore = "Du hast die %s mit %s erkundet!",
                quit = "Auf Wiedersehen!",
                saved = "Spiel in %s gespeichert!",
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
            actions = {
                feed = "Покормить",
                play = "Поиграть",
                walk = "Погулять",
                rest = "Отдохнуть",
                groom = "Ухаживать",
                train = "Тренировать",
                explore = "Исследовать",
                quit = "Выйти"
            },
            status = "%s и %s | День %d | %s",
            stats = "Вы: %s Энергия | %s: %s Голод, %s Счастье, %s Здоровье",
            messages = {
                feed = "%s с удовольствием ест!",
                play = "Вы поиграли с %s!",
                walk = "Вы погуляли с %s на улице!",
                rest = "Вы оба отдохнули.",
                groom = "Вы причесали %s. Он/она выглядит отлично!",
                train = "%s научился чему-то новому!",
                explore = "Вы исследовали %s вместе с %s!",
                quit = "До свидания! Увидимся скоро!",
                saved = "Игра сохранена в %s!",
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
            actions = {
                feed = "Mate",
                play = "Leke",
                walk = "Gå tur",
                rest = "Hvile",
                groom = "Stelle",
                train = "Trene",
                explore = "Utforske",
                quit = "Avslutte"
            },
            status = "%s og %s | Dag %d | %s",
            stats = "Du: %s Energi | %s: %s Sult, %s Glede, %s Helse",
            messages = {
                feed = "%s spiser med glede!",
                play = "Du lekte med %s!",
                walk = "Du gikk en tur med %s!",
                rest = "Dere hvilte begge to.",
                groom = "Du stelte %s. Hen ser flott ut!",
                train = "%s lærte noe nytt!",
                explore = "Du utforsket %s med %s!",
                quit = "Ha det bra! Vi ses snart!",
                saved = "Spillet er lagret til %s!",
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
            actions = {
                feed = "먹이 주기",
                play = "놀아주기",
                walk = "산책하기",
                rest = "휴식하기",
                groom = "몸단장",
                train = "훈련하기",
                explore = "탐험하기",
                quit = "종료하기"
            },
            status = "%s와(과) %s | %d일차 | %s",
            stats = "당신: 에너지 %s | %s: 배고픔 %s, 행복 %s, 건강 %s",
            messages = {
                feed = "%s이(가) 행복하게 먹고 있어요!",
                play = "%s와(과) 함께 놀았어요!",
                walk = "%s와(과) 함께 산책했어요!",
                rest = "둘 다 휴식을 취했습니다.",
                groom = "%s의 몸단장을 해주었습니다. 아주 멋져요!",
                train = "%s이(가) 새로운 것을 배웠어요!",
                explore = "%s와(과) 함께 %s을(를) 탐험했어요!",
                quit = "안녕히 가세요! 다음에 또 만나요!",
                saved = "게임이 %s에 저장되었습니다!",
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

    -- avoid running any globals by giving an empty environment
    local env = {}
    local chunk, era = load("return " .. kontent, "@"..fayl_nema, "t", env)
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
    return sava_tu_jsona(savaDataa, SAVE_FILE)
end

local function lodaDraem()
    local dataa = loda_fro_jsona(SAVE_FILE)
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

local function read_nonempty(prompt)
    local input
    repeat
        io.write(KOLORS.cyan .. prompt .. KOLORS.reset)
        input = io.read()
    until input and input:match("%S")
    return input
end

local function nevaDraem(lang)
    local T = lang.translations
    print(KOLORS.bright_green .. T.welcome .. KOLORS.reset)

    local peguniNema = read_nonempty(T.name_prompt)
    local draemNema = read_nonempty(T.pet_name_prompt)
    local draemType = read_nonempty(T.pet_type_prompt)
    local homeLokasion = read_nonempty(T.location_prompt)

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
        for i, key in ipairs(ACTION_ORDER) do
            io.write(string.format("%s%d. %s%s  ", KOLORS.bright_cyan, i, T.actions[key], KOLORS.reset))
        end
        print("\n")

        -- some conlang flavor at the start of each turn
        maybe_show_conlang()

        io.write(KOLORS.cyan .. "> " .. KOLORS.reset)
        local choisa = tonumber(io.read())

        if choisa and choisa >= 1 and choisa <= #ACTION_ORDER then
            local actionKey = ACTION_ORDER[choisa]
            running = performa(actionKey, draem, lang)

            draem.draem.hunger = klampa(draem.draem.hunger + DELTA.hunger_per_turn, 0, 100)
            draem.draem.happiness = klampa(draem.draem.happiness - DELTA.happiness_loss_per_turn, 0, 100)
            draem.peguni.energy = klampa(draem.peguni.energy - DELTA.energy_loss_per_turn, 0, 100)
        else
            print(KOLORS.red .. T.messages.error .. KOLORS.reset)
            print(KOLORS.white .. T.messages.continue .. KOLORS.reset)
            io.read()
        end
    end
end

performa = function(action, draem, lang)
    local T_msg = lang.translations.messages
    local pet = draem.draem

    if action == "feed" then
        print(string.format(T_msg.feed, pet.name))
        pet.hunger = klampa(pet.hunger + DELTA.feed.hunger, 0, 100)
        pet.happiness = klampa(pet.happiness + DELTA.feed.happiness, 0, 100)
    elseif action == "play" then
        print(string.format(T_msg.play, pet.name))
        pet.happiness = klampa(pet.happiness + DELTA.play.happiness, 0, 100)
        pet.hunger = klampa(pet.hunger + DELTA.play.hunger, 0, 100)
        draem.peguni.energy = klampa(draem.peguni.energy + DELTA.play.energy, 0, 100)
    elseif action == "walk" then
        print(string.format(T_msg.walk, pet.name))
        pet.happiness = klampa(pet.happiness + DELTA.walk.happiness, 0, 100)
        pet.health = klampa(pet.health + DELTA.walk.health, 0, 100)
        draem.peguni.energy = klampa(draem.peguni.energy + DELTA.walk.energy, 0, 100)
    elseif action == "rest" then
        print(T_msg.rest)
        draem.peguni.energy = klampa(draem.peguni.energy + DELTA.rest.energy, 0, 100)
        pet.hunger = klampa(pet.hunger + DELTA.rest.hunger, 0, 100)
    elseif action == "groom" then
        print(string.format(T_msg.groom, pet.name))
        pet.health = klampa(pet.health + DELTA.groom.health, 0, 100)
        pet.happiness = klampa(pet.happiness + DELTA.groom.happiness, 0, 100)
    elseif action == "train" then
        print(string.format(T_msg.train, pet.name))
        pet.happiness = klampa(pet.happiness + DELTA.train.happiness, 0, 100)
        draem.peguni.energy = klampa(draem.peguni.energy + DELTA.train.energy, 0, 100)
    elseif action == "explore" then
        print(string.format(T_msg.explore, draem.environment.location, pet.name))
        pet.happiness = klampa(pet.happiness + DELTA.explore.happiness, 0, 100)
        draem.peguni.energy = klampa(draem.peguni.energy + DELTA.explore.energy, 0, 100)
    elseif action == "quit" then
        if savaDraem(draem) then
            print(KOLORS.bright_green .. string.format(T_msg.saved, SAVE_FILE) .. KOLORS.reset)
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
        local yes = { y=true, j=true, ["д"]=true, ["예"]=true }
        if yes[lodaChoisa] then
            draeim(savedDraem, savedLang)
            return
        end
    elseif savedDraem and not savedLang then
          print(KOLORS.yellow .. "Save file ("..SAVE_FILE..") found, but its language is no longer supported. Starting new game." .. KOLORS.reset)
    else
        print(KOLORS.yellow .. selectedaLang.translations.messages.load_error .. KOLORS.reset)
    end

    local nevaDraemDataa = nevaDraem(selectedaLang)
    draeim(nevaDraemDataa, selectedaLang)
end

-- Start the draem
maina()
