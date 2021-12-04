echo "atualizar repositórios"
echo " "
apt update

echo " "
echo " "
echo "remover versões antigas do docker (se houver)"
echo " "
apt remove -y docker docker-engine docker.io containerd runc

apt autoremove -y

echo " "
echo " "
echo "instalar pacotes ca-certificates, gnupg e lsb-release"
echo " "
apt install -y ca-certificates curl gnupg lsb-release


echo " "
echo " "
echo "instalar o docker"
echo " "
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt install -y docker-ce docker-ce-cli containerd.io

echo " "
echo " "
echo "subir o container mongo"
echo " "
docker run --name db -d mongo:4.0 --smallfiles --replSet rs0 --oplogSize 128
sleep 3

echo " "
echo " "
echo "inicializar o mongodb"
echo " "
docker exec -ti db mongo --eval "printjson(rs.initiate())"

echo " "
echo " "
echo "subir o container rocket.chat"
echo " "
docker run --name rocketchat -p 3000:3000 --link db --env ROOT_URL="http://$(hostname -I | awk '{print $1}'):3000/" --env MONGO_OPLOG_URL=mongodb://db:27017/local -d rocket.chat

echo " "
echo " "
echo "criar o banco bridge-rock-band no mongodb"
echo " "
docker exec -ti db mongo --eval "db = db.getSiblingDB('bridge-rock-band'); db.teste.insertOne({});"

echo " "
echo " "
echo "listar bancos no mongodb"
echo " "
docker exec -ti db mongo --eval "db.adminCommand('listDatabases');"