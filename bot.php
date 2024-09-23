<?php
require 'vendor/autoload.php';

use Telegram\Bot\Api;
use Telegram\Bot\Keyboard\Keyboard;

$telegram = new Api('8041464661:AAHJenRmBlSonPWj1RWA1ZV-3lJak8L2Wkk');

$update = $telegram->getWebhookUpdate();

if (isset($update['inline_query'])) {
    handleInlineQuery($update['inline_query']);
} elseif (isset($update['message'])) {
    handleMessage($update['message']);
}

function handleInlineQuery($inlineQuery) {
    global $telegram;
    
    $query = $inlineQuery['query'];
    $results = [];
    
    if (!empty($query)) {
        $results[] = [
            'type' => 'article',
            'id' => '1',
            'title' => "Search for: {$query}",
            'description' => "Perform a search for {$query}",
            'input_message_content' => [
                'message_text' => "🔍 Searching for: {$query}"
            ]
        ];
    }
    
    $telegram->answerInlineQuery([
        'inline_query_id' => $inlineQuery['id'],
        'results' => json_encode($results),
        'cache_time' => 300,
    ]);
}

function handleMessage($message) {
    global $telegram;
    
    $chat_id = $message['chat']['id'];
    $text = $message['text'] ?? '';
    
    // Check if user is a member of the required channel
    $chat_member = $telegram->getChatMember([
        'chat_id' => '@LikhonScripts',
        'user_id' => $message['from']['id']
    ]);
    
    if ($chat_member->getStatus() == 'left') {
        $telegram->sendMessage([
            'chat_id' => $chat_id,
            'text' => '🚫 Please join @LikhonScripts to use this bot.'
        ]);
        return;
    }
    
    if (strpos($text, '/') === 0) {
        $command = substr($text, 1);
        $command_file = __DIR__ . "/cmd/{$command}.php";
        
        if (file_exists($command_file)) {
            include $command_file;
        } else {
            $telegram->sendMessage([
                'chat_id' => $chat_id,
                'text' => '❓ Unknown command. Please try /help for available commands.'
            ]);
        }
    } else {
        $telegram->sendMessage([
            'chat_id' => $chat_id,
            'text' => "👋 Welcome! I'm AlrightAssistantBot. Use /help to see what I can do!"
        ]);
    }
}
