// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

// tesla tokens that are backed by tesla shares
// tesla shares will be held by the owner of this contract
// based off of which we will mint tesla tokens

contract BackedTesla is ConfirmedOwner, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    address private constant SEPOLIA_FUNCTION_ROUTER = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

    bytes32 private constant SEPOLIA_DON_ID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    string private s_mintSourceCode;

    uint64 private immutable i_subscriptionId;
    uint32 private constant GAS_LIMIT = 300_000;

    constructor(string memory mintSourceCode, uint64 subscriptionId)
        ConfirmedOwner(msg.sender)
        FunctionsClient(SEPOLIA_FUNCTION_ROUTER)
    {
        s_mintSourceCode = mintSourceCode;
        i_subscriptionId = subscriptionId;
    }
    /**
     * @notice Sends an HTTP request for character information
     * 1. See how much TSLA the owner has
     * 2. Check if enough TSLA is in the alpaca account
     * 3. Mint dTSLA
     * 4. Transfer dTSLA to the user
     *
     * @dev If you pass 0, that will act just as a way to get an updated portfolio balance
     * @param amountOfTokensToMint The amount of tokens to mint
     *
     */

    function sendMintRequest(uint256 amountOfTokensToMint) external onlyOwner returns (bytes32) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_mintSourceCode);

        bytes32 reqId = _sendRequest(req.encodeCBOR(), i_subscriptionId, GAS_LIMIT, SEPOLIA_DON_ID);

        return reqId;
    }
}
