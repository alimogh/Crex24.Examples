# Crex24.Examples

Examples of usage BotTrade API with authentication via HMACSHA512 signature.



#### build and run js example

You need only node.js (8 LTS for example)

Go into js folder and execute commands: 
1.  npm install
2.  node app.js

Don't forget to set api keys!

#### run python example

You need only python 3

Go into python folder and execute commands: 
1. python app.py

Don't forget to set api keys!


If you get error **"ModuleNotFoundError: No module named 'requests'** please install module **requests** via pip: 

**pip install requests** (linux with sudo)

#### run php example

Works with php version 7.1

Go into php folder and execute commands: 
1. php -f app.php

Don't forget to set api keys!

#### run perl example

If necessary, install additional perl modules. This can be done with the cpan command:<br>
cpan -i Digest::SHA MIME::Base64 LWP::UserAgent JSON Data::Dumper

1. Go to the perl folder and edit the api keys in the app.pl and app_API_V2_beta.pl files.
2. `perl app.pl` or `perl app_API_V2_beta.pl`
