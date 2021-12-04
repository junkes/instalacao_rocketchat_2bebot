echo "atualizar repositórios"
echo " "
apt update

echo " "
echo " "
echo "instalar pacote snapd"
echo " "
apt install -y snapd
sleep 5

echo " "
echo " "
echo "instalar rocketchat-server via snap"
echo " "
snap install rocketchat-server
sleep 10

echo " "
echo "iniciar rocketchat-server"
echo " "
snap start rocketchat-server
sleep 5

echo " "
echo "verificar status do rocketchat-server"
echo " "
snap services rocketchat-server

echo " "
echo "instalar pacote mongodb-clients"
echo " "
apt install -y mongodb-clients
sleep 5

echo " "
echo "criar banco bridge-rock-band no mongodb"
echo " "
mongo --eval "db = db.getSiblingDB('bridge-rock-band'); db.teste.insertOne({});"

echo " "
echo "listar bancos no mongodb"
echo " "
mongo --eval "db.adminCommand('listDatabases');"