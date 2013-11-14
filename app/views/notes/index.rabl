node(:notes) do |notes|
  @notes.map do |note|
    partial "notes/show", object: note
  end
end