class Otoy
  module Utilities

    RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/

    def self.safe_b64_encode(msg)
      Base64.strict_encode64(msg).tr("+/", "-_").gsub('=', '') rescue nil
    end

    def self.safe_b64_decode(msg)
      msg += '=' * (4 - msg.length.modulo(4))
      Base64.strict_decode64(msg.tr("-_", "+/")) rescue nil
    end

    def self.url_escape(str)
      URI::escape(str.to_s, RESERVED_CHARACTERS)
    rescue
      URI::escape(str.to_s.force_encoding(Encoding::UTF_8), RESERVED_CHARACTERS)
    end

  end
end
