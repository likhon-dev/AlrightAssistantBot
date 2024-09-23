<?php
$response = file_get_contents('https://datausa.io/api/data?drilldowns=Nation&measures=Population&year=latest');
$data = json_decode($response, true);

$population = number_format($data['data'][0]['Population']);
$year = $data['data'][0]['Year'];

$telegram->sendMessage([
    'chat_id' => $chat_id,
    'text' => "👥 US Population ({$year}): *{$population}*",
    'parse_mode' => 'Markdown'
]);

