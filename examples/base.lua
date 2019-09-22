local sqlite = require 'sqlite3' ('sqlite3')
local SQLITE = sqlite.const

local code, db = sqlite.open(':memory:')
if code ~= SQLITE.OK then
  print('Error: ' .. db:errmsg())
  os.exit()
end


code = sqlite.exec(db, [[ CREATE TABLE People (
  id   INTEGER PRIMARY KEY,
  name TEXT,
  age  INTEGER
); ]])


do
  -- Create and use prepared statement
  -- Don't forget to finalize after using

  local some_data = {
    { name = 'Alex', age = 35 };
    { name = 'Eric', age = 27 };
    { name = 'Paul', age = 29 };
  }

  local code, stmt = sqlite.prepare_v2(db, [[
    INSERT INTO People (name, age) VALUES (?, ?);
  ]])

  for _, row in pairs(some_data) do
    sqlite.bind_text(stmt, 1, row.name)
    sqlite.bind_int(stmt, 2, row.age)
    sqlite.step(stmt)
    sqlite.reset(stmt)
  end

  sqlite.finalize(stmt)
end


do
  -- Using prepared statement in simplified way
  -- Statement prepared and finalized automatically

  local another_data = {
    { name = 'John',  age = 24 };
    { name = 'Steve', age = 32 };
    { name = 'Gary',  age = 26 };
  }

  code = sqlite.using_stmt(db, 'INSERT INTO People (name, age) VALUES (?, ?);', function (db, stmt)
    for _, row in pairs(another_data) do
      sqlite.bind_text(stmt, 1, row.name)
      sqlite.bind_int(stmt, 2, row.age)
      sqlite.step(stmt)
      sqlite.reset(stmt)
    end
  end)
end


do
  -- Retrieving results from query in loop
  -- Statement managed fully automatically

  print('All people: ')
  for stmt in sqlite.using_stmt_iter(db, 'SELECT id, name, age FROM People;') do
    print(sqlite.column_int(stmt, 0), sqlite.column_text(stmt, 1), sqlite.column_int(stmt, 2))
  end
end


do
  -- Retrieving results from query in callback
  -- Statement managed fully automatically
  -- Invokes callback for every result row

  print('Older than 27 years: ')
  sqlite.using_stmt_loop(db, 'SELECT name, age FROM People WHERE age > 27;', function (db, stmt)
    print(sqlite.column_text(stmt, 0), sqlite.column_int(stmt, 1))
  end)
end


do
  -- Retrieving results from manualy prepared statement in loop

  local code, stmt = sqlite.prepare_v2(db, [[
    SELECT name, age FROM People WHERE age < 27;
  ]])

  print('Younger than 27 years: ')
  for _ in sqlite.stmt_iter(stmt) do
    print(sqlite.column_text(stmt, 0), sqlite.column_int(stmt, 1))
  end

  stmt:finalize()
end


do
  -- Retrieving results from manualy prepared statement in callback
  -- Invokes callback for every result row

  local code, stmt = sqlite.prepare_v2(db, [[
    SELECT name, age FROM People WHERE age == 27;
  ]])

  print('Exact 27 years: ')
  sqlite.stmt_loop(stmt, function (stmt)
    print(sqlite.column_text(stmt, 0), sqlite.column_int(stmt, 1))
  end)

  stmt:finalize()
end


db:close()
