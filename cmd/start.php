<?php
$keyboard = new Keyboard();
$keyboard->inline();
$keyboard->row(Keyboard::inlineButton(['text' => '📚 Help', 'callback_data' => 'help']));

$telegram->sendMessage([
    'chat_id' => $chat_id,
    'text' => '🎉 Welcome to AlrightAssistantBot! I\'m here to help you with various tasks. Use /help to see available commands.',
    'reply_markup' => $keyboard
]);

