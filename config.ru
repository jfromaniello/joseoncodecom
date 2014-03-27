require 'rack'
require 'rack/contrib/try_static'
require 'rack/contrib/static_cache'

system("ejekyll")

use Rack::CommonLogger

use Rack::StaticCache,
    :urls => ["/css", "/js" ], :root => "_site",
    :duration => 0.5

use Rack::TryStatic,
    :root => "_site",   # static files root dir
    :urls => %w[/],     # match all requests
    :try => ['.html', 'index.html', '/index.html'] # try these postfixes sequentially

map '/' do
  # otherwise 404 NotFound
  run Proc.new {|env| [404, {"Content-Type" => "text/html"}, ["Not Found... Sorry!"]] }
end


# I use a wrong character for this article and was causing lot of headaches
map '/2011/03/30/entityframework-4-1-rc-%E2%80%93-code-first-review/' do
  run Proc.new {|env| [302, {'Location' => 'http://joseoncode.com/2011/03/30/entityframework-4-1-rc-code-first-review/'}, ["infinity 0.1"]] }
end

map '/.well-known/keybase.txt' do
  run Proc.new {|env| [302, {'Location' => 'http://joseoncode.com/well-known/keybase.txt'}, ["infinity 0.1"]] }
end
