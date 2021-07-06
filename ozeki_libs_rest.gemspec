Gem::Specification.new do |spec|
    spec.name = 'ozeki_libs_rest'
    spec.version = '1.0.1'
    spec.summary = 'This is a library for the Ozeki SMS Gateway software.'
    spec.description = 'With the ozeki_libs_rest library you can send SMS messages using the Ruby programming language and the Ozeki SMS Gateway.'
    spec.author = 'Zsolt Ardai'
    spec.email = ''
    spec.files = ['lib/ozeki_libs_rest.rb']
    spec.add_dependency('faraday', '~> 1.5.0')
    spec.homepage = 'https://github.com/ozekisms/ruby-send-sms-http-rest-ozeki'
    spec.license = 'MIT'
end