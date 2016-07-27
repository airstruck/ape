-- APE: A Plugin Environment (for monkeypatching).

local function load (self, plugin)
    if type(plugin) == 'string' then
        plugin = require(plugin)
    end
    for i = 1, #self.plugins do
        if self.plugins[i] == plugin then
            return plugin
        end
    end
    self.plugins[#self.plugins + 1] = plugin
    plugin.pluginState = 'disabled'
    return plugin
end

local function unload (self, plugin)
    if type(plugin) == 'string' then
        plugin = require(plugin)
    end
    for i = #self.plugins, 1, -1 do
        local p = self.plugins[i]
        p:disable(self.context)
        if p == plugin then
            table.remove(self.plugins, i)
            p.pluginState = nil
        end
    end
    for i = 1, #self.plugins do
        local p = self.plugins[i]
        if p.pluginState == 'enabled' then
            p:enable(self.context)
        end
    end
end

local function refresh (self)
    for i = #self.plugins, 1, -1 do
        local p = self.plugins[i]
        if p.pluginState == 'enabled' then
            p:disable(self.context)
        elseif p.pluginState == 'disabling' then
            p:disable(self.context)
            p.pluginState = 'disabled'
        end
    end
    for i = 1, #self.plugins do
        local p = self.plugins[i]
        if p.pluginState == 'enabled' then
            p:enable(self.context)
        elseif p.pluginState == 'enabling' then
            p:enable(self.context)
            p.pluginState = 'enabled'
        end
    end
end

local function enable (self, plugin)
    plugin = self:load(plugin)
    if plugin.pluginState ~= 'enabled' then
        plugin.pluginState = 'enabling'
        self:refresh()
    end
end

local function disable (self, plugin)
    if type(plugin) == 'string' then
        plugin = require(plugin)
    end
    if plugin.pluginState ~= 'disabled' then
        plugin.pluginState = 'disabling'
        self:refresh()
    end
end

local function sort (self, sort)
    for i = #self.plugins, 1, -1 do
        local p = self.plugins[i]
        p:disable(self.context)
    end
    table.sort(self.plugins, sort)
    for i = 1, #self.plugins do
        local p = self.plugins[i]
        if p.pluginState == 'enabled' then
            p:enable(self.context)
        end
    end
end

return function (context)
    return {
        -- Public methods.
        load = load,
        unload = unload,
        enable = enable,
        disable = disable,
        sort = sort,
        
        -- Don't monkey around with these!
        plugins = {},
        context = context,
        refresh = refresh,
    }
end
