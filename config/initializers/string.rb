# Monkey patch encryption on Strings
# To be used for symmetrical encryption of twitter API tokens
class String
  # Look for dedicated twitter encryption passphrase, otherwise use Rails secret key base
  KEY = ENV['TWITTER_TOKEN_ENCRYPTION_PHRASE']

  def encrypt(key: KEY)
    begin
      cipher = OpenSSL::Cipher.new('AES-256-CBC').encrypt
      cipher.key = Digest::SHA1.hexdigest key
      s = cipher.update(self) + cipher.final

      s.unpack('H*')[0].upcase
    rescue Exception => e
      Rails.logger.info "Key found: #{key.nil? ? 'No' : 'Yes'}"
      Rails.logger.info e.to_s
    end
  end

  def decrypt(key: KEY)
    begin
      cipher = OpenSSL::Cipher.new('AES-256-CBC').decrypt
      cipher.key = Digest::SHA1.hexdigest key
      s = [self].pack("H*").unpack("C*").pack("c*")

      cipher.update(s) + cipher.final
    rescue Exception => e
      Rails.logger.info "Key found: #{key.nil? ? 'No' : 'Yes'}"
      Rails.logger.info e.to_s
    end
  end
end
