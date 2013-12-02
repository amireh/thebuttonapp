module Algol
  def self.password_salt()
    rand(36**16).to_s(32)[0..6]
  end

  def self.tiny_salt(r = 3)
    Base64.urlsafe_encode64 Random.rand(1234 * (10**r)).to_s(8)
  end

  def self.sane_salt(pepper)
    Base64.urlsafe_encode64( pepper + Time.now.to_s)
  end

  def self.salt(pepper = "")
    pepper = Random.rand(12345 * 1000).to_s if pepper.empty?
    pepper = pepper + Random.rand(1234).to_s
    sane_salt(pepper)
  end
end

helpers Algol