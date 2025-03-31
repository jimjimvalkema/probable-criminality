# probable-criminality
just some  notes for me and joss :)


## benchmark circuit example
```shell
nargo compile; nargo info > pedersen_test.info; bb gates -b ./target/pedersen_test.json > pedersen_test.gates
```


## [install aztec](https://docs.aztec.network/developers/getting_started)
### [install docker ubuntu]( https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) (not docker desktop it sucks):
follow tutorial here: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
  
<!-- #### Add to ur apt repo:    
```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```  
    
#### install it:   
```shell
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
``` -->
   
#### [Add ur self to the docker group](https://docs.docker.com/engine/install/linux-postinstall/) (other wise you get `error: docker not running`)  
```shell
sudo groupadd docker;
sudo usermod -aG docker $USER;
source ~/.bashrc;
```
if it still is broken try: https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue


### [install aztec sand box](https://docs.aztec.network/developers/getting_started#install-the-sandbox):  
#### install  
`bash -i <(curl -s https://install.aztec.network)`    
  
#### start:   
`aztec start --sandbox`


## [make new contract](https://docs.aztec.network/developers/tutorials/codealong/contract_tutorials/counter_contract)
Its just a noir and aztec is a library! And type is now `type = "contract"`



note there is a bug where docker makes all new files owned by root
just do `sudo chown -R $USER:docker *` every time aztec makes files
```shell
aztec-nargo new --contract counter

```


compile counter  
```shell
cd aztec-private-counter/contracts/counter;
aztec-nargo compile;
sudo chown -R $USER:docker *;
```

make typescript types
```shell
cd aztec-private-counter/contracts/counter;
aztec codegen -o src/artifacts target;
sudo chown -R $USER:docker *;
```

deploy (i used bun because i still don't know how to use typescript with node lmao)
```shell
bun run  scripts/deployCounter
```

`VERSION=0.82.2 aztec start --sandbox`