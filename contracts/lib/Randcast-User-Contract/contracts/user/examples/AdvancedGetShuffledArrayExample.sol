// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BasicRandcastConsumerBase} from "../BasicRandcastConsumerBase.sol";
import {RequestIdBase} from "../../utils/RequestIdBase.sol";
// solhint-disable-next-line no-global-import
import "../RandcastSDK.sol" as RandcastSDK;

contract AdvancedGetShuffledArrayExample is RequestIdBase, BasicRandcastConsumerBase {
    mapping(bytes32 => uint256) public shuffledArrayUppers;
    uint256[][] public shuffleResults;

    // solhint-disable-next-line no-empty-blocks
    constructor(address adapter) BasicRandcastConsumerBase(adapter) {}

    /**
     * Requests randomness
     */
    function getRandomNumberThenGenerateShuffledArray(
        uint256 shuffledArrayUpper,
        uint64 subId,
        uint256 seed,
        uint16 requestConfirmations,
        uint32 callbackGasLimit,
        uint256 callbackMaxGasPrice
    ) external returns (bytes32) {
        bytes memory params;

        uint256 rawSeed = _makeRandcastInputSeed(seed, subId, address(this), getNonce(subId));
        // This should be identical to controller generated requestId.
        bytes32 requestId = _makeRequestId(rawSeed);
        shuffledArrayUppers[requestId] = shuffledArrayUpper;

        return _rawRequestRandomness(
            RequestType.Randomness, params, subId, seed, requestConfirmations, callbackGasLimit, callbackMaxGasPrice
        );

        // These equals to following code(recommended):
        // bytes32 requestId = _rawRequestRandomness(
        //    RequestType.Randomness,
        //    params,
        //    subId,
        //    seed,
        //    requestConfirmations,
        //    callbackGasLimit,
        //    callbackMaxGasPrice
        // );

        // shuffledArrayUppers[requestId] = shuffledArrayUpper;
    }

    /**
     * Callback function used by Randcast Adapter
     */
    function _fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        shuffleResults.push(RandcastSDK.shuffle(shuffledArrayUppers[requestId], randomness));
    }

    function lengthOfShuffleResults() public view returns (uint256) {
        return shuffleResults.length;
    }
}
