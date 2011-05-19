DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3:db/data.db")
DataMapper.auto_upgrade!
