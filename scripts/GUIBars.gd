extends ProgressBar


func _on_Starship_health_changed(new_health, _old):
	value = new_health
	$Label.text = str(floor(value)) + "%"


func _on_Starship_energy_changed(new_energy, _old):
	value = new_energy
	$Label.text = str(floor(value)) + "%"
