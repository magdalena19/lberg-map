# Monkey patch encryption on Strings
# To be used for symmetrical encryption of twitter API tokens
class String
  # Look for dedicated twitter encryption passphrase, otherwise use Rails secret key base
  KEY = ENV['TWITTER_TOKEN_ENCRYPTION_PHRASE'] ||
    ENV['SECRET_KEY_BASE'] || # Production
    ENV['secret_key_base'] || # Production
    Rails.application.secrets.secret_key_base # Development

  def encrypt(key: KEY)
    begin
      cipher = OpenSSL::Cipher.new('AES-128-CBC-HMAC-SHA256').encrypt
      cipher.key = Digest::SHA1.hexdigest key
      s = cipher.update(self) + cipher.final

      s.unpack('H*')[0].upcase
    rescue
      nil
    end
  end

  def decrypt(key: KEY)
    begin
      cipher = OpenSSL::Cipher.new('AES-128-CBC-HMAC-SHA256').decrypt
      cipher.key = Digest::SHA1.hexdigest key
      s = [self].pack("H*").unpack("C*").pack("c*")

      cipher.update(s) + cipher.final
    rescue
      nil
    end
  end
end
