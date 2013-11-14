object @note

attributes :id, :note, :created_at

node(:media) do |note|
  {
    url: note.url
  }
end
