module GraphingHelper
  def graph_filter_path(name, val)
    opts = {}
    opts[name] = val
    graphing_index_path(clean_params.merge(opts))
  end

  def graph_filter_array_path(name, val)
    graphing_index_path(toggle_array_param(name, val))
  end

  def graph_filter_toggle_path(name, val)
    opts = clean_params.deep_dup
    unless opts[name].present?
      opts[name] = val
    else
      opts.delete(name)
    end
    graphing_index_path(opts)
  end

  def toggle_array_param(name, val)
    opts = clean_params.deep_dup
    val = Array(val)
    if opts[name].blank?
      opts[name] = val
    elsif !(opts[name] & val).blank?
      val.each {|v| opts[name].delete(v) }
    else
      opts[name].concat val
    end

    opts
  end

  def param_active(name, val)
    'active' if params[name].present? && params[name].to_s == val.to_s
  end

  def not_param_active(name, val)
    'active' unless params[name].present? && params[name].to_s == val.to_s
  end

  def param_array_active(name, val)
    val = Array(val)
    'active' if params[name].present? && !(params[name].map(&:to_s) & val.map(&:to_s)).blank?
  end
end
