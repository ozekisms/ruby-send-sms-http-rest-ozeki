require 'ozeki_libs_rest'

configuration = Configuration.new(
    "http_user",
    "qwe123",
    "http://127.0.0.1:9509/api"
);

msg = Message.new
msg.id = "f53efb1a-8ff6-4e62-97c3-2c1e81964b9d"

api = MessageApi.new(configuration)

result = api.delete(Folder.new.inbox, msg)

print(result)