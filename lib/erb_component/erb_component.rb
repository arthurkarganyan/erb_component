require "erb_component/version"
require "erb_component/req_tools"
require 'erb'

class ErbComponent
  include ReqTools

  class Error < StandardError;
  end

  attr_reader :req, :parent

  def initialize(req, opts = {})
    @req = req
    @template = opts[:template]
    begin
      @parent = self.class.superclass == ErbComponent ? nil : self.class.superclass.new(req)
      if @parent && !(parent.template['{{VIEW}}'] || parent.template['{{view}}'])
        @parent = parent.parent
      end
    rescue ArgumentError
    end
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

  def self.call(req, opts = {})
    new(req, opts).render
  end

  def self.current_file=(file)
    @current_file = file
  end

  def self.current_file
    @current_file
  end

  def template_file_path
    self.class.current_file.gsub('.rb', '.erb')
  end

  def template
    return @template if @template
    return File.read(template_file_path) if template_file_path
    fail "not found: #{template_file_path}"
  end
end
