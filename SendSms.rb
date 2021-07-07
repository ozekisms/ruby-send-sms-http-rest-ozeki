require 'ozeki_libs_rest'

configuration = Configuration.new(
    "http_user",
    "qwe123",
    "http://127.0.0.1:9509/api"
);

msg = Message.new
msg.to_address = "+36201111111"
msg.text = "Hello world!"

api = MessageApi.new(configuration)

result = api.send(msg)

print(result)

