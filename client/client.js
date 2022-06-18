// run this file with this command on command line:
// node ./arbi-protocol/client/client.js

(async function () {
  const ethers = require("ethers");
  const write_node =
    "https://twilight-icy-log.matic.quiknode.pro/6b18b0d8485309d9c66de130cdd8187124b3d0f9";
  const read_node = "https://polygon-rpc.com/";
  const { BigNumber } = require("ethers");

  // Define provider from ethers to read node
  const provider = new ethers.providers.JsonRpcProvider(read_node);

  // ABI file is needed to be able to interact via javascript with the contracts
  // this abi file is specific from this pool, you would find abis on the chain explorer(polyscan)
  // contract tab scroll down to abi, make a new file following the order on this directory ./abi/protocol/poolnameAbi.json
  // adn paste the ABI code, each abi is specific to each contract
  const wBTCwETH = require("./abis/pools/balancer/wBTCwETH");

  const fromWei = (amount) => ethers.utils.parseUnits(amount, "wei");

  // pool address
  const wBTCwETH_address = "0xCF354603A9AEbD2Ff9f33E1B04246d8Ea204ae95";

  // this is how you create the contract instance
  const wBTCwETH_pool = new ethers.Contract(
    wBTCwETH_address,
    wBTCwETH,
    provider
  );

  // Take a look at polyscan to know the methods available or console log the contract methods as follows:
  // console.log("ALL METHODS",wBTCwETH_pool); // this will print the methods delete the // to uncomment
  // or check methods here : https://polygonscan.com/address/0xCF354603A9AEbD2Ff9f33E1B04246d8Ea204ae95#readContract

  // get PoolId (we will use it to query pool stats from vaults/pools contract)
  // here : https://github.com/balancer-labs/balancer-v2-monorepo/blob/weighted-deployment/contracts/vault/PoolTokens.sol#L85
  const wBTCwETH_ppolId = await wBTCwETH_pool.getPoolId();
  console.log("wBTCwETH_ppolId: ", wBTCwETH_ppolId.toString());

  // // get reserves (weights of each token % on the pool)
  const wBTCwETH_reserves = await wBTCwETH_pool.getNormalizedWeights();
  const wBTHC_reserves = wBTCwETH_reserves.toString().split(",")[0];
  const wETH_reserves = wBTCwETH_reserves.toString().split(",")[1];
  console.log(
    "wBTCwETH_reserves: ",
    fromWei(wBTHC_reserves.toString()).toString()
  );
  console.log("wETH_reserves: ", fromWei(wETH_reserves.toString()).toString());

  // // get total supply
  const wBTCwETH_totalSupply = await wBTCwETH_pool.totalSupply();
  console.log(
    "wBTCwETH_totalSupply: ",
    fromWei(wBTCwETH_totalSupply.toString()).toString()
  );
})();
