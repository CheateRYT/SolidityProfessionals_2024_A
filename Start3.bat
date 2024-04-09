start /B geth --http --http.addr "127.0.0.1" --http.port 8545 --datadir C:\Users\wsr\Desktop\2024_A3 --http.api "web3,eth,admin,personal,miner,net" --networkid 1337 --http.corsdomain "*" --allow-insecure-unlock --rpc.enabledeprecatedpersonal console

echo personal.unlockAccount(eth.accounts[0],"1",0) | geth attach "http://127.0.0.1:8545"
echo personal.unlockAccount(eth.accounts[1],"1",0) | geth attach "http://127.0.0.1:8545"
echo personal.unlockAccount(eth.accounts[2],"1",0) | geth attach "http://127.0.0.1:8545"
echo personal.unlockAccount(eth.accounts[3],"1",0) | geth attach "http://127.0.0.1:8545"
echo miner.setEtherbase(eth.accounts[0]) | geth attach "http://127.0.0.1:8545"
echo miner.start(1) | geth attach "http://127.0.0.1:8545"

cd C:\Users\wsr\Desktop\2024_A3\interface
live-server