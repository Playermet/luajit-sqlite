local sqlite = require 'sqlite3' ('sqlite3')
local SQLITE = sqlite.const

local code, db = sqlite.open(':memory:')
if code ~= SQLITE.OK then
  print('Error: ' .. db:errmsg())
  os.exit()
end


code = db:exec [[ CREATE TABLE People (
  id   INTEGER PRIMARY KEY,
  name TEXT,
  age  INTEGER
); ]]


do
  -- Create and use prepared statement
  -- Don't forget to finalize after using

  local some_data = {
    { name = 'Alex', age = 35 };
    { name = 'Eric', age = 27 };
    { name = 'Paul', age = 29 };
  }

  local code, stmt = db:prepare_v2 [[
    INSERT INTO People (name, age) VALUES (?, ?);
  ]]

  for _, row in pairs(some_data) do
    stmt:bind_text(1, row.name)
    stmt:bind_int(2, row.age)
    stmt:step()
    stmt:reset()
  end

  stmt:finalize()
end


do
  -- Using prepared statement in simplified way
  -- Statement prepared and finalized automatically

  local another_data = {
    { name = 'John',  age = 24 };
    { name = 'Steve', age = 32 };
    { name = 'Gary',  age = 26 };
  }

  code = db:using_stmt('INSERT INTO People (name, age) VALUES (?, ?);', function (db, stmt)
    for _, row in pairs(another_data) do
      stmt:bind_text(1, row.name)
      stmt:bind_int(2, row.age)
      stmt:step()
      stmt:reset()
    end
  end)
end


do
  -- Retrieving results from query in loop
  -- Statement managed fully automatically

  print('All people: ')
  for stmt in db:using_stmt_iter 'SELECT id, name, age FROM People;' do
    print(stmt:column_int(0), stmt:column_text(1), stmt:column_int(2))
  end
end


do
  -- Retrieving results from query in callback
  -- Statement managed fully automatically
  -- Invokes callback for every result row

  print('Older than 27 years: ')
  db:using_stmt_loop('SELECT name, age FROM People WHERE age > 27;', function (db, stmt)
    print(stmt:column_text(0), stmt:column_int(1))
  end)
end


do
  -- Retrieving results from manualy prepared statement in loop

  local code, stmt = db:prepare_v2 [[
    SELECT name, age FROM People WHERE age < 27;
  ]]

  print('Younger than 27 years: ')
  for _ in stmt:iter() do
    print(stmt:column_text(0), stmt:column_int(1))
  end

  stmt:finalize()
end


do
  -- Retrieving results from manualy prepared statement in callback
  -- Invokes callback for every result row

  local code, stmt = db:prepare_v2 [[
    SELECT name, age FROM People WHERE age == 27;
  ]]

  print('Exact 27 years: ')
  stmt:loop(function (stmt)
    print(stmt:column_text(0), stmt:column_int(1))
  end)

  stmt:finalize()
end


db:close()
