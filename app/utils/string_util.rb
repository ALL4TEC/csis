# frozen_string_literal: true

class StringUtil
  class << self
    def remove_html(input, tags = ['<P>', '<BR>', '<p>', '</p>'])
      tags.each do |tag|
        input&.gsub!(tag, '')
      end
    end
  end
end
