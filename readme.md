# WebChat

---
Verify and install Mysql Lib in linux
- `sudo apt install libmysqlclient-dev default-libmysqlclient-dev`

Create a virtualenv for webchat
- `virtualenv -p python2.7 webchat`

Active a virtualenv
- `source /path/to/virtualenv/bin/activate`

Install all dependencies 
- `pip install -r requeriments.txt`

Download and install Gecko Driver
- https://github.com/mozilla/geckodriver/releases



Run migrations
`python migrate.py migrate`

Run Server
`python migrate.py runserver`

Create a account in systeam, create a chat

Start a selenium driver
`python manage.py whatsapp`

