<?php
$help_text = "
🤖 *AlrightAssistantBot Commands*

/start - 🚀 Start the bot
/help - 📚 Show this help message
/nationality - 🌍 Predict nationality from a name
/population - 👥 Get population data
/dog - 🐶 Get a random dog image
/ip - 🌐 Get your IP address
/randomuser - 👤 Generate random user data
/mlb - ⚾ Search for MLB player data
/word - 📖 Look up word information
/whois - 🔍 WHOIS domain lookup

Feel free to ask me anything! 😊
";

$telegram->sendMessage([
    'chat_id' => $chat_id,
    'text' => $help_text,
    'parse_mode' => 'Markdown'
]);

