<?php
$response = file_get_contents('https://dog.ceo/api/breeds/image/random');
$data = json_decode($response, true);

$telegram->sendPhoto([
    'chat_id' => $chat_id,
    'photo' => $data['message'],
    'caption' => '🐶 Woof! Here\'s a cute dog for you!'
]);

