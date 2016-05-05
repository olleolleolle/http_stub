module HtmlHelpers
  include Haml::Helpers

  alias_method :encode_whitespace, :preserve
end
