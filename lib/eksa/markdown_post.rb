# frozen_string_literal: true
# encoding: utf-8

require 'yaml'
require 'kramdown'

module Eksa
  class MarkdownPost
    attr_reader :content, :metadata, :slug, :filename

    POSTS_DIR = "_posts"

    def self.all
      return [] unless Dir.exist?(POSTS_DIR)
      
      Dir.glob(File.join(POSTS_DIR, "*.md")).map do |file|
        new(file)
      end.sort_by { |p| p.date }.reverse
    end

    def self.find(slug)
      all.find { |p| p.slug == slug }
    end

    def initialize(file_path)
      @filename = File.basename(file_path)
      @slug = @filename.sub(/\.md$/, '')
      load_file(file_path)
    end

    def title
      @metadata['title'] || "Untitled Post"
    end

    def date
      @metadata['date'] || File.mtime(File.join(POSTS_DIR, @filename))
    end

    def author
      @metadata['author'] || ""
    end

    def category
      @metadata['category'] || "Uncategorized"
    end

    def image
      @metadata['image'] || ""
    end

    def body_html
      Kramdown::Document.new(@content, input: 'GFM').to_html
    end

    private

    def load_file(file_path)
      content = File.read(file_path, encoding: 'utf-8')
      # Improved regex: handle optional trailing newline after second separator
      if content =~ /\A(---\s*\r?\n.*?\r?\n)^(---\s*\r?\n?)/m
        @metadata = YAML.safe_load($1, permitted_classes: [Time])
        @content = $'
      else
        @metadata = {}
        @content = content
      end
    end
  end
end
