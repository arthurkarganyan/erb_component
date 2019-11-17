require "erb_component/version"
require 'erb'

class ErbComponent
  class Error < StandardError; end

  attr_reader :params, :path, :parent

  def initialize(opts = {})
    @params = opts[:params] || {}
    @path = opts[:path]
    @parent = self.class.superclass == ErbComponent ? nil : self.class.superclass.new(opts)
  end

  def render
    str = ERB.new(template).result(binding)
    parent ? parent.render.gsub("{{VIEW}}", str) : str
  end

  def self.render(opts = {})
    new(opts).render
  end

  def template
    a = "components/#{self.class.name.underscore}.erb"
    return File.read a if File.exists? a
    fail 'not found'
  end

  def method_missing(m, *args, &block)
    possible_const = "#{self.class}::#{m}"
    clazz = if Kernel.const_defined?(possible_const)
              Kernel.const_get possible_const
            else
              Kernel.const_get m.to_s
            end
    opts = {path: path, params: params}
    opts.merge!(args[0]) if args.size > 0
    component = clazz.new(opts)
    component.render
  end
end
