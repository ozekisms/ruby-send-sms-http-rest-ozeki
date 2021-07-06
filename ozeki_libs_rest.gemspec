Gem::Specification.new do |spec|
    spec.name = 'ozeki_libs_rest'
    spec.version = '1.0.4'
    spec.summary = 'This is a library for the Ozeki SMS Gateway software.'
    spec.description = 'With the ozeki_libs_rest library you can send SMS messages using the Ruby programming language and the Ozeki SMS Gateway.'
    spec.author = 'Zsolt Ardai'
    spec.email = 'info@ozeki.hu'
    spec.files = ['lib/ozeki_libs_rest.rb']
    spec.add_dependency('faraday', '~> 1.5.0')
    spec.homepage = 'http://in.ozeki.hu/p_867-ruby-send-sms-with-the-http-rest-api-code-sample.html'
    spec.license = 'MIT'
end