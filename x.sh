#!/bin/bash

# Create necessary directories
mkdir -p bot/cmd

# Create main bot file
cat > bot/bot.php << EOL
<?php
require 'vendor/autoload.php';

use Telegram\Bot\Api;
use Telegram\Bot\Keyboard\Keyboard;

\$telegram = new Api('8041464661:AAHJenRmBlSonPWj1RWA1ZV-3lJak8L2Wkk');

\$update = \$telegram->getWebhookUpdate();

if (isset(\$update['inline_query'])) {
    handleInlineQuery(\$update['inline_query']);
} elseif (isset(\$update['message'])) {
    handleMessage(\$update['message']);
}

function handleInlineQuery(\$inlineQuery) {
    global \$telegram;
    
    \$query = \$inlineQuery['query'];
    \$results = [];
    
    if (!empty(\$query)) {
        \$results[] = [
            'type' => 'article',
            'id' => '1',
            'title' => "Search for: {\$query}",
            'description' => "Perform a search for {\$query}",
            'input_message_content' => [
                'message_text' => "🔍 Searching for: {\$query}"
            ]
        ];
    }
    
    \$telegram->answerInlineQuery([
        'inline_query_id' => \$inlineQuery['id'],
        'results' => json_encode(\$results),
        'cache_time' => 300,
    ]);
}

function handleMessage(\$message) {
    global \$telegram;
    
    \$chat_id = \$message['chat']['id'];
    \$text = \$message['text'] ?? '';
    
    // Check if user is a member of the required channel
    \$chat_member = \$telegram->getChatMember([
        'chat_id' => '@LikhonScripts',
        'user_id' => \$message['from']['id']
    ]);
    
    if (\$chat_member->getStatus() == 'left') {
        \$telegram->sendMessage([
            'chat_id' => \$chat_id,
            'text' => '🚫 Please join @LikhonScripts to use this bot.'
        ]);
        return;
    }
    
    if (strpos(\$text, '/') === 0) {
        \$command = substr(\$text, 1);
        \$command_file = __DIR__ . "/cmd/{\$command}.php";
        
        if (file_exists(\$command_file)) {
            include \$command_file;
        } else {
            \$telegram->sendMessage([
                'chat_id' => \$chat_id,
                'text' => '❓ Unknown command. Please try /help for available commands.'
            ]);
        }
    } else {
        \$telegram->sendMessage([
            'chat_id' => \$chat_id,
            'text' => "👋 Welcome! I'm AlrightAssistantBot. Use /help to see what I can do!"
        ]);
    }
}
EOL

# Create command files
echo "<?php
\$keyboard = new Keyboard();
\$keyboard->inline();
\$keyboard->row(Keyboard::inlineButton(['text' => '📚 Help', 'callback_data' => 'help']));

\$telegram->sendMessage([
    'chat_id' => \$chat_id,
    'text' => '🎉 Welcome to AlrightAssistantBot! I\'m here to help you with various tasks. Use /help to see available commands.',
    'reply_markup' => \$keyboard
]);
" > bot/cmd/start.php

echo "<?php
\$help_text = \"
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
\";

\$telegram->sendMessage([
    'chat_id' => \$chat_id,
    'text' => \$help_text,
    'parse_mode' => 'Markdown'
]);
" > bot/cmd/help.php

echo "<?php
if (preg_match('/^\/nationality (.+)$/', \$text, \$matches)) {
    \$name = urlencode(\$matches[1]);
    \$response = file_get_contents(\"https://api.nationalize.io/?name={\$name}\");
    \$data = json_decode(\$response, true);
    
    \$result = \"🌍 Nationality prediction for *{\$matches[1]}*:\n\n\";
    foreach (\$data['country'] as \$country) {
        \$flag = getCountryFlag(\$country['country_id']);
        \$probability = round(\$country['probability'] * 100, 2);
        \$result .= \"{\$flag} {\$country['country_id']}: {\$probability}%\n\";
    }
    
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => \$result,
        'parse_mode' => 'Markdown'
    ]);
} else {
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => '⚠️ Please provide a name. Usage: /nationality John'
    ]);
}

