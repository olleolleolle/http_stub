module HtmlEncodingHelper
  include Haml::Helpers

  def encode_whitespace(string)
    preserve(string)
  end

end
