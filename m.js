const { 
    Client, 
    AccountId, 
    PrivateKey, 
    ContractCreateFlow,
    ContractFunctionParameters,
    ContractExecuteTransaction,
} = require('@hashgraph/sdk');
const fs = require('fs');

const operatorId = AccountId.fromString("0.0.XXX");
const operatorKey = PrivateKey.fromString("YOUR-KEY");

const client = Client.forTestnet().setOperator(operatorId, operatorKey);

const main = async () => {

    const bytecode = fs.readFileSync("./TreasuryContract_sol_TreasuryContract.bin");

    const contractCreate = new ContractCreateFlow()
        .setGas(100000)
        .setBytecode(bytecode);
    const contractCreateTx = await contractCreate.execute(client);
    const contractCreateRx = await contractCreateTx.getReceipt(client);
    const contractId = contractCreateRx.contractId;

    console.log("Contract created with ID: " + contractId);

    // Create FT using precompile function
    const createToken = new ContractExecuteTransaction()
        .setContractId(contractId)
        .setGas(900000) // Increase if revert
        .setPayableAmount(40) // Increase if revert
        .setFunction("createFungible", 
            new ContractFunctionParameters()
            .addString("TOKENNAME1") // FT name
            .addString("TOKENSYMBOL1") // FT symbol
            .addInt64(100000000000000000) // FT initial supply
            .addInt32(6) // FT decimals
            );
    const createTokenTx = await createToken.execute(client);
    const createTokenRx = await createTokenTx.getRecord(client);
    const tokenIdSolidityAddr = createTokenRx.contractFunctionResult.getAddress(0);
    const tokenId = AccountId.fromSolidityAddress(tokenIdSolidityAddr);

    console.log("Token created with ID: " + tokenId);

}

main();