module Eksa
  class CmsController < Eksa::Controller
    def index
      return unless require_auth
      
      @posts = Eksa::MarkdownPost.all(include_unpublished: true)
      render_internal 'cms/index'
    end

    def edit
      return unless require_auth
      
      slug = params['slug']
      @post = Eksa::MarkdownPost.find(slug)
      
      if @post
        render_internal 'cms/edit'
      else
        redirect_to "/cms", notice: "Error: Postingan tidak ditemukan."
      end
    end

    def update_post
      return unless require_auth
      
      slug = params['slug']
      post_path = File.join(Eksa::MarkdownPost::POSTS_DIR, "#{slug}.md")
      
      unless File.exist?(post_path)
        return redirect_to "/cms", notice: "Error: Postingan tidak ditemukan."
      end

      # Existing metadata fetching to preserve unmodified keys like 'date' if not handling them
      # We parse form params
      title = params['title']
      category = params['category']
      author = params['author']
      image = params['image']
      content = params['content']
      
      # We'll re-read the original to preserve keys we aren't allowing to edit (like published status and date)
      original_content = File.read(post_path, encoding: 'utf-8')
      metadata = {}
      
      if original_content =~ /\A(---\s*\r?\n.*?\r?\n)^(---\s*\r?\n?)/m
        metadata = YAML.safe_load($1, permitted_classes: [Time]) || {}
      end
      
      # Update metadata with form values
      metadata['title'] = title
      metadata['category'] = category
      metadata['author'] = author
      metadata['image'] = image unless image.nil? || image.strip.empty?
      
      # Dump new YAML
      new_yaml = YAML.dump(metadata)
      
      # Join with content
      new_file_content = "#{new_yaml}---\n\n#{content}"
      
      # Write changes
      File.write(post_path, new_file_content, encoding: 'utf-8')
      
      redirect_to "/cms", notice: "Postingan '#{title}' berhasil diperbarui."
    end

    def toggle_status
      return unless require_auth
      
      slug = params['slug']
      post_path = File.join(Eksa::MarkdownPost::POSTS_DIR, "#{slug}.md")
      
      if File.exist?(post_path)
        content = File.read(post_path, encoding: 'utf-8')
        
        # Simple string replacement for published status in front matter
        if content.match?(/^published:\s*false/m)
          new_content = content.sub(/^published:\s*false/m, "published: true")
          status = "diaktifkan"
        elsif content.match?(/^published:\s*true/m)
          new_content = content.sub(/^published:\s*true/m, "published: false")
          status = "dinonaktifkan"
        else
          # If no published tag exists, it's implicitly true, so we set it to false
          new_content = content.sub(/\A(---\r?\n)/) { "#{$1}published: false\n" }
          status = "dinonaktifkan"
        end
        
        File.write(post_path, new_content)
        redirect_to "/cms", notice: "Postingan #{File.basename(post_path)} berhasil #{status}."
      else
        redirect_to "/cms", notice: "Error: Postingan tidak ditemukan."
      end
    end

    def delete_post
      return unless require_auth

      slug = params['slug']
      post_path = File.join(Eksa::MarkdownPost::POSTS_DIR, "#{slug}.md")

      if File.exist?(post_path)
        File.delete(post_path)
        redirect_to "/cms", notice: "Postingan berhasil dihapus secara permanen."
      else
        redirect_to "/cms", notice: "Error: Postingan tidak ditemukan."
      end
    end
  end
end
