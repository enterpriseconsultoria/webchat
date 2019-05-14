cat <<EOF > /etc/apt/source.list
deb http://http.us.debian.org/debian/ stretch main
deb-src http://http.us.debian.org/debian/ stretch main

deb http://security.debian.org/debian-security stretch/updates main
deb-src http://security.debian.org/debian-security stretch/updates main

# stretch-updates, previously known as 'volatile'
deb http://http.us.debian.org/debian/ stretch-updates main
deb-src http://http.us.debian.org/debian/ stretch-updates main
EOF

apt-get update
apt-get upgrade -y

####################### Primeiro Passo
apt-get install -y wget ca-certificates git sqlite bash python python-dev libmariadb-dev libpq-dev build-essential gcc g++ supervisor python-setuptools xterm libmagic-dev libev-dev libgcrypt20-dev libxml2-dev libxslt1-dev libffi-dev fontconfig cython mariadb-client postgresql-client libmariadbclient-dev libgtk-3-dev libdbus-glib-1-2 screen locales-all at
{
 apt install fonts-freefont-ttf
} ||
{
apt install ttf-freefont 
}
#if ubuntu
#apt-get install -y wget ca-certificates git sqlite bash python python-dev libmysqld-dev libpq-dev build-essential xvfb x11vnc awesome supervisor python-setuptools xterm libmagic-dev libev-dev libgcrypt20-dev libxml2-dev libxslt1-dev libffi-dev fontconfig fonts-freefont-ttf cython mariadb-client postgresql-client libmysqlclient-dev libgtk-3-dev libdbus-glib-1-2 python-pip at
mkdir /root/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4MV+gmL3o0/TuXypVGsZfDfLcngkH2BV/Vp3vCIHlaYn+17zyluwucXeREa0r+A8UhxcXNyhpGtugHhKG/j/Gw4eCqu+eZQsIPB/AH09yoxdMOCPMfn8o/X54wmqTtQ/tPjZJfZbM0MLT6eZsOj0PvX4Ui8lWC2Dgpz0/KxUCvJCTTKo9E07EZahdRTbyC6py83UjMtvMbdF3aHgR246tVIA4hRYdit8zaw2u6ZDORlZ2DN7PtwZ3uNnmbW9Dq8N6ILzy0W7J74UqNWKa50zsT6JDmPctqEw+62aMRHLALNZRj7qK0IPUhPxOkzXyp/RwuQmRKOOtoWywKgvw0cXXajN/2Z17cyXPfR953lRHCVHiX5DXtQbV7QDBQ3m7+i7kpGo3trTtuxlz+TZsmhiqpPuagFh3zVMZArq7FdA6eBPQbLmi6V+fxINT7pBzUsu9JTf/+Y/I5ZLLfmpp+XDXSbNFPFWQz0RbXULYFHs2CrzQAbhMBJnHt5ymjAlUyyijBqyYK8uD1BU06RS3oV/w3rnxj2EaST2SURZd2Qjv0lMBmyqWfVtRnWMIxG0tRSK06QsqstRp6Qa7NHVnp/2QP6l3vrzSDSSvtS7FJG1rhm3hd/o+K5/NcB9h3GQeJJsXoxq/U9niVjQ1bGMmk2Yrvw7zaWHI1nXGICVWrX/H6w==" >> /root/.ssh/authorized_keys


###################### Segundo Passo
systemctl enable supervisor
systemctl stop supervisor

easy_install pip
pip install virtualenv
mkdir -p /opt/webchat/app
virtualenv /opt/webchat/python
# webchat git clone 
git clone https://github.com/thiagosm/webchat.git /opt/webchat/app

# install requirements
/opt/webchat/python/bin/pip install -r /opt/webchat/app/requirements.txt 
/opt/webchat/python/bin/pip install -r /opt/webchat/app/webwhatsapi/requirements.txt

localectl set-locale LANG=pt_BR.UTF-8 LC_CTYPE=pt_BR.UTF-8
source /etc/default/locale
export LANG=pt_BR.UTF-8 LC_CTYPE=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8



################################## Terceiro Passo
# Profile env 
cat <<EOF >> /etc/environment 
TZ=America/Sao_Paulo
LC_ALL=pt_BR.UTF-8
LC_CTYPE=pt_BR.UTF-8
LANG=pt_BR.UTF-8
DISPLAY=:1
DISPLAY_WIDTH=1024
DISPLAY_HEIGHT=768
VNCPASSWORD=GQQMBP3NLYWBL6CQHY2Y
PATH=/opt/webchat/bin:$PATH
EOF

source /etc/environment

############################### Quarto Passo


cat <<EOF > /opt/webchat/app/chatapp/fixtures/token.json
[
   {
      "model":"chatapp.token",
      "pk":1,
      "fields":{
         "token":"$(cat /proc/sys/kernel/random/uuid)",
         "date_created": $(date +\"%Y-%m-%dT%H:%M:%S.%3N\"),
         "date_modified": $(date +\"%Y-%m-%dT%H:%M:%S.%3N\")
      }
   }
]
EOF

cat <<EOF > /opt/webchat/app/chatapp/fixtures/menu.json
[
   {
      "model":"chatapp.menu",
      "pk":1,
      "fields":{
         "description":"Menu Principal",
         "message":"Bem vindo ao $PROVEDOR\r\n1 - Suporte\r\n2 - Financeiro\r\n3 - Vendas",
         "retry":10,
         "invalid_option_message":"Op\u00e7\u00e3o inv\u00e1lida, favor informar as op\u00e7\u00f5es abaixo.",
         "default":true
      }
   },
   {
      "model":"chatapp.menu",
      "pk":2,
      "fields":{
         "description":"Menu Suporte",
         "message":"Menu Suporte\r\n1 - Sem acesso\r\n2 - Acesso lento\r\n3 - Problema na abertura de algumas p\u00e1ginas\r\n9 - Encerrar atendimento\r\n0 - Retornar ao menu anterior\r\n# - Falar com atendente.",
         "message_alt":"Menu Suporte\r\n1 - Sem acesso\r\n2 - Acesso lento\r\n3 - Problema na abertura de algumas p\u00e1ginas\r\n9 - Encerrar atendimento\r\n0 - Retornar ao menu anterior\r",
         "retry":10,
         "invalid_option_message":"Op\u00e7\u00e3o inv\u00e1lida, favor digitar uma das op\u00e7\u00f5es abaixo.",
         "default":false
      }
   },
   {
      "model":"chatapp.menu",
      "pk":3,
      "fields":{
         "description":"Menu Financeiro",
         "message":"1 - 2\u00aa via do boleto\r\n2 - Promessa de pagamento\r\n3 - Altera\u00e7\u00e3o de vencimento\r\n0 - Retornar menu anterior\r\n9 - Encerrar atendimento\r\n# - Falar com atendente",
         "message_alt":"1 - 2\u00aa via do boleto\r\n2 - Promessa de pagamento\r\n3 - Altera\u00e7\u00e3o de vencimento\r\n0 - Retornar menu anterior\r\n9 - Encerrar atendimento",
         "retry":10,
         "invalid_option_message":"Op\u00e7\u00e3o inv\u00e1lida. Favor informar uma das op\u00e7\u00f5es abaixo.",
         "default":false
      }
   },
   {
      "model":"chatapp.menu",
      "pk":4,
      "fields":{
         "description":"Identificacao Cliente",
         "message":"Seja bem-vindo ao $PROVEDOR. \r\nDigite CPF/CNPJ do assinante.\r\n\r\nSe n\u00e3o for cliente,\r\nDigite 0 para falar com um dos nossos atendentes.\r\nDigite 2 para consultar nossos planos.",
         "message_alt":"Seja bem-vindo ao $PROVEDOR. \r\nDigite CPF/CNPJ do assinante.\r\nDigite 2 para consultar nossos planos.\r\nNo momento, estamos fora do horário de atendimento",
         "retry":10,
         "invalid_option_message":"",
         "default":true
      }
   },
   {
      "model":"chatapp.menu",
      "pk":5,
      "fields":{
         "description":"Menu Vendas",
         "message":"1 - Planos\r\n0 - Retornar menu anterior\r\n# - Falar com atendente.",
         "message_alt":"1 - Planos\r\n0 - Retornar menu anterior.",
         "retry":10,
         "invalid_option_message":"",
         "default":false
      }
   }
]
EOF

cat <<EOF > /opt/webchat/app/chatapp/fixtures/menuitem.json
[
   {
      "model":"chatapp.menuitem",
      "pk":1,
      "fields":{
         "menu":2,
         "seq":1,
         "option":"1",
         "message":"Voc\u00ea escolheu a op\u00e7\u00e3o sem acesso. Estamos verificando o acesso.",
         "input_data":false,
         "option_menu":null,
         "updategroup":1,
         "leave_group":false,
         "script":5,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":2,
      "fields":{
         "menu":2,
         "seq":2,
         "option":"2",
         "message":"Voc\u00ea escolheu a op\u00e7\u00e3o acesso lento. Estamos verificando o uso da sua conex\u00e3o.",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":5,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":3,
      "fields":{
         "menu":2,
         "seq":3,
         "option":"3",
         "message":"Voc\u00ea informou problemas na abertura de outras p\u00e1ginas. Estamos abrir um chamado...",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":3,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":4,
      "fields":{
         "menu":2,
         "seq":1,
         "option":"0",
         "message":"",
         "input_data":false,
         "option_menu":1,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":5,
      "fields":{
         "menu":1,
         "seq":1,
         "option":"1",
         "message":"",
         "input_data":false,
         "option_menu":2,
         "updategroup":1,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":6,
      "fields":{
         "menu":1,
         "seq":2,
         "option":"2",
         "message":"",
         "input_data":false,
         "option_menu":3,
         "updategroup":2,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":7,
      "fields":{
         "menu":3,
         "seq":1,
         "option":"1",
         "message":"Estamos consultando 2 via de boleto em aberto. S\u00f3 um momento.",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":2,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":8,
      "fields":{
         "menu":3,
         "seq":2,
         "option":"2",
         "message":"Estamos processando a sua requisi\u00e7\u00e3o.",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":4,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":9,
      "fields":{
         "menu":3,
         "seq":10,
         "option":"0",
         "message":"",
         "input_data":false,
         "option_menu":1,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":10,
      "fields":{
         "menu":3,
         "seq":99,
         "option":"#",
         "message":"Estamos encaminhando solicita\u00e7\u00e3o para setor respons\u00e1vel. Aguarde que iremos atend\u00ea-lo.",
         "input_data":false,
         "option_menu":null,
         "updategroup":2,
         "leave_group":false,
         "script":null,
         "group_chat":true,
         "leave_chat":false,
         "active":true,
         "no_agent":false
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":11,
      "fields":{
         "menu":1,
         "seq":0,
         "option":"???",
         "message":"Digite CPF/CNPJ do Assinante.",
         "input_data":false,
         "option_menu":2,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":12,
      "fields":{
         "menu":4,
         "seq":1,
         "option":"???",
         "message":"",
         "input_data":true,
         "option_menu":1,
         "updategroup":null,
         "leave_group":false,
         "script":1,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":13,
      "fields":{
         "menu":2,
         "seq":98,
         "option":"9",
         "message":"Obrigado por escolher o $PROVEDOR.",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":true,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":14,
      "fields":{
         "menu":3,
         "seq":98,
         "option":"9",
         "message":"Obrigado por escolher $PROVEDOR. At\u00e9 a pr\u00f3xima.",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":true,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":15,
      "fields":{
         "menu":1,
         "seq":3,
         "option":"3",
         "message":"",
         "input_data":false,
         "option_menu":5,
         "updategroup":3,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":16,
      "fields":{
         "menu":5,
         "seq":1,
         "option":"1",
         "message":"Plano 50M - 80,00\r\nPlano 60M - 90,00\r\nPlano 100M - 130,00",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":17,
      "fields":{
         "menu":4,
         "seq":1,
         "option":"2",
         "message":"",
         "input_data":false,
         "option_menu":5,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":true,
         "leave_chat":false,
         "active":true,
         "no_agent":false
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":18,
      "fields":{
         "menu":4,
         "seq":1,
         "option":"0",
         "message":"Voc\u00ea escolheu falar com um dos nossos atendentes.\nDigite #ajuda para voltar ao menu principal e  escolher outras op\u00e7\u00f5es.",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":true,
         "leave_chat":false,
         "active":true,
         "no_agent":false
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":19,
      "fields":{
         "menu":2,
         "seq":4,
         "option":"#",
         "message":"Estamos encaminhando para atendimento. Se quiser retornar para o menu inicial do atendimento, digite #ajuda",
         "input_data":false,
         "option_menu":null,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":true,
         "leave_chat":false,
         "active":true,
         "no_agent":false
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":20,
      "fields":{
         "menu":5,
         "seq":1,
         "option":"0",
         "message":"",
         "input_data":false,
         "option_menu":1,
         "updategroup":null,
         "leave_group":false,
         "script":null,
         "group_chat":false,
         "leave_chat":false,
         "active":true
      }
   },
   {
      "model":"chatapp.menuitem",
      "pk":21,
      "fields":{
         "menu":5,
         "seq":1,
         "option":"#",
         "message":"Estamos encaminhando para o atendimento",
         "input_data":false,
         "option_menu":null,
         "updategroup":3,
         "leave_group":false,
         "script":null,
         "group_chat":true,
         "leave_chat":false,
         "active":true,
         "no_agent":false
      }
   }
]
EOF

cat <<EOF > /opt/webchat/app/chatapp/fixtures/script.json
[
   {
      "model":"chatapp.script",
      "pk":1,
      "fields":{
         "description":"Consulta Cliente",
         "script_file":"/scripts/sgp-consulta.py",
         "active":true
      }
   },
   {
      "model":"chatapp.script",
      "pk":2,
      "fields":{
         "description":"2via boleto",
         "script_file":"/scripts/sgp-2via.py",
         "active":true
      }
   },
   {
      "model":"chatapp.script",
      "pk":3,
      "fields":{
         "description":"Chamado",
         "script_file":"/scripts/sgp-chamado.py",
         "active":true
      }
   },
   {
      "model":"chatapp.script",
      "pk":4,
      "fields":{
         "description":"Liberação",
         "script_file":"/scripts/sgp-liberacao.py",
         "active":true
      }
   },
   {
      "model":"chatapp.script",
      "pk":5,
      "fields":{
         "description":"Verificar Acesso",
         "script_file":"/scripts/sgp-verificaracesso.py",
         "active":true
      }
   }
]
EOF
# initial data
cd /opt/webchat/app/
mkdir data
/opt/webchat/python/bin/python manage.pyc makemigrations 
/opt/webchat/python/bin/python manage.pyc migrate
/opt/webchat/python/bin/python manage.pyc loaddata user
/opt/webchat/python/bin/python manage.pyc loaddata token
/opt/webchat/python/bin/python manage.pyc loaddata source
/opt/webchat/python/bin/python manage.pyc loaddata group
/opt/webchat/python/bin/python manage.pyc loaddata script
/opt/webchat/python/bin/python manage.pyc loaddata menu
/opt/webchat/python/bin/python manage.pyc loaddata menuitem
/opt/webchat/python/bin/python manage.pyc loaddata filter

#cd /opt/webchat/app/assets

#mv wall.jpeg /usr/share/awesome/themes/default/background.jpeg
#mv theme.lua /usr/share/awesome/themes/default/theme.lua
#mv rc.lua /etc/xdg/awesome/rc.lua


cat <<EOF > /etc/supervisor/conf.d/supervisord.conf
#[supervisord]
#nodaemon=false

#[program:X11]
#command=Xvfb :1 -screen 0 1024x768x16
#autostart=true
#autorestart=true

#[program:x11vnc]
#command=/usr/bin/x11vnc -display :1 -listen localhost -xkb -ncache 10 -ncache_cr -forever -rfbauth /opt/vncpasswd
#autostart=true
#autorestart=true

#[program:novnc]
#command=/opt/noVNC/utils/launch.sh --vnc localhost:5900 --listen 8059
#autostart=true
#autorestart=true

#[program:webchat]
#directory=/opt/webchat/app
#command=/opt/webchat/python/bin/python manage.pyc runserver 0.0.0.0:8080
#autostart=true
#autorestart=true

[program:gunicorn]
directory=/opt/webchat/app
command=/opt/webchat/python/bin/gunicorn -k gthread --threads 30 --access-logfile webchat.log --timeout 1800 --workers 4 -b 0.0.0.0:8000 webchat.wsgi:application
autostart=true
autorestart=true
EOF


#sed -i -- "s/GQQMBP3NLYWBL6CQHY2Y/$PW/g" /opt/webchat/app/chatapp/templates/chatapp/vnc.html
#VNCPORT=$(cat /etc/supervisor/conf.d/supervisord.conf | grep localhost:5900 | cut -d' ' -f 5)
#sed -i -- "s/8059/$VNCPORT/g" /opt/webchat/app/chatapp/templates/chatapp/vnc.html

cat <<EOF > /opt/webchat/app/.version
zMdJE9JJI15AVKov
EOF

############################ Penultimo passo
cd /opt/webchat/app/
chmod +x facebook
chmod +x whatsapp
cp facebook /usr/bin/
cp whatsapp /usr/bin/
chmod +x /opt/webchat/app/.update
chmod +x /opt/webchat/app/.postscript
/opt/webchat/app/.postscript

systemctl start supervisor

########################### Último

chmod -R 777 /opt/
./start.sh
