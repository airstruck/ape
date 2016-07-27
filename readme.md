
# APE

A Plugin Environment (for monkeypatching).

## Plugins

Ape plugins hook into a host app by *monkeypatching*. They can be enabled
and disabled at runtime, and can be sorted to suit user priority preferences.

To accomplish this, Ape plugins must release their claws from the host app
by *unmonkeypatching*.

All plugins must provide `enable` and `disable` methods. These methods
perform the patching and unpatching. Whatever "enable" does, "disable"
must revert. **Do not call these methods.**  Instead, use `ape:enable(self)`
or `ape:disable(self)`.

These methods should take two arguments, `self` and `host`. The "host"
is what the plugin will be patching.

```lua
-- plugin/example.lua

local ExamplePlugin = {}

ExamplePlugin:enable (host)
    -- monkeypatch host's draw function
    local draw = host.draw
    function host:draw()
        lg.setColor(0, 0, 255)
        draw(host)
    end
    self.oldDraw = draw
end

ExamplePlugin:disable (host)
    -- revert our monkeypatches
    host.draw = self.oldDraw
end

return ExamplePlugin
```

## Host App

It's easy to host plugins with Ape. Just require the module, call the
constructor and enable some plugins. Remember to pass the constructor
a reference to your host app.

```lua
local Ape = require 'ape'

function MyApp:init()
    self.ape = Ape(self)
    self.ape:enable('plugin.example')
end

function MyApp:draw()
    lg.print('hi')
end
```
    
## API

### Ape ({table} host)

The `Ape` constructor takes a `host` app
and returns an object with the following methods.

All methods will `require(plugin)`
if the `plugin` argument is a string,
and treat that module as the plugin object.
        
### ape:load ({string|table} plugin)

Load a plugin, but don't enable it.
If it was already loaded, do nothing.
Load order determines plugin priority.

### ape:unload ({string|table} plugin)

Disable and unload a plugin. It will take
lowest priority if loaded again.

### ape:enable ({string|table} plugin)

Enable a plugin, loading it first if needed.

### ape:disable ({string|table} plugin)

Disable a plugin, but don't unload it.
This preserves the plugin's priority order.

### ape:sort ({func} sort)
Sort loaded plugins to re-prioritize them.
