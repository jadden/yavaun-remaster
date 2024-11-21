extends Node

func play_click_sound():
	$ClickSoundPlayer.stop()
	$ClickSoundPlayer.play()

func play_confirm_race_sound():
	$ConfirmRacePlayer.stop()
	$ConfirmRacePlayer.play()

func play_menu_choice_sound():
	$MenuChoicePlayer.stop()
	$MenuChoicePlayer.play()
