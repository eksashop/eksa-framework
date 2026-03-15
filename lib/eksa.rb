require 'rack'
require 'json'
require_relative 'eksa/version'
require_relative 'eksa/controller'
require_relative 'eksa/model'
require_relative 'eksa/markdown_post'

module Eksa
  class Application
    attr_reader :config, :middlewares

    def initialize
      @routes = {}
      @middlewares = []
      @config = {
        db_path: File.expand_path("./db/eksa_app.db")
      }
      yield self if block_given?
      configure_framework
    end

    def configure_framework
      Eksa::Model.database_path = @config[:db_path]
    end

    def add_route(path, controller_class, action)
      pattern = path.gsub(/:\w+/, '([^/]+)')
      @routes[path] = { 
        controller: controller_class, 
        action: action, 
        regex: Regexp.new("\\A#{pattern}\\z"),
        keys: path.scan(/:(\w+)/).flatten
      }
    end

    def use(middleware, *args, &block)
      @middlewares << [middleware, args, block]
    end

    def call(env)
      @app ||= build_app
      @app.call(env)
    end

    def build_app
      builder = Rack::Builder.new
      @middlewares.each do |middleware, args, block|
        builder.use(middleware, *args, &block)
      end
      builder.run(method(:core_call))
      builder.to_app
    end

    def core_call(env)
      request = Rack::Request.new(env)
      flash_message = request.cookies['eksa_flash']
      
      # Find matching route
      route_config = nil
      params = {}
      
      @routes.each do |path, config|
        if match = config[:regex].match(request.path_info)
          route_config = config
          config[:keys].each_with_index do |key, index|
            params[key] = match[index + 1]
          end
          break
        end
      end

      if route_config
        # Merge dynamic params into request params
        request.params.merge!(params)
        
        controller_instance = route_config[:controller].new(request)
        controller_instance.flash[:notice] = flash_message if flash_message
        response_data = controller_instance.send(route_config[:action])
        if response_data.is_a?(Array) && response_data.size == 3
          status, headers, body = response_data
          response = Rack::Response.new(body, status, headers)
        else
          response = Rack::Response.new
          if controller_instance.status == 302
            response.redirect(controller_instance.redirect_url, 302)
          else
            response.write(response_data)
            response['content-type'] = 'text/html'
          end
        end

        response.delete_cookie('eksa_flash') if flash_message
        response.finish
      else
        html = <<~HTML
          <!DOCTYPE html>
          <html lang="id">
          <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>404 - Halaman Tidak Ditemukan</title>
              <script src="https://cdn.tailwindcss.com"></script>
              <link href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css" rel="stylesheet">
              <script src="https://unpkg.com/lucide@latest"></script>
              <style>
                  body { background: radial-gradient(circle at top left, #1e1b4b 0%, #000000 100%); min-height: 100vh; color: white; font-family: sans-serif; display: flex; align-items: center; justify-content: center; overflow: hidden; margin: 0; }
                  .glass { background: rgba(255, 255, 255, 0.03); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); }
                  .glow { position: absolute; width: 400px; height: 400px; background: radial-gradient(circle, rgba(79, 70, 229, 0.15) 0%, transparent 70%); z-index: -1; filter: blur(40px); }
              </style>
          </head>
          <body>
              <div class="glow" style="top: 0; left: 0; transform: translate(-50%, -50%);"></div>
              <div class="glow" style="bottom: 0; right: 0; transform: translate(50%, 50%);"></div>
              <div class="glass" style="max-width: 512px; width: 100%; padding: 48px; border-radius: 40px; text-align: center; animation: zoomIn 0.8s;">
                  <div style="margin-bottom: 32px; position: relative; display: inline-block;">
                      <div style="position: absolute; inset: 0; background: rgba(79, 70, 229, 0.2); filter: blur(3xl); border-radius: 9999px;"></div>
                      <div style="position: relative; background: rgba(79, 70, 229, 0.2); padding: 24px; border-radius: 24px; border: 1px solid rgba(99, 102, 241, 0.3);">
                          <i data-lucide="ghost" style="width: 64px; height: 64px; color: #a5b4fc;"></i>
                      </div>
                  </div>
                  <h1 style="font-size: 80px; font-weight: 900; margin: 0; letter-spacing: -0.05em; color: white; opacity: 0.9;">404</h1>
                  <h2 style="font-size: 24px; font-weight: 700; margin: 16px 0; color: rgba(255, 255, 255, 0.9);">Oops! Halaman Hilang.</h2>
                  <p style="color: rgba(255, 255, 255, 0.5); margin-bottom: 40px; line-height: 1.6;">Sepertinya halaman yang Anda cari tidak ada atau sudah berpindah alamat. Jangan khawatir, kita bisa kembali.</p>
                  <div style="display: flex; flex-direction: column; gap: 16px; justify-content: center;">
                      <a href="/" style="padding: 16px 32px; background: white; color: black; font-weight: 700; border-radius: 16px; text-decoration: none; display: flex; items-center: center; justify-content: center; gap: 8px;">
                          <i data-lucide="home" style="width: 20px; height: 20px;"></i> Kembali ke Beranda
                      </a>
                  </div>
              </div>
              <script>lucide.createIcons();</script>
          </body>
          </html>
        HTML
        [404, { 'content-type' => 'text/html' }, [html]]
      end
    end
  end
end