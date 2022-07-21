const {ethers} = require("hardhat");

async function main(){
  const simpleStorageFactory = await ethers.getContractFactory("SimpleStorage");
  console.log("deploying contract...");
  const SimpleStorage = await simpleStorageFactory.deploy();
  await SimpleStorage.deployed();
  console.log(`Deployed contract to: ${SimpleStorage.address}`)
}

main()
.then(() => {
  process.exit(0);
})
.catch((error) =>{
  console.error(error);
  process.exit(1);
})