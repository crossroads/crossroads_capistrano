String.class_eval do
  def blank?
    self == ""
  end
end
NilClass.class_eval do
  def blank?
    true
  end
end

