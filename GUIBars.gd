extends ProgressBar


func _on_Starship_health_changed(new_health):
	value = new_health;


func _on_Starship_energy_changed(new_energy):
	value = new_energy;
