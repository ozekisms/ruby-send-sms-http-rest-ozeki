# OzekiLibsRest

The ozeki_libs_rest gem is a tool for Ozeki SMS Gateway. With this library you can send, delete, mark and receive SMS messages using the built in api of the SMS Gateway.

To use the example code called SendSms.rb you have to set up an http_user in your SMS Gateway.

It is also important to mention, that you have to run the code on a computer where the SMS Gateway gateway is running.

## Installation

To install the ozeki_libs_rest gem, you have to execute the following command:

    $ gem install ozeki_libs_rest

## How to send a simple SMS message

 To use the ozeki_libs_rest you have to create a Configuration object.
```ruby
    configuration = Configuration.new(
        "username",
        "password",
        "http://example.com/api"
    )
```
To initialize a Message object we have to use the following code:

```ruby
    msg = Message.new
    msg.to_address = "+36201111111"
    msg.text = "Hello world!"
```
To send your message  we should create a MessageApi object.
The MessageApi constructor takes only one parameter which is a configuration object.

```ruby
    api = MessageApi.new(configuration)
    
    result = api.send(msg) #We save our result in a varriable
```
