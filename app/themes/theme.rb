# encoding: utf-8

class Theme
  ATTRIBUTES = [:id, :name, :author, :stylesheet, :mobile_stylesheet].freeze
  attr_accessor(*ATTRIBUTES)

  class << self
    def all
      ids = base_dir.entries.select do |d|
        File.exist?(base_dir.join(d, "theme.yml"))
      end.map(&:to_s)
      ids.map { |id| find(id) }
    end

    def precompile_assets
      all.flat_map do |theme|
        [theme.stylesheet_path, theme.mobile_stylesheet_path]
      end.compact
    end

    def mobile
      all.select(&:mobile?)
    end

    def find(id)
      themes[id] ||= load(id)
    end

    def base_dir
      Rails.root.join("app", "themes")
    end

    private

    def themes
      @themes ||= {}
    end

    def load(id)
      theme_dir  = base_dir.join(id)
      theme_file = theme_dir.join("theme.yml")
      raise "Theme not found" unless File.exist?(theme_file)
      Theme.new(YAML.load_file(theme_file).merge(id: id))
    end
  end

  def initialize(options = {})
    configure_options(options)
  end

  def path(filename = nil)
    filename ? "#{id}/#{filename}" : nil
  end

  def dir
    Theme.base_dir.join(id)
  end

  def mobile?
    mobile_stylesheet?
  end

  def stylesheet
    @stylesheet || "screen.css"
  end

  def stylesheet_path
    path(stylesheet)
  end

  def mobile_stylesheet_path
    path(mobile_stylesheet)
  end

  def full_name
    author? ? "#{name} by #{author}" : name
  end

  private

  def method_missing(method, *args, &block)
    base_method = method.to_s.gsub(/\?$/, "").to_sym
    if method.to_s =~ /\?$/ && ATTRIBUTES.include?(base_method)
      !send(base_method).blank?
    else
      super
    end
  end

  def configure_options(options = {})
    options.symbolize_keys!
    options.each do |key, value|
      send("#{key}=".to_sym, value) if respond_to?("#{key}=".to_sym)
    end
  end
end
