<?php
if (preg_match('/^\/mlb (.+)$/', $text, $matches)) {
    $player = urlencode($matches[1]);
    $response = file_get_contents("http://lookup-service-prod.mlb.com/json/named.search_player_all.bam?sport_code='mlb'&active_sw='Y'&name_part='{$player}%25'");
    $data = json_decode($response, true);
    
    if ($data['search_player_all']['queryResults']['totalSize'] > 0) {
        $player_data = $data['search_player_all']['queryResults']['row'];
        $result = "⚾ *Player found:*\n\n";
        $result .= "📛 Name: {$player_data['name_display_first_last']}\n";
        $result .= "🏟️ Team: {$player_data['team_full']}\n";
        $result .= "🎯 Position: {$player_data['position']}\n";
        $result .= "🏏 Bats: {$player_data['bats']}, Throws: {$player_data['throws']}";
    } else {
        $result = "🚫 No player found with that name.";
    }
    
    $telegram->sendMessage([
        'chat_id' => $chat_id,
        'text' => $result,
        'parse_mode' => 'Markdown'
    ]);
} else {
    $telegram->sendMessage([
        'chat_id' => $chat_id,
        'text' => '⚠️ Please provide a player name. Usage: /mlb John Doe'
    ]);
}

