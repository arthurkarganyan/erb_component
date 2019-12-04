module ReqTools
  def path
    @req.path
  end

  def path_hash
    @path_hash ||= begin
      split = path.split('/')
      split.shift

      res = {}
      split.size.times do |i|
        if split[i].to_i.to_s == split[i]
          res[split[i - 1].singularize + "_id"] = split[i]
        end
      end
      res.with_indifferent_access
    end
  end

  def params
    @params ||= begin
      res = @req.params
      res.merge!(JSON.parse(req.body.read)) if req.post? || req.put? || req.patch?
      res.merge!(path_hash)
      res.with_indifferent_access
    end
  end

  def method_missing(m, *args, &block)
    return super unless m.to_s[0].upcase == m.to_s[0]
    m = m.to_s
    str = Kernel.const_defined?("#{self.class}::#{m}") ? "#{self.class}::#{m}" : m
    clazz = Kernel.const_get(str)
    if args.size > 0
      component = clazz.new(req, *args)
    else
      component = clazz.new(req)
    end
    component.render
  end
end
