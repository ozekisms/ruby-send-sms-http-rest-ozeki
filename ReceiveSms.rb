require 'ozeki_libs_rest'

configuration = Configuration.new(
    "http_user",
    "qwe123",
    "http://127.0.0.1:9509/api"
);

api = MessageApi.new(configuration)

result = api.download_incoming()

print(result, "\n")
result.messages.each do |message|
    print(message, "\n")
end
