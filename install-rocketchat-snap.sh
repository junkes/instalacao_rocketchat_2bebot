echo "atualizar repositórios"
echo " "
sleep 3
apt update

echo " "
echo " "
echo "instalar pacote snapd"
echo " "
sleep 3
apt install -y snapd

echo " "
echo " "
echo "instalar rocketchat-server via snap"
echo " "
sleep 3
snap install rocketchat-server

echo " "
echo "aguardar 5 segundos" # para garantir a conclusão da instalação do rocket-server
echo " "
sleep 5

echo " "
echo "iniciar rocketchat-server"
echo " "
sleep 3
snap start rocketchat-server

echo " "
echo "verificar status do rocketchat-server"
echo " "
sleep 3
snap services rocketchat-server

# echo " "
# echo "instalar mongodb-clients"
# echo " "
# sleep 3
# apt install -y mongodb-clients

echo " "
echo "criar banco bridge-rock-band no mongodb"
echo " "
sleep 3
mongo --eval "db = db.getSiblingDB('bridge-rock-band'); db.teste.insertOne({});"

echo " "
echo "listar bancos no mongodb"
echo " "
sleep 3
mongo --eval "db.adminCommand('listDatabases');"