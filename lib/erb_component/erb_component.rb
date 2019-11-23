require "erb_component/version"
require 'erb'

class ErbComponent
  class Error < StandardError;
  end

  attr_reader :req, :parent

  def initialize(req, opts = {})
    @req = req
    begin
      @parent = self.class.superclass == ErbComponent ? nil : self.class.superclass.new(req)
      if @parent && !(parent.template['{{VIEW}}'] || parent.template['{{view}}'])
        @parent = parent.parent
      end
    rescue ArgumentError
    end
  end

  def path
    @req.path
  end

  def params
    @req.params.with_indifferent_access
  end

  def render
    str = ERB.new(template).result(binding)
    if parent
      parent.render.gsub("{{VIEW}}", str).gsub("{{view}}", str)
    else
      str
    end
  end

  def self.render(opts = {})
    new(opts).render
  end

  def template_file_path
    file_name = "#{self.class.name.underscore}.erb"
    if File.exists? "components/#{file_name}"
      return "components/#{file_name}"
    elsif File.exists? "pages/#{file_name}"
      return "pages/#{file_name}"
    else
      nil
    end
  end

  def template
    return File.read(template_file_path) if template_file_path
    fail "not found: #{template_file_path}"
  end

  def method_missing(m, *args, &block)
    m = m.to_s
    str = Kernel.const_defined?("#{self.class}::#{m}") ? "#{self.class}::#{m}" : m
    clazz = Kernel.const_get(str)
    if args.size > 0
      component = clazz.new(req, *args)
    else
      component = clazz.new(req)
    end
    begin
      component.render
    rescue StandardError => err
      binding.pry
      super
    end
  end
end
