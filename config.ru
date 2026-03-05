require './lib/eksa'
require './app/controllers/pages_controller'

use Rack::Static, urls: ["/css", "/img"], root: "public"
use Rack::ShowExceptions

app = Eksa::Application.new

app.add_route "/", PagesController, :index
app.add_route "/hapus", PagesController, :hapus_pesan
app.add_route "/edit", PagesController, :edit
app.add_route "/about", PagesController, :about
app.add_route "/docs", PagesController, :docs
app.add_route "/kontak", PagesController, :kontak

run app