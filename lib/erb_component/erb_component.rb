require "erb_component/version"
require 'erb'

class ErbComponent
  class Error < StandardError;
  end

  attr_reader :req, :parent

  def initialize(req)
    @req = req
    @parent = self.class.superclass == ErbComponent ? nil : self.class.superclass.new(req)
  end

  def path
    @req.path
  end

  def params
    @req.params
  end

  def render
    str = ERB.new(template).result(binding)
    parent ? parent.render.gsub("{{VIEW}}", str).gsub("{{view}}", str) : str
  end

  def self.render(opts = {})
    new(opts).render
  end

  def template
    file_name = "#{self.class.name.underscore}.erb"
    a = "components/#{file_name}"
    return File.read a if File.exists? a
    a = "pages/#{file_name}"
    return File.read a if File.exists? a
    fail "not found: #{file_name}"
  end

  def method_missing(m, *args, &block)
    m = m.to_s
    str = Kernel.const_defined?("#{self.class}::#{m}") ? "#{self.class}::#{m}" : m
    clazz = Kernel.const_get(str)
    opts = {path: path, params: params}
    opts.merge!(args[0]) if args.size > 0
    component = clazz.new(opts)
    component.render
  rescue
    super
  end
end
