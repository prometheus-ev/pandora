unless OpenSSL::Cipher.const_defined?(:CipherError)
  OpenSSL::Cipher::CipherError = OpenSSL::CipherError
end

module Util
  module Crypter
    extend self

    def encrypt(...)
      Base64.encode64(crypt(:encrypt, ...))
    end

    def decrypt(*args)
      crypt(:decrypt, Base64.decode64(args.shift), *args)
    end

    def crypt(method, value, iv, key)
      # REWRITE: the library usage has changed
      # cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.send(method) # encrypt/decrypt

      # REWRITE: we have to cut down the iv byte size since the new version of
      # openssl requires it.
      # TODO: does that bring problems with the oauth functionality?, Could we
      # use cipher.random_iv?
      # cipher.iv  = Digest::SHA256.hexdigest(iv)
      cipher.iv  = Digest::SHA256.hexdigest(iv).first(16)
      # REWRITE: key has to be 32 bytes
      # cipher.key = Digest::SHA256.hexdigest(key)
      cipher.key = Digest::SHA256.hexdigest(key).first(32)

      # REWRITE: this is now done in a different way
      # cipher << value << cipher.final
      cipher.update(value) + cipher.final
    rescue OpenSSL::Cipher::CipherError
      # ???
    end
  end
end
