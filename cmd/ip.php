<?php
$response = file_get_contents('https://api.ipify.org?format=json');
$data = json_decode($response, true);

$telegram->sendMessage([
    'chat_id' => $chat_id,
    'text' => "🌐 Your IP address is: *{$data['ip']}*",
    'parse_mode' => 'Markdown'
]);

