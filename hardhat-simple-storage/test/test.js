const{ethers} = require("hardhat");
const{assert,expect} = require("chai");
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");

describe("SimpleStorage",function (){

  let simpleStorageFactory,SimpleStorage

  beforeEach(async function (){
    simpleStorageFactory = await ethers.getContractFactory("SimpleStorage")
    SimpleStorage = await simpleStorageFactory.deploy()
  })

  it("should have default value as 0",async function(){
    let currentValue = await SimpleStorage.retrieve();
    let expectedValue = "0";

    assert.equal(currentValue.toString(), expectedValue);
  })

  it("Should store new variable",async function(){
    await SimpleStorage.store(21);
    let currentValue = await SimpleStorage.retrieve()
    let expectedValue = "21";

    assert.equal(currentValue.toString(),expectedValue);
  })
})


