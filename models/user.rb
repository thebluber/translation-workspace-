class User
  include DataMapper::Resource

  property :id, Serial
  property :email, String
  property :password_hash, String

  has n, :texts
  has n, :sentences, :through => :texts

  def self.authenticate(params)
    User.first(:email => params[:email], :password_hash => User.encode(params[:password]))
  end

  def password=(pw)
    self.password_hash = User.encode(pw)
  end

private
  def self.encode pw_str
    Digest::SHA1.hexdigest(pw_str)
  end



end
