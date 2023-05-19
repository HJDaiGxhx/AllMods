---@diagnostic disable: lowercase-global, deprecated, undefined-global

local Package = Class(function(self, inst)
    self.inst = inst
    self.content = nil

    self.onpack = nil
    self.onunpack = nil
end)

--------------------------------------------------------------------------

function Package:SetOnPackFn(fn)
    self.onpack = fn
end

function Package:SetOnUnpackFn(fn)
    self.onunpack = fn
end

--------------------------------------------------------------------------

function Package:Pack(entity)
    if entity ~= nil and entity:HasTag("packable") ~= nil then
        entity.Transform:SetPosition(0, -100, 0) -- hide entity away

        self.content = entity

        if self.onpack ~= nil then
            self.onpack(self.inst, entity)
        end
    end
end

function Package:UnPack(pt)
    -- print(self.inst.content_guid)
    -- print(Ents[self.inst.content_guid])
    -- self.content = self.content or self.inst.content_guid and Ents[self.inst.content_guid]
    if self.content then
        print("self.content")
        self.content.Transform:SetPosition(pt:Get()) -- teleport entity back
        SpawnPrefab("die_fx").Transform:SetPosition(pt:Get())
        return true
    else
        return false
    end
end

--------------------------------------------------------------------------

function Package:OnSave()
    print("OnSave")
    print(self.content and self.content.GUID or nil)
    return { content = self.content ~= nil and self.content.GUID or nil, },
        { self.content ~= nil and self.content.GUID or nil, }
end

function Package:LoadPostPass(newents, savedata)
    print("LoadPostPass")
    if savedata.content ~= nil then
        print("savedata.content")
        local content = newents[savedata.content]
        if content ~= nil then
            self.content = content.entity
            print("self.content", self.content)
        end
    end
end

return Package
