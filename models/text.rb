#encoding: utf-8
class Text
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  
  belongs_to :user
  has n, :sentences

  def self.fill str
  str_array = str.split("。")
  str_array.each do |sentence|
    sentence.strip + "。"
  end
  end
  
end

class Sentence
  include DataMapper::Resource
  property :id, Serial
  property :japanese, Text
  property :german, Text

  belongs_to :text

end
