extends "res://scripts/ui_core.gd"

var langs = {
	'en': 'english',
	'fr': 'français',
	'ar': 'العربية',
	'afr': 'afrikaans',
	'ojb': 'ojibwe',
	'crm': 'creole (_mauritius)',
	'crh': 'creole (_haiti)'
}

func _lang_select(loc):
	TranslationServer.set_locale(loc)

func _ready():
	var index = langs.keys()
	index.sort()
	index.invert()
	for l in range(index.size()):
		var btn = get_child(1).duplicate(l)
		btn.name = index[l]
		btn.text = langs[index[l]].capitalize()
		add_child_below_node($sep_bot,btn,true)
		btn.connect('pressed', self, '_lang_select', [btn.name])
