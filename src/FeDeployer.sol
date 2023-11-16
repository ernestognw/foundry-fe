// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13 <0.9.0;

import {FeConfig} from "./FeConfig.sol";

library FeDeployer {
    function config() public returns (FeConfig) {
        return new FeConfig();
    }

    function deploy(string memory file) internal returns (address) {
        return config().deploy(file);
    }

    function broadcast(string memory file) internal returns (address) {
        return config().set_broadcast(true).deploy(file);
    }

    function deploy_with_value(
        string memory file,
        uint256 value
    ) internal returns (address) {
        return config().with_value(value).deploy(file);
    }

    function broadcast_with_value(
        string memory file,
        uint256 value
    ) internal returns (address) {
        return config().set_broadcast(true).with_value(value).deploy(file);
    }

    function deploy_with_args(
        string memory file,
        bytes memory args
    ) internal returns (address) {
        return config().with_args(args).deploy(file);
    }

    function broadcast_with_args(
        string memory file,
        bytes memory args
    ) internal returns (address) {
        return config().set_broadcast(true).with_args(args).deploy(file);
    }
}
