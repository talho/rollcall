module MainHelper
  def severity_class(pct)
    if pct > 0.2
      'text-danger'
    elsif pct > 0.1
      ''
    elsif pct > 0.05
      'text-warning'
    else
      'text-muted'
    end
  end
end
