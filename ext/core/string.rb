require 'addressable/uri'

class String
  def sanitize
    Addressable::URI.parse(self.downcase.gsub(/[[:^word:]]/u,'-').squeeze('-').chomp('-').gsub(/^\-/, '').gsub(/\-$/, '')).normalized_path
  end

  def is_email?
    (self =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/u) != nil
  end

  def to_plural
    DataMapper::Inflector.pluralize(self)
  end

  def pluralize(n = nil)
    plural = to_plural
    n && n != 1 ? "#{n} #{plural}" : "1 #{self}"
  end

  def vowelize
    Vowels.include?(self[0]) ? "an #{self}" : "a #{self}"
  end

  def to_markdown
    PageHub::Markdown.render!(self)
  end

  # expected format: "MM/DD/YYYY"
  def to_date(graceful = true)
    m,d,y = self.split(/\/|\-/)
    begin
      DateTime.new(y.to_i,m.to_i,d.to_i)
    rescue ArgumentError => e
      raise e unless graceful
      DateTime.now
    end
  end

  alias_method :blank?, :empty?

  private

  Vowels = ['a','o','u','i','e']
end