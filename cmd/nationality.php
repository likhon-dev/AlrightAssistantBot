<?php
if (preg_match('/^\/nationality (.+)$/', $text, $matches)) {
    $name = urlencode($matches[1]);
    $response = file_get_contents("https://api.nationalize.io/?name={$name}");
    $data = json_decode($response, true);
    
    $result = "🌍 Nationality prediction for *{$matches[1]}*:\n\n";
    foreach ($data['country'] as $country) {
        $flag = getCountryFlag($country['country_id']);
        $probability = round($country['probability'] * 100, 2);
        $result .= "{$flag} {$country['country_id']}: {$probability}%\n";
    }
    
    $telegram->sendMessage([
        'chat_id' => $chat_id,
        'text' => $result,
        'parse_mode' => 'Markdown'
    ]);
} else {
    $telegram->sendMessage([
        'chat_id' => $chat_id,
        'text' => '⚠️ Please provide a name. Usage: /nationality John'
    ]);
}

function getCountryFlag($country_code) {
    $flag_offset = 127397;
    $unicode_flag = mb_convert_encoding('&#' . (ord($country_code[0]) + $flag_offset) . ';&#' . (ord($country_code[1]) + $flag_offset) . ';', 'UTF-8', 'HTML-ENTITIES');
    return $unicode_flag;
}

