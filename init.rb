# Include hook code here
require 'rollcall'

ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :rollcall => [ "rollcall/rollcall" ])

ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :rollcall => [])
