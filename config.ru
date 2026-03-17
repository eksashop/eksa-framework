require './lib/eksa'

Dir[File.join(__dir__, 'app/controllers/*.rb')].each { |file| require_relative file }

app = Eksa::Application.new do |config|
  config.config[:db_path] = File.expand_path("./db/eksa_app.db")
  
  config.use Rack::Static, urls: ["/css", "/img"], root: "public"
  config.use Rack::ShowExceptions
end

app.add_route "/", PagesController, :index
app.add_route "/hapus", PagesController, :hapus_pesan
app.add_route "/edit", PagesController, :edit
app.add_route "/about", PagesController, :about
app.add_route "/docs", PagesController, :docs
app.add_route "/kontak", PagesController, :kontak
app.add_route "/conduct", PagesController, :conduct
app.add_route "/security", PagesController, :security
app.add_route "/robots.txt", SeoController, :robots
app.add_route "/sitemap.xml", SeoController, :sitemap
app.add_route "/posts", PostsController, :index
app.add_route "/posts/:slug", PostsController, :show

run app