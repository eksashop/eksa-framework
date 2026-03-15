class SeoController < Eksa::Controller
  def robots
    scheme = request.env['rack.url_scheme'] || 'https'
    content = <<~TEXT
      User-agent: *
      Allow: /
      Disallow: /hapus
      Disallow: /edit
      
      Sitemap: #{scheme}://#{request.host}/sitemap.xml
    TEXT
    [200, { "Content-Type" => "text/plain" }, [content]]
  end

  def sitemap
    scheme = request.env['rack.url_scheme'] || 'https'
    base_url = "#{scheme}://#{request.host}"
    lastmod = Time.now.strftime("%Y-%m-%d")
    
    xml = '<?xml version="1.0" encoding="UTF-8"?>'
    xml += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    
    # Base Pages
    ["/", "/about", "/docs", "/kontak", "/posts"].each do |path|
      xml += "<url>"
      xml += "<loc>#{base_url}#{path}</loc>"
      xml += "<lastmod>#{lastmod}</lastmod>"
      xml += "<priority>#{path == '/' ? '1.0' : '0.8'}</priority>"
      xml += "</url>"
    end

    # Blog Posts
    Eksa::MarkdownPost.all.each do |post|
      xml += "<url>"
      xml += "<loc>#{base_url}/posts/#{post.slug}</loc>"
      xml += "<lastmod>#{post.date.is_a?(Time) ? post.date.strftime("%Y-%m-%d") : lastmod}</lastmod>"
      xml += "<priority>0.6</priority>"
      xml += "</url>"
    end
    
    xml += '</urlset>'
    [200, { "Content-Type" => "application/xml" }, [xml]]
  end
end