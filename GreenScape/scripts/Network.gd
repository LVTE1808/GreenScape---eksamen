extends Control


# Declare member variables here. Examples:
var http_request : HTTPRequest = HTTPRequest.new()
const SERVER_URL = "http://ddu-vnl.dk/db_test.php"
const SERVER_HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Cache-Control: max-age=0"]
const SECRET_KEY = 31415926535

var nonce = null
var request_queue : Array = []
var is_requesting : bool = false

func _ready():
	# Opret et HTTPRequest-objekt
	randomize()
	add_child(http_request)
	# Lyt efter signaler fra HTTPRequest
	http_request.connect("request_completed", self, "_http_request_completed")
	

func _process(delta):

	
	if is_requesting:
		return
		
	if request_queue.empty():
		return
		
	is_requesting = true
	_send_request(request_queue.pop_front())

	
	#if nonce == null:
	#	request_nonce()
	#else:
	#	_send_request(request_queue.pop_front())
	
	
#func request_nonce():
#	var client = HTTPClient.new()
#	var data = client.query_string_from_dict({"data" : JSON.print({})})
#	var body = "command=get_nonce&" + data
#	
#	var err = http_request.request(SERVER_URL, SERVER_HEADERS, false, HTTPClient.METHOD_POST, body)
#	
#	if err != OK:
#		printerr("HTTPRequest error: " + String(err))
#		return
#		
#	print("Requeste nonce")
	
	
	
func _send_request(request: Dictionary):
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({"data" : JSON.print(request['data'])})
	var body = "command=" + request['command'] + "&" + data
	
	#var cnonce = String(Crypto.new().generate_random_bytes(32)).sha256_text()
	
	#var client_hash = (nonce + cnonce + body + String(SECRET_KEY)).sha256_text()
	#print(client_hash)
	#nonce = null
	
	var headers = SERVER_HEADERS.duplicate()
	#headers.push_back("cnonce: " + cnonce)
	#headers.push_back("hash: " + client_hash)
	
	var err = http_request.request(SERVER_URL, headers, false, HTTPClient.METHOD_POST, body)
		
	if err != OK:
		printerr("HTTPRequest error: " + String(err))
		return
		
	print("Requesting...\n\tCommand: " + request['command'] + "\n\tBody: " + body)


func _http_request_completed(_result, _response_code, _headers, _body):
	is_requesting = false
	if _result != http_request.RESULT_SUCCESS:
		printerr("Error w/ connection: " + String(_result))
		return
	
	var response_body = _body.get_string_from_utf8()
	#$TextEdit.set_text(response_body)
	var response = parse_json(response_body)

	if response['error'] != "none":
		printerr("We returned error: " + response['error'])
		return
	
	if(response['data_status'] == "no player"):
		print("No user")
	else:
		print(String(response['response'][0]['password']))
		
	#if response['command'] == "get_nonce":
	#	nonce = response['response']['nonce']
	#	print("Get nonce: " + response['response']['nonce'])
	#	return	
	# Håndter svaret fra HTTP-anmodningen
	#if response_code == 200:
	#	var data = parse_json(body)
	#	# Håndter dataene, f.eks. vis dem i UI'en
	#	print(data) # Udskriv dataene til konsollen
	#else:
	#	print("Anmodning mislykkedes:", response_code)


func _on_GetScores_pressed():
	# Send en HTTP GET-anmodning for at indlæse data
	var username = $PlayerName.get_text()
	var password = $Score.get_text()
	
	var params = {
	"action": "get_scores" # Handlingen, der skal udføres i PHP-scriptet
	}
	http_request.request("https://www.simply.com/dk/controlpanel/ddu-vnl.dk/filebrowser/view/?file=GreenScape.php", params)


func _on_AddScore_pressed():
	# Send en HTTP POST-anmodning for at gemme data
	var username = $PlayerName.get_text()
	var score = $Score.get_text()
	
	#var params = {
	#"action": "add_score", # Handlingen, der skal udføres i PHP-scriptet
	#"user_name": username, # Brugernavn
	#"score": password # Scoren, der skal gemmes
	#}
	var params = "action=" + "add_score&" + "data:{user_name:" + username + ",score:" + score + "}"  # Handlingen, der skal udføres i PHP-scriptet
	#"user_name": username, # Brugernavn
	#"score": password # Scoren, der skal gemmes
	#}
	http_request.request("https://www.simply.com/dk/controlpanel/ddu-vnl.dk/filebrowser/view/?file=GreenScape.php", SERVER_HEADERS, true,HTTPClient.METHOD_POST, params)

func _get_player():
	var username = $PlayerName.get_text()
	var password = $Score.get_text()
	
	var command = "get_player"
	var data = {"username":username, "password":password}
	request_queue.push_back({"command" : command, "data" : data})




func _on_tilbage_pressed():
	Scenetransition.change_scene("res://Scenes/Startside.tscn")
