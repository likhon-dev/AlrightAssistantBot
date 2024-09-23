<?php
$response = file_get_contents('https://randomuser.me/api/');
$data = json_decode($response, true);
$user = $data['results'][0];

$result = "👤 *Random User Generated:*\n\n";
$result .= "📛 Name: {$user['name']['first']} {$user['name']['last']}\n";
$result .= "📧 Email: {$user['email']}\n";
$result .= "☎️ Phone: {$user['phone']}\n";
$result .= "📍 Location: {$user['location']['city']}, {$user['location']['country']}";

$telegram->sendMessage([
    'chat_id' => $chat_id,
    'text' => $result,
    'parse_mode' => 'Markdown'
]);

