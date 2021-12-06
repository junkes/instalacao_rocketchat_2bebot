portaRocket=""
portaMongo=""
portasMongoDocker=""
mongoMsg="Acesse o mongo de dentro do docker \nExecute: docker exec -it db mongo"

echo " "
echo " "
echo "atualizar repositórios"
echo " "
apt update
echo " "
echo " "

while [ "$portaRocket" = "" ]; do
read -p "Informe a porta que será usada para expor o rocket.chat: " portaRocket
done

echo " "
echo "Rocket.chat será exposto através da porta $portaRocket"
echo " "
read -p "Informe a porta que será usada para expor o mongodb ou deixe em branco para não expor porta para ele: " portaMongo
echo " "

if [ "$portaMongo" = "" ]; then
  echo "Mongo não será exposto"
else
  echo "Mongo será exposto através da porta $portaMongo"
  portasMongoDocker="-p $portaMongo:27017"
  mongoMsg="Acesse o mongo fora do docker através da porta $portaMongo \nExecute: mongo --port $portaMongo"
  echo " "
  echo " "
  echo "instalar mongodb-clients"
  echo " "
  apt install -y mongodb-clients
fi

echo " "
echo " "
echo "remover versões antigas do docker (se houver)"
echo " "
apt remove -y docker docker-engine docker.io containerd runc

apt autoremove -y

echo " "
echo " "
echo "instalar pacotes ca-certificates, curl, gnupg e lsb-release"
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

docker run --name db $portasMongoDocker -d mongo:4.0 --smallfiles --replSet rs0 --oplogSize 128

echo " "
echo " "
echo "aguardar 5 segundos"
sleep 5

echo " "
echo " "
echo "inicializar o mongodb"
echo " "
docker exec -ti db mongo --eval "printjson(rs.initiate())"

echo " "
echo " "
echo "aguardar 5 segundos"
sleep 5

echo " "
echo " "
echo "subir o container rocket.chat"
echo " "
docker run --name rocketchat -p $portaRocket:3000 --link db --env ROOT_URL="http://$(hostname -I | awk '{print $1}'):$portaRocket/" --env MONGO_OPLOG_URL=mongodb://db:27017/local -d rocket.chat

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

echo " "
echo " "
echo "aguardar 10 segundos"
sleep 10

echo " "
echo " "
echo "acesse o rocket.chat pelo endereço http://$(hostname -I | awk '{print $1}'):$portaRocket/"

echo " "
echo $mongoMsg

echo " "
echo " "
echo "FIM"
echo " "
echo " "