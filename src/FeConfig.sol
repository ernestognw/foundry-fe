// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "forge-std/Vm.sol";

contract FeConfig {
    Vm public constant vm =
        Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    bytes public args;
    uint256 public value;
    bool public should_broadcast;

    function build(string memory file) public {
        string[] memory command = new string[](3);
        command[0] = "fe build";
        command[1] = file;
        command[2] = "--overwrite";
        bytes memory retData = vm.ffi(command);

        if (string(retData).toSlice().startsWith("Compiled".toSlice())) {
            return;
        }

        revert(string.concat("Build failed: ", string(retData)));
    }

    function deploy(
        string memory file,
        string memory contractName
    ) public returns (address) {
        bytes memory concatenated = creation_code_with_args(file, contractName);

        address deployedAddress;
        if (should_broadcast) vm.broadcast();
        assembly {
            let val := sload(value.slot)
            deployedAddress := create(
                val,
                add(concatenated, 0x20),
                mload(concatenated)
            )
        }

        require(
            deployedAddress != address(0),
            "FeDeployer could not deploy contract"
        );

        return deployedAddress;
    }

    function with_value(uint256 value_) public returns (FeConfig) {
        value = value_;
        return this;
    }

    function with_args(uint256 args_) public returns (FeConfig) {
        args = args_;
        return this;
    }

    function set_broadcast(bool broadcast) public returns (HuffConfig) {
        should_broadcast = broadcast;
        return this;
    }

    function creation_code_with_args(
        string memory file,
        string memory contractName
    ) public payable returns (bytes memory bytecode) {
        bytecode = creation_code(file, contractName);
        return bytes.concat(bytecode, args);
    }

    function creation_code(
        string memory file,
        string memory contractName
    ) public payable returns (bytes memory bytecode) {
        build(file);

        string[] memory command = new string[](3);
        command[0] = "cat output/";
        command[1] = contractName;
        command[2] = "/";
        command[3] = contractName;
        command[4] = ".bin";
        bytecode = vm.ffi(command);

        if (bytecode.length != 0) return bytecode;

        revert(
            string.concat("Could not find bytecode for ", name, " contract")
        );
    }
}
