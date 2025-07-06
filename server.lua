local QBCore = exports['qb-core']:GetCoreObject()
local PlayerCooldowns = {}


QBCore.Functions.CreateUseableItem('ktp', function(source, item)
    TriggerClientEvent('ap_ktp:client:openKtpUseMenu', source)
end)

RegisterNetEvent('ap_ktp:server:showKtpToNearby', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.metadata.ktpdata then return end

    local dataToShow = Player.PlayerData.metadata.ktpdata
    dataToShow.pekerjaan = Player.PlayerData.job.label
    dataToShow.telepon = Player.PlayerData.charinfo.phone

    for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
        if playerId ~= src and (#(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(playerId))) < 5.0) then
            TriggerClientEvent('ap_ktp:client:receiveKtpOffer', playerId, dataToShow)
        end
    end
end)

RegisterNetEvent('ap_ktp:server:buatKtpUntukWarga', function(targetId, fotoUrl, expiresDate)
    local src = source
    local Petugas = QBCore.Functions.GetPlayer(src)
    if not Petugas or not Config.AllowedJobs[Petugas.PlayerData.job.name] then return end
    
    local Warga = QBCore.Functions.GetPlayer(targetId)
    if not Warga then
        TriggerClientEvent('QBCore:Notify', src, "ID Warga tidak ditemukan.", "error")
        return
    end
    
    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(targetId))) > 5.0 then TriggerClientEvent('QBCore:Notify', src, "Warga terlalu jauh.", "error"); return end
    if not string.match(expiresDate, "%d%d%d%d%-%d%d%-%d%d") then TriggerClientEvent('QBCore:Notify', src, "Format tanggal salah. Gunakan YYYY-MM-DD.", "error"); return end

    if Warga.PlayerData.money.bank < Config.BiayaKTP then
        TriggerClientEvent('QBCore:Notify', src, "Warga tidak punya cukup uang di bank.", "error")
        TriggerClientEvent('QBCore:Notify', targetId, "Uang Anda di bank tidak cukup.", "error")
        return
    end

    Warga.Functions.RemoveMoney('bank', Config.BiayaKTP, 'pembuatan-ktp')
    
    local charinfo = Warga.PlayerData.charinfo
    local ktpData = {
        citizenid = Warga.PlayerData.citizenid, nik = Warga.PlayerData.citizenid,
        nama = ('%s %s'):format(charinfo.firstname, charinfo.lastname):upper(),
        ttl = ('LOS SANTOS, %s'):format(charinfo.birthdate), gender = (charinfo.gender == 0 and 'LAKI-LAKI' or 'PEREMPUAN'),
        fotourl = fotoUrl, birthdate = charinfo.birthdate,
        expires = expiresDate, nationality = charinfo.nationality or "WNI"
    }
    
    Warga.Functions.SetMetaData("ktpdata", ktpData)
    Warga.Functions.AddItem('ktp', 1, false)
    
    TriggerClientEvent('QBCore:Notify', src, "KTP untuk " .. ktpData.nama .. " berhasil dibuat.", "success")
    TriggerClientEvent('QBCore:Notify', targetId, "KTP Anda telah dibuat oleh petugas.", "success")
end)

RegisterNetEvent('ap_ktp:server:perpanjangKtpOlehPetugas', function(targetId, durasiBulan)
    local src = source
    local Petugas = QBCore.Functions.GetPlayer(src)
    if not Petugas or not Config.AllowedJobs[Petugas.PlayerData.job.name] then return end

    local Warga = QBCore.Functions.GetPlayer(targetId)
    if not Warga then TriggerClientEvent('QBCore:Notify', src, "ID Warga tidak ditemukan.", "error"); return end

    local oldKtpData = Warga.PlayerData.metadata.ktpdata
    if not oldKtpData then TriggerClientEvent('QBCore:Notify', src, "Warga ini tidak memiliki data KTP di sistem.", "error"); return end

    local durasiInt = tonumber(durasiBulan)
    local biaya = Config.BiayaPerpanjangPerBulan * durasiInt
    if Warga.PlayerData.money.bank < biaya then TriggerClientEvent('QBCore:Notify', src, "Warga tidak memiliki cukup uang di bank ($"..biaya..").", "error"); return end
    Warga.Functions.RemoveMoney('bank', biaya, 'perpanjang-ktp-oleh-petugas')
    
    local y, m, d = string.match(oldKtpData.expires, "(%d+)%-(%d+)%-(%d+)")
    y, m, d = tonumber(y), tonumber(m), tonumber(d)

    m = m + durasiInt
    while m > 12 do m = m - 12; y = y + 1 end
    local newDateStr = string.format("%04d-%02d-%02d", y, m, d)
    
    local newKtpData = {
        citizenid = oldKtpData.citizenid, nik = oldKtpData.nik, nama = oldKtpData.nama,
        ttl = oldKtpData.ttl, gender = oldKtpData.gender, fotourl = oldKtpData.fotourl,
        birthdate = oldKtpData.birthdate, expires = newDateStr, nationality = oldKtpData.nationality or "WNI"
    }
    
    Warga.Functions.SetMetaData("ktpdata", newKtpData)
    TriggerClientEvent('ap_ktp:client:updateKtpData', targetId, newKtpData)
    TriggerClientEvent('QBCore:Notify', src, "KTP untuk " .. Warga.PlayerData.charinfo.firstname .. " berhasil diperpanjang.", "success")
    TriggerClientEvent('QBCore:Notify', targetId, "KTP Anda telah diperpanjang oleh petugas.", "success")
end)

QBCore.Commands.Add('resetktp', 'Reset data KTP pemain.', {{name='id', help='ID Server pemain'}}, true, function(source, args)
    local targetId = tonumber(args[1])
    if not targetId then return end
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not TargetPlayer then return end
    TargetPlayer.Functions.SetMetaData("ktpdata", nil)
    TriggerClientEvent('QBCore:Notify', source, "Data KTP untuk ID "..targetId.." telah direset.", "success")
    TriggerClientEvent('QBCore:Notify', targetId, "Data KTP Anda telah direset oleh admin.", "primary")
end, 'admin')