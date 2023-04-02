// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import './HederaResponseCodes.sol';
import './IHederaTokenService.sol';
import './HederaTokenService.sol';
import './ExpiryHelper.sol';

contract TreasuryContract is HederaTokenService, ExpiryHelper {
    bool public bUsed;


    function createFungible(
        string memory name,
        string memory symbol,
        int64 initialSupply,
        int32 decimals
    ) external payable returns (address createdTokenAddress) {
        
        require(!bUsed, "Contract has already been used.");
        bUsed = true;

        IHederaTokenService.HederaToken memory token;
        token.name = name;
        token.symbol = symbol;
        token.treasury = address(this);
        token.expiry = createAutoRenewExpiry(address(this), 7776000);

        // create the expiry schedule for the token using ExpiryHelper
        // token.expiry = createAutoRenewExpiry(address(this), autoRenewPeriod);

        IHederaTokenService.FixedFee[] memory fixedFees = new IHederaTokenService.FixedFee[](0);

        IHederaTokenService.FractionalFee[] memory fractionalFees = new IHederaTokenService.FractionalFee[](2);
        fractionalFees[0].feeCollector = address(this);
        fractionalFees[0].numerator = 5; 
        fractionalFees[0].denominator = 100;

        fractionalFees[1].feeCollector = msg.sender;
        fractionalFees[1].numerator = 5; 
        fractionalFees[1].denominator = 100; 

        (int responseCode, address tokenAddress) =
                    HederaTokenService.createFungibleTokenWithCustomFees(token, initialSupply, decimals, fixedFees, fractionalFees);

if (responseCode != HederaResponseCodes.SUCCESS) {
    revert ("Token creation failed");
}

        createdTokenAddress = tokenAddress;
        int response = HederaTokenService.transferToken(tokenAddress, address(this), msg.sender, int64(initialSupply) );

if (response != HederaResponseCodes.SUCCESS) {
    revert ("Token transfer failed");
}

    }
}
