class Hash
  # Removes a key from the hash and returns the hash
  def delete!(key)
    self.delete(key)
    self
  end
end

