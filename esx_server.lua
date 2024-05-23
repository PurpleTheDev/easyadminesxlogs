ESX = nil
globalLicenses = {}
local discordWebhookURL = "https://discord.com/api/webhooks/1242993636770058261/uFn92M5HNwOMUQx0nXABkrEOqQLEhJjB4LNU5I7cd4jS0GPgapzCtYsem58E3TPaMKV8"

function SendWebhookMessage(webhookURL, title, description, color, fields)
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["fields"] = fields,
            ["footer"] = {
                ["text"] = "Purples ESX logs",
            },
        }
    }
    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({embeds = embed, username = "Purples ESX logs"}), { ['Content-Type'] = 'application/json' })
end

function getName(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer and xPlayer.getName() or "Unknown"
end

function logAction(source, playerId, action, details, color, amount)
    local fields = {
        { ["name"] = "Staff member:", ["value"] = "`"..getName(source).."`", ["inline"] = true },
        { ["name"] = "Player:", ["value"] = "`"..getName(playerId).."`", ["inline"] = true },
        { ["name"] = "Action:", ["value"] = "`"..details.."`", ["inline"] = false }
    }
    if amount then
        table.insert(fields, { ["name"] = "Amount:", ["value"] = "`"..tostring(amount).."`", ["inline"] = false })
    end
    SendWebhookMessage(discordWebhookURL, action, "", color, fields)
end

Citizen.CreateThread(function()
    function setESXObj(obj)
        ESX = obj
    end
    function setLicenses(licenses)
        globalLicenses = licenses
        collectgarbage()
    end

    repeat
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(10000)
        if not ESX then
            TriggerEvent('esx:getSharedObject', setESXObj)
        else
            TriggerEvent("esx_license:getLicensesList", setLicenses)
        end
    until ESX
end)

RegisterServerEvent("EasyAdmin:esx:addAccountMoney")
AddEventHandler("EasyAdmin:esx:addAccountMoney", function(playerId, account, accountMoney)
    if DoesPlayerHavePermission(source, "easyadmin.esx.money") and ESX then
        logAction(source, playerId, "Account Money Added", "gave $"..accountMoney.." "..account.." Money", 3066993, accountMoney)

        local xPlayer = ESX.GetPlayerFromId(playerId)
        if accountMoney < 0 then
            xPlayer.removeAccountMoney(account, -accountMoney)
        else
            xPlayer.addAccountMoney(account, accountMoney)
        end
    end
end)

RegisterServerEvent("EasyAdmin:esx:setAccountMoney")
AddEventHandler("EasyAdmin:esx:setAccountMoney", function(playerId, account, accountMoney)
    if DoesPlayerHavePermission(source, "easyadmin.esx.money") and ESX then
        logAction(source, playerId, "Account Money Set", "set account money to $"..accountMoney.." "..account.." Money", 15105570, accountMoney)

        local xPlayer = ESX.GetPlayerFromId(playerId)
        xPlayer.setAccountMoney(account, accountMoney)
    end
end)

RegisterServerEvent("EasyAdmin:esx:addMoney")
AddEventHandler("EasyAdmin:esx:addMoney", function(playerId, money)
    if DoesPlayerHavePermission(source, "easyadmin.esx.money") and ESX then
        logAction(source, playerId, "Money Added", "gave $"..money, 3066993, money)

        local xPlayer = ESX.GetPlayerFromId(playerId)
        if money < 0 then
            xPlayer.removeMoney(-money)
        else
            xPlayer.addMoney(money)
        end
    end
end)

RegisterServerEvent("EasyAdmin:esx:addInventoryItem")
AddEventHandler("EasyAdmin:esx:addInventoryItem", function(playerId, item, count)
    if DoesPlayerHavePermission(source, "easyadmin.esx.items") and ESX then
        logAction(source, playerId, "Inventory Item Added", "gave "..count.." "..item, 3066993, count)

        local xPlayer = ESX.GetPlayerFromId(playerId)
        if count < 0 then
            xPlayer.removeInventoryItem(item, -count)
        else
            xPlayer.addInventoryItem(item, count)
        end
    end
end)

RegisterServerEvent("EasyAdmin:esx:setInventoryItem")
AddEventHandler("EasyAdmin:esx:setInventoryItem", function(playerId, item, count)
    if DoesPlayerHavePermission(source, "easyadmin.esx.items") and ESX then
        logAction(source, playerId, "Inventory Item Set", "set inventory item to "..count.." "..item, 15105570, count)

        local xPlayer = ESX.GetPlayerFromId(playerId)
        xPlayer.setInventoryItem(item, count)
    end
end)

RegisterServerEvent("EasyAdmin:esx:SetJob")
AddEventHandler("EasyAdmin:esx:SetJob", function(playerId, job, grade)
    if DoesPlayerHavePermission(source, "easyadmin.esx.setjob") and ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        logAction(source, playerId, "Job Set", "set job to "..job, 15105570)

        xPlayer.setJob(job, tonumber(grade))
    end
end)

RegisterServerEvent("EasyAdmin:esx:ResetSkin")
AddEventHandler("EasyAdmin:esx:ResetSkin", function(playerId)
    if DoesPlayerHavePermission(source, "easyadmin.esx.resetskin") and ESX then
        TriggerClientEvent('esx_skin:openSaveableMenu', playerId)
        logAction(source, playerId, "Skin Reset", "reset the skin", 15158332)
        TriggerClientEvent("EasyAdmin:showNotification", source, getName(playerId).."'s skin menu has been opened.")
    end
end)

RegisterServerEvent("EasyAdmin:esx:toggleLicense")
AddEventHandler("EasyAdmin:esx:toggleLicense", function(playerId, license)
    if DoesPlayerHavePermission(source, "easyadmin.esx.license") and ESX then
        local found = false
        for i, l in pairs(globalLicenses) do
            if l.type == license then
                found = true
                TriggerEvent("esx_license:checkLicense", playerId, license, function(hasLicense)
                    if hasLicense then
                        TriggerEvent("esx_license:removeLicense", playerId, license)
                        logAction(source, playerId, "License Removed", "removed license **"..license.."**", 15158332)
                        TriggerClientEvent("EasyAdmin:showNotification", source, getName(playerId).."'s "..license.." has been removed ")
                    else
                        TriggerEvent("esx_license:addLicense", playerId, license)
                        logAction(source, playerId, "License Added", "added license **"..license.."**", 3066993)
                        TriggerClientEvent("EasyAdmin:showNotification", source, getName(playerId).." has been added the license "..license)
                    end
                end)
            end
        end
        Wait(3000)
        if not found then
            TriggerClientEvent("EasyAdmin:showNotification", source, "This License does not exist.")
        end
    end
end)

RegisterServerEvent("EasyAdmin:esx:HandcuffPlayer")
AddEventHandler("EasyAdmin:esx:HandcuffPlayer", function(playerId)
    if DoesPlayerHavePermission(source, "easyadmin.esx.cuff") and ESX then
        TriggerClientEvent("esx_policejob:handcuff", playerId)
        logAction(source, playerId, "Player Handcuffed", "handcuffed", 15158332)
    end
end)

RegisterServerEvent("EasyAdmin:esx:RevivePlayer")
AddEventHandler("EasyAdmin:esx:RevivePlayer", function(playerId)
    if DoesPlayerHavePermission(source, "easyadmin.esx.revive") and ESX then
        TriggerClientEvent("esx_ambulancejob:revive", playerId)
        logAction(source, playerId, "Player Revived", "revived", 3066993)
    end
end)
