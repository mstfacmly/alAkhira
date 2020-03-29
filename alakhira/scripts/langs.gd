extends "res://scripts/ui_core.gd"

const languages = [
	'English',
	'Français',
	'العربية',
]

func _lang_select(btn):
	if btn == 'English':
		TranslationServer.set_locale('en')
	if btn == 'Français':
		TranslationServer.set_locale('fr')
	if btn == 'العربية':
		TranslationServer.set_locale('ar')

func _showhide():
	if is_visible() != true:
		set_visible(true)
		back = funcref(self, '_showhide')
	else:
		set_visible(false)
	
	_grab_menu()

func _ready():
	for l in range(languages.size()):
		var btn = get_node('btn' + str(l))
		btn.set_text(languages[l])
		btn.connect('pressed', self, '_lang_select', [btn.get_text()])
