# frozen_string_literal: true

class QualysWa::ScanTest
  attr_reader :qid,
    :title,
    :data,
    :param,
    :payload,
    :result,
    :uri,
    :content

  def initialize(data)
    @qid = data.at_xpath('.//qid')&.text
    @title = data.at_xpath('.//title')&.text
    @data = handle_base64(data.at_xpath('.//data'))
    @param = data.at_xpath('.//param')&.text
    @payload = data.at_xpath('.//payload')&.text
    @result = handle_base64(data.at_xpath('.//result'))
    @uri = data.at_xpath('.//uri')&.text
    @content = data.at_xpath('.//contents')&.text
  end

  private

  def handle_base64(node)
    decoded = node&.text
    if node&.attributes&.values_at('base64')&.first&.value == 'true' && decoded.present?
      decoded = Base64.decode64(decoded)
    end
    decoded
  end
end
