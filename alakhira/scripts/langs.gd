extends "res://scripts/ui_core.gd"

var langs = {
	'en': 'english',
	'fr': 'français',
	'ar': 'العربية',
	'afr': 'afrikaans',
	'ojb': 'ojibweᐊᓂᐦᔑᓈᐯᒧᐎᓐᐊᓂᐦᔑᓈᐯᒧᐎᓐᐊᓂᐦᔑᓈᐯᒧᐎᓐᐊᓂᐦᔑᓈᐯᒧᐎ',
	'crm': 'creole (_mauritius_)',
	'crh': 'creole (_haiti_)',
	'jp' : '日本語',
	'cn' : 'chinese',
	'pr' : 'portuguese',
	'tmz' : 'tamazight',
	'fn' : 'finnish',
	'ru' : 'русский',
	'po' : 'polish',
	'fa' : 'فارسی',
	'in' : 'indian',
	'vt' : '㗂越',
	'sp' : 'spanish',
	'it' : 'italian'
}

func _lang_select(loc):
	TranslationServer.set_locale(loc)

func _resize_scroll(mu):
	$scroll.rect_min_size.y = $scroll/list/btn0.rect_size.y * mu

func _ready():
	var index = langs.keys()
	index.sort()
	for l in range(index.size()):
		var btn = $scroll/list.get_child(0).duplicate(l)
		btn.name = index[l]
		btn.text = langs[index[l]].capitalize()
		btn.connect('pressed', self, '_lang_select', [btn.name])
		btn.show()
		$scroll/list.add_child(btn)

	_resize_scroll(7)
