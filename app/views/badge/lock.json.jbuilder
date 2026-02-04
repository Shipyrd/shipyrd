json.schemaVersion 1
json.label "#{@destination.locked? ? "🔒" : "🔓"} #{@destination.name}"
json.color @destination.locked? ? "yellow" : "green"

json.message(@destination.locked_by.presence || "unlocked")
