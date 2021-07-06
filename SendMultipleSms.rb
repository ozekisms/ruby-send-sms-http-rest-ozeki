require 'ozeki_libs_rest'

configuration = Configuration.new(
    "http_user",
    "qwe123",
    "http://127.0.0.1:9509/api"
);

msg1 = Message.new
msg1.to_address = "+36201111111"
msg1.text = "Hello world 1"

msg2 = Message.new
msg2.to_address = "+36202222222"
msg2.text = "Hello world 2"

msg3 = Message.new
msg3.to_address = "+36203333333"
msg3.text = "Hello world 3"

api = MessageApi.new(configuration)

result = api.send([ msg1, msg2, msg3 ])

print(result)

