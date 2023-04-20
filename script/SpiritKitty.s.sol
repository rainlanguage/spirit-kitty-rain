// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "lib/rain.interface.factory/src/ICloneFactoryV1.sol";
import {FlowERC721Config} from "lib/rain.interface.flow/src/IFlowERC721V2.sol";

contract SpiritKitty is Script {
    function setUp() public {}

    function run() public {
        // struct FlowERC721Config {
        //     string name;
        //     string symbol;
        //     string baseURI;
        //     EvaluableConfig evaluableConfig;
        //     EvaluableConfig[] flowConfig;
        // };

        // struct EvaluableConfig {
        //     IExpressionDeployerV1 deployer;
        //     bytes[] sources;
        //     uint256[] constants;
        // }

        ICloneableFactoryV1 cloneFactory_ = ICloneableFactoryV1(
            0x7e58B418bAA10e812884D4ABbE5e72593EFFE471
        );
        IFlowERC721V2 flow_ = cloneFactory_.clone(
            0xBAc970976b1e3293c640e045acA4ee83f0231A5C,
            FlowERC721Config(
                "SpiritKitty",
                "SK",
                "https://arpet.club/kitty-corner/",
                EvaluableConfig(
                    0x703A4C3Fae78A3F57894c1093Ae1D06750939D0F,
                    [],
                    []
                )
            )
        );

        // vm.broadcast();
    }
}