function getCountryFlag(\$country_code) {
    \$flag_offset = 127397;
    \$unicode_flag = mb_convert_encoding('&#' . (ord(\$country_code[0]) + \$flag_offset) . ';&#' . (ord(\$country_code[1]) + \$flag_offset) . ';', 'UTF-8', 'HTML-ENTITIES');
    return \$unicode_flag;
}
" > bot/cmd/nationality.php

echo "<?php
\$response = file_get_contents('https://datausa.io/api/data?drilldowns=Nation&measures=Population&year=latest');
\$data = json_decode(\$response, true);

\$population = number_format(\$data['data'][0]['Population']);
\$year = \$data['data'][0]['Year'];

\$telegram->sendMessage([
    'chat_id' => \$chat_id,
    'text' => \"👥 US Population ({\$year}): *{\$population}*\",
    'parse_mode' => 'Markdown'
]);
" > bot/cmd/population.php

echo "<?php
\$response = file_get_contents('https://dog.ceo/api/breeds/image/random');
\$data = json_decode(\$response, true);

\$telegram->sendPhoto([
    'chat_id' => \$chat_id,
    'photo' => \$data['message'],
    'caption' => '🐶 Woof! Here\'s a cute dog for you!'
]);
" > bot/cmd/dog.php

echo "<?php
\$response = file_get_contents('https://api.ipify.org?format=json');
\$data = json_decode(\$response, true);

\$telegram->sendMessage([
    'chat_id' => \$chat_id,
    'text' => \"🌐 Your IP address is: *{\$data['ip']}*\",
    'parse_mode' => 'Markdown'
]);
" > bot/cmd/ip.php

echo "<?php
\$response = file_get_contents('https://randomuser.me/api/');
\$data = json_decode(\$response, true);
\$user = \$data['results'][0];

\$result = \"👤 *Random User Generated:*\n\n\";
\$result .= \"📛 Name: {\$user['name']['first']} {\$user['name']['last']}\n\";
\$result .= \"📧 Email: {\$user['email']}\n\";
\$result .= \"☎️ Phone: {\$user['phone']}\n\";
\$result .= \"📍 Location: {\$user['location']['city']}, {\$user['location']['country']}\";

\$telegram->sendMessage([
    'chat_id' => \$chat_id,
    'text' => \$result,
    'parse_mode' => 'Markdown'
]);
" > bot/cmd/randomuser.php

echo "<?php
if (preg_match('/^\/mlb (.+)$/', \$text, \$matches)) {
    \$player = urlencode(\$matches[1]);
    \$response = file_get_contents(\"http://lookup-service-prod.mlb.com/json/named.search_player_all.bam?sport_code='mlb'&active_sw='Y'&name_part='{\$player}%25'\");
    \$data = json_decode(\$response, true);
    
    if (\$data['search_player_all']['queryResults']['totalSize'] > 0) {
        \$player_data = \$data['search_player_all']['queryResults']['row'];
        \$result = \"⚾ *Player found:*\n\n\";
        \$result .= \"📛 Name: {\$player_data['name_display_first_last']}\n\";
        \$result .= \"🏟️ Team: {\$player_data['team_full']}\n\";
        \$result .= \"🎯 Position: {\$player_data['position']}\n\";
        \$result .= \"🏏 Bats: {\$player_data['bats']}, Throws: {\$player_data['throws']}\";
    } else {
        \$result = \"🚫 No player found with that name.\";
    }
    
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => \$result,
        'parse_mode' => 'Markdown'
    ]);
} else {
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => '⚠️ Please provide a player name. Usage: /mlb John Doe'
    ]);
}
" > bot/cmd/mlb.php

