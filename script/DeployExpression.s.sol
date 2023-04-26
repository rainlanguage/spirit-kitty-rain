// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/StdJson.sol";
import "../lib/rain.interface.interpreter/src/IExpressionDeployerV1.sol";
import "../lib/rain.interface.interpreter/src/IInterpreterV1.sol";
import "../lib/rain.interface.interpreter/src/IInterpreterStoreV1.sol";
import "../lib/rain.interface.interpreter/src/unstable/IDebugExpressionDeployerV1.sol";
import "../lib/sol.lib.memory/src/LibUint256Array.sol";
import "../lib/sol.lib.memory/src/LibUint256Matrix.sol";
import "../lib/rain.interface.interpreter/src/LibContext.sol";

contract DeployExpression is Script {
    using stdJson for address;
    using stdJson for string;

    using LibUint256Array for uint256;
    using LibUint256Array for uint256[];
    using LibUint256Matrix for uint256[];

    string json;

    function setUp() public {
        // Read from the config file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/config.json");
        json = vm.readFile(path);
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        IDebugExpressionDeployerV1 expressionDeployer_ = IDebugExpressionDeployerV1(
                stdJson.readAddress(json, ".expressionDeployer")
            );

        uint256[] memory constants = stdJson.readUintArray(
            json,
            ".flows.flow_approve.constants"
        );
        bytes[] memory sources = stdJson.readBytesArray(
            json,
            ".flows.flow_approve.sources"
        );
        // uint256[] memory minOutputs = new uint256[](1);
        // minOutputs[0] = 6;
        uint256 minOutputs = 6;

        uint256[] memory callerContext_ = LibUint256Array.arrayFrom(0x0123);
        SignedContextV1[] memory signedContexts_ = new SignedContextV1[](0);

        uint256[][] memory context_ = LibContext.build(
            callerContext_.matrixFrom(),
            signedContexts_
        );

        uint256[] memory initialStack = new uint256[](0);

        vm.startBroadcast(deployerPrivateKey);

        (
            uint256[] memory finalStack,
            uint256[] memory kvs
        ) = expressionDeployer_.offchainDebugEval(
                sources,
                constants,
                FullyQualifiedNamespace.wrap(0),
                context_,
                SourceIndex.wrap(0),
                initialStack,
                minOutputs
            );

        vm.stopBroadcast();
    }
}
