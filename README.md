# Features

# Start using
Before calling sqlite functions you need to initialize binding with library name or path.
Luajit uses dynamic library loading API directly, so behaviour may be different on each OS.
Filename and location of sqlite library may also vary.
Several examples:
```lua
-- Windows
local sqlite = require 'sqlite3' ('sqlite3')
local sqlite = require 'sqlite3' ('../some/path/sqlite3.dll')
-- Linux
local sqlite = require 'sqlite3' ('./libsqlite3.so')
local sqlite = require 'sqlite3' ('/usr/local/lib/libsqlite3.so')
-- Mac OS X
local sqlite = require 'sqlite3' ('/opt/local/lib/libsqlite3.dylib')
```
For statically linked sqlite, just skip argument.
```lua
-- Any OS
local sqlite = require 'sqlite3' ()
```
Constants stored in const table. It is recommended to save it in variable with SQLITE name.
```lua
local SQLITE = sqlite.const
```

# Example code
```lua

```
