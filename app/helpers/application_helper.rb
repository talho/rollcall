module ApplicationHelper
  PARAM_KEY_BLACKLIST = :authenticity_token, :commit, :utf8, :_method, :action, :controller

  def render_flash
    content = ""
    content << %Q{<div class="alert alert-error alert-dismissible" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>#{flash[:error]}</div>} unless flash[:error].blank?
    content << %Q{<div class="alert alert-info alert-dismissible" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>#{flash[:notice]}</div>} unless flash[:notice].blank?
    content << %Q{<div class="alert alert-warning alert-dismissible" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>#{flash[:warning]}</div>} unless flash[:warning].blank?
    content << %Q{<div class="alert alert-success alert-dismissible" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>#{flash[:success]}</div>} unless flash[:success].blank?
    unless flash[:errors].blank?
      content << %Q{<div class="alert alert-error" role="alert"><ul class="unstyled">}
      content << %Q{<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>}
      flash[:errors].each do |e|
        content << "<li>#{e}</li>"
      end
      content << %Q{</ul></div>}
    end
    content.html_safe
  end

  def clean_params
    params.except(*PARAM_KEY_BLACKLIST)
  end
end