echo "<?php
if (preg_match('/^\/word (.+)$/', \$text, \$matches)) {
    \$word = urlencode(\$matches[1]);
    \$response = file_get_contents(\"https://wordsapiv1.p.mashape.com/words/{\$word}\");
    \$data = json_decode(\$response, true);
    
    if (isset(\$data['results'])) {
        \$result = \"📖 Word information for '*{\$matches[1]}*':\n\n\";
        foreach (\$data['results'] as \$index => \$info) {
            \$result .= \"*Definition " . (\$index + 1) . ":* {\$info['definition']}\n\";
            \$result .= \"*Part of Speech:* {\$info['partOfSpeech']}\n\n\";
        }
    } else {
        \$result = \"🚫 No information found for the word '*{\$matches[1]}*'.\";
    }
    
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => \$result,
        'parse_mode' => 'Markdown'
    ]);
} else {
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => '⚠️ Please provide a word. Usage: /word example'
    ]);
}
" > bot/cmd/word.php

echo "<?php
if (preg_match('/^\/whois (.+)$/', \$text, \$matches)) {
    \$domain = urlencode(\$matches[1]);
    \$curl = curl_init();
    
    curl_setopt_array(\$curl, [
        CURLOPT_URL => \"https://whoisjson.com/api/v1/whois?domain={\$domain}\",
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            \"Authorization: Token=YOUR_WHOISJSON_API_KEY\"
        ],
    ]);
    
    \$response = curl_exec(\$curl);
    \$err = curl_error(\$curl);
    
    curl_close(\$curl);
    
    if (\$err) {
        \$result = \"❌ Error fetching WHOIS information.\";
    } else {
        \$data = json_decode(\$response, true);
        \$result = \"🔍 *WHOIS information for {\$matches[1]}:*\n\n\";
        \$result .= \"🏢 Registrar: {\$data['registrar_name']}\n\";
        \$result .= \"📅 Creation Date: {\$data['creation_date']}\n\";
        \$result .= \"⏰ Expiration Date: {\$data['expiration_date']}\n\";
        \$result .= \"🖥️ Name Servers: \" . implode(\", \", \$data['name_servers']);
    }
    
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => \$result,
        'parse_mode' => 'Markdown'
    ]);
} else {
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => '⚠️ Please provide a domain name. Usage: /whois example.com'
    ]);
}
" > bot/cmd/whois.php

# Fix the error in word.php creation
cat > bot/cmd/word.php << 'EOL'
<?php
if (preg_match('/^\/word (.+)$/', \$text, \$matches)) {
    \$word = urlencode(\$matches[1]);
    \$response = file_get_contents("https://wordsapiv1.p.mashape.com/words/{\$word}");
    \$data = json_decode(\$response, true);
    
    if (isset(\$data['results'])) {
        \$result = "📖 Word information for '*{\$matches[1]}*':\n\n";
        foreach (\$data['results'] as \$index => \$info) {
            \$result .= "*Definition " . (\$index + 1) . ":* {\$info['definition']}\n";
            \$result .= "*Part of Speech:* {\$info['partOfSpeech']}\n\n";
        }
    } else {
        \$result = "🚫 No information found for the word '*{\$matches[1]}*'.";
    }
    
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => \$result,
        'parse_mode' => 'Markdown'
    ]);
} else {
    \$telegram->sendMessage([
        'chat_id' => \$chat_id,
        'text' => '⚠️ Please provide a word. Usage: /word example'
    ]);
}
EOL
# Create a README file
cat > bot/README.md << EOL
# AlrightAssistantBot 🤖

Welcome to AlrightAssistantBot, your friendly Telegram assistant! This bot can help you with various tasks, from predicting nationalities to fetching random dog images.

## Features

- 🌍 Predict nationality from a name
- 👥 Get US population data
- 🐶 Fetch random dog images
- 🌐 Get your IP address
- 👤 Generate random user data
- ⚾ Search for MLB player data
- 📖 Look up word information
- 🔍 WHOIS domain lookup

## Setup

1. Install PHP and required extensions.
2. Install Composer and run \`composer require irazasyed/telegram-bot-sdk\`.
3. Replace \`YOUR_WHOISJSON_API_KEY\` in \`cmd/whois.php\` with your actual API key.
4. Set up a webhook for your bot to receive updates.

## Usage

Start a chat with @AlrightAssistantBot on Telegram and use the available commands!

For more information, use the /help command in the bot chat.

Enjoy

echo "Bot setup complete. Remember to replace 'YOUR_BOT_TOKEN' and 'YOUR_WHOISJSON_API_KEY' with your actual API keys."