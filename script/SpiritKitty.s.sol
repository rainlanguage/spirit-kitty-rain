// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/StdJson.sol";
import "../lib/rain.interface.factory/src/ICloneFactoryV1.sol";
import {FlowERC721Config, IFlowERC721V2, EvaluableConfig, IExpressionDeployerV1} from "../lib/rain.interface.flow/src/IFlowERC721V2.sol";

contract SpiritKitty is Script {
    using stdJson for address;
    using stdJson for string;

    string json;
    IFlowERC721V2 flowERC721;

    function setUp() public {
        // Read from the config file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/spiritKitty.json");
        json = vm.readFile(path);

        ICloneableFactoryV1 cloneFactory_ = ICloneableFactoryV1(
            stdJson.readAddress(json, ".cloneFactory")
        );
        IFlowERC721V2 flowERC721_ = IFlowERC721V2(
            stdJson.readAddress(json, ".flowERC721")
        );
        IExpressionDeployerV1 expressionDeployer_ = IExpressionDeployerV1(
            stdJson.readAddress(json, ".expressionDeployer")
        );

        uint256[] memory constants = stdJson.readUintArray(json, ".constants");
        bytes[] memory sources = stdJson.readBytesArray(json, ".sources");
        EvaluableConfig[] memory flows;

        FlowERC721Config memory config = FlowERC721Config(
            stdJson.readString(json, ".name"),
            stdJson.readString(json, ".symbol"),
            stdJson.readString(json, ".baseURI"),
            EvaluableConfig(expressionDeployer_, sources, constants),
            flows
        );

        flowERC721 = IFlowERC721V2(
            cloneFactory_.clone(address(flowERC721_), abi.encode(config))
        );
    }

    function run() public {
        // vm.startBroadcast();
        // vm.stopBroadcast();
    }
}
