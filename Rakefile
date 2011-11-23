desc 'notify search engines'
task :default do
	puts '* Pushing to github'
	`git push origin`
	
	puts '* Deploying to heroku'
	`git push heroku`
	
	Rake::Task["sitemap"].invoke
end
task :sitemap do
  begin
    require 'net/http'
    require 'uri'
    puts '* Pinging Google about our sitemap'
    Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + URI.escape('http://joseoncode.com/sitemap.xml'))
    puts '* Pinging Bing about our sitemap'
    Net::HTTP.get('www.bing.com', '/ping?sitemap=' + URI.escape('http://joseoncode.com/sitemap.xml'))
  rescue LoadError
    puts '! Could not ping Google about our sitemap, because Net::HTTP or URI could not be found.'
  end
end