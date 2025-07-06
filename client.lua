local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPeds, isKtpVisible = {}, false

local function HideKtpUI()
    if not isKtpVisible then return end
    SendNUIMessage({ type = 'hideKTP' })
    isKtpVisible = false
    ClearPedTasks(PlayerPedId()) 
end

RegisterNetEvent('ap_ktp:client:openKtpUseMenu', function()
    exports['qb-menu']:openMenu({
        {
            header = "Pilih Aksi",
            isMenuHeader = true,
        },
        {
            header = "Lihat KTP Sendiri",
            txt = "Hanya menampilkan KTP di layar Anda.",
            params = {
                event = "ap_ktp:client:executeShowKtp",
                args = { broadcast = false } 
            }
        },
        {
            header = "Tunjukkan ke Sekitar",
            txt = "Menawarkan KTP Anda ke pemain terdekat.",
            params = {
                event = "ap_ktp:client:executeShowKtp",
                args = { broadcast = true } 
            }
        },
        {
            header = "Tutup",
            txt = "",
            params = {
                event = "qb-menu:closeMenu",
            }
        }
    })
end)

RegisterNetEvent('ap_ktp:client:executeShowKtp', function(data)
    if isKtpVisible then return end
    
    local pData = QBCore.Functions.GetPlayerData()
    local ktpData = pData.metadata.ktpdata
    if not ktpData or not ktpData.nik then
        QBCore.Functions.Notify("Data KTP Anda tidak ditemukan. Silakan buat KTP melalui petugas.", "error")
        return
    end

    ktpData.pekerjaan = pData.job.label
    ktpData.telepon = pData.charinfo.phone

    local animDict = "paper_1_rcm_alt1-9"
    RequestAnimDict(animDict); while not HasAnimDictLoaded(animDict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, "player_one_dual-9", 8.0, 8.0, -1, 49, 0, false, false, false)

    SendNUIMessage({ type = 'showKTP', data = ktpData })
    isKtpVisible = true
    
    if data.broadcast then
        TriggerServerEvent('ap_ktp:server:showKtpToNearby')
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if isKtpVisible then
            DisableControlAction(0, 177, true) -- BACKSPACE
            if IsDisabledControlJustPressed(0, 177) then HideKtpUI() end
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('ap_ktp:client:receiveKtpOffer', function(ktpData)
    QBCore.Functions.Notify(ktpData.nama .. " menunjukkan KTP. Tekan [G] untuk melihat.", 'primary', 7500)
    local timeout = 7500
    CreateThread(function()
        while timeout > 0 do
            Wait(1); timeout = timeout - 1
            if IsControlJustPressed(0, 47) then
                if isKtpVisible then return end 
                SendNUIMessage({ type = 'showKTP', data = ktpData })
                isKtpVisible = true
                return 
            end
        end
    end)
end)

local function SpawnNPCs()
    for _, ped in ipairs(spawnedPeds) do DeleteEntity(ped) end; spawnedPeds = {}
    for _, location in ipairs(Config.Locations) do
        RequestModel(location.model); while not HasModelLoaded(location.model) do Wait(10) end
        local ped = CreatePed(4, location.model, location.coords.x, location.coords.y, location.coords.z - 1.0, location.coords.w, false, true)
        FreezeEntityPosition(ped, true); SetEntityInvincible(ped, true); SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, location.scenario, 0, true)
        table.insert(spawnedPeds, ped)
        
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = "client",
                    event = "ap_ktp:client:openMainMenu",
                    icon = "fas fa-id-card",
                    label = Config.InteractionLabel,
                    canInteract = function()
                        local pData = QBCore.Functions.GetPlayerData()
                        return pData.job and Config.AllowedJobs[pData.job.name]
                    end
                }
            },
            distance = 2.0
        })
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', SpawnNPCs)
AddEventHandler('onResourceStart', function(res) if GetCurrentResourceName() == res and QBCore.Functions.GetPlayerData().citizenid then SpawnNPCs() end end)
AddEventHandler('onResourceStop', function(res) if GetCurrentResourceName() == res then for _, ped in ipairs(spawnedPeds) do DeleteEntity(ped) end end end)
RegisterNetEvent('ap_ktp:client:openMainMenu', function()
    exports['qb-menu']:openMenu({
        { header = "Layanan Kependudukan", isMenuHeader = true },
        { header = "Buatkan KTP untuk Warga", txt = "Membuat KTP baru untuk warga.", params = { event = "ap_ktp:client:startBuatKtpUntukWarga" }},
        { header = "Perpanjang KTP Warga", txt = "Memperpanjang masa berlaku KTP warga.", params = { event = "ap_ktp:client:startPerpanjangKtp" }},
        { header = "Tutup", params = { event = "qb-menu:closeMenu" } }
    })
end)

RegisterNetEvent('ap_ktp:client:startBuatKtpUntukWarga', function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Buat KTP untuk Warga",
        submitText = "Buat KTP",
        inputs = {
            { text = "ID Server Warga", name = "targetid", type = "number", isRequired = true },
            { text = "URL Foto Warga", name = "fotourl", type = "text", isRequired = true },
            { text = "Tanggal Kedaluwarsa (Contoh: 2025-12-31)", name = "expires", type = "text", isRequired = true }
        }
    })
    if dialog and dialog.targetid and dialog.fotourl and dialog.expires then
        TriggerServerEvent('ap_ktp:server:buatKtpUntukWarga', tonumber(dialog.targetid), dialog.fotourl, dialog.expires)
    end
end)

RegisterNetEvent('ap_ktp:client:startPerpanjangKtp', function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Perpanjang KTP Warga",
        submitText = "Lanjut",
        inputs = {
            { text = "ID Server Warga", name = "targetid", type = "number", isRequired = true },
            {
                text = "Pilih Durasi Perpanjangan", name = "durasi", type = "select",
                options = {
                    { value = "1", text = "1 Bulan - $" .. Config.BiayaPerpanjangPerBulan * 1 },
                    { value = "2", text = "2 Bulan - $" .. Config.BiayaPerpanjangPerBulan * 2 },
                    { value = "3", text = "3 Bulan - $" .. Config.BiayaPerpanjangPerBulan * 3 },
                },
                isRequired = true
            }
        }
    })
    if dialog and dialog.targetid and dialog.durasi then
        TriggerServerEvent('ap_ktp:server:perpanjangKtpOlehPetugas', tonumber(dialog.targetid), dialog.durasi)
    end
end)

RegisterNetEvent('ap_ktp:client:updateKtpData', function(newKtpData)
    local pData = QBCore.Functions.GetPlayerData()
    pData.metadata.ktpdata = newKtpData
end)

