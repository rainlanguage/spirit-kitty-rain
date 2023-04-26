// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/StdJson.sol";
import "../lib/rain.interface.interpreter/src/IExpressionDeployerV1.sol";
import "../lib/rain.interface.interpreter/src/IInterpreterV1.sol";
import "../lib/rain.interface.interpreter/src/IInterpreterStoreV1.sol";
import "../lib/rain.interface.interpreter/src/unstable/IDebugExpressionDeployerV1.sol";

contract DeployExpression is Script {
    using stdJson for address;
    using stdJson for string;

    using LibStackPointer for uint256[];
    using LibStackPointer for StackPointer;
    using LibUint256Array for uint256;
    using LibUint256Array for uint256[];
    using LibUint256Matrix for uint256[];
    using LibInterpreterState for InterpreterState;
    using LibFixedPointMath for uint256;

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
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 6;

        uint256[][] memory context_ = LibContext.build(
            callerContext_.matrixFrom(),
            signedContexts_
        );

        vm.startBroadcast(deployerPrivateKey);

        // (
        //     IInterpreterV1 interpreter,
        //     IInterpreterStoreV1 store,
        //     address expression
        // ) = expressionDeployer_.offchainDebugEval(
        //         sources,
        //         constants,
        //         FullyQualifiedNamespace.wrap(0),
        //         uint256[][] memory context,
        //         SourceIndex sourceIndex,
        //         uint256[] memory initialStack,
        //         minOutputs
        //     );

        vm.stopBroadcast();
    }
}
