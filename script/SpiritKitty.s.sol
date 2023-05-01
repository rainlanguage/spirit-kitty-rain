// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/StdJson.sol";
import "../lib/forge-std/src/console.sol";
import {VmSafe} from "../lib/forge-std/src/Vm.sol";

import "../lib/rain.interface.factory/src/ICloneableV1.sol";
import {FlowERC721Config, IFlowERC721V2, EvaluableConfig, IExpressionDeployerV1, Evaluable, IInterpreterV1, IInterpreterStoreV1, SignedContextV1} from "../lib/rain.interface.flow/src/IFlowERC721V2.sol";
import {IERC721Metadata} from "../lib/forge-std/src/interfaces/IERC721.sol";
import {ClonesUpgradeable as Clones} from "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/ClonesUpgradeable.sol";

contract SpiritKitty is Script {
    using stdJson for address;
    using stdJson for string;

    error ScriptMessage(string message);

    string json;

    function setUp() public {
        // Read from the config file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/config.json");
        json = vm.readFile(path);
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        IFlowERC721V2 flowERC721Implementation_ = IFlowERC721V2(
            stdJson.readAddress(json, ".flowERC721")
        );
        IExpressionDeployerV1 expressionDeployer_ = IExpressionDeployerV1(
            stdJson.readAddress(json, ".expressionDeployer")
        );

        uint256[] memory constants = stdJson.readUintArray(
            json,
            ".entrypoints.constants"
        );
        bytes[] memory sources = stdJson.readBytesArray(
            json,
            ".entrypoints.sources"
        );
        EvaluableConfig[] memory flows = new EvaluableConfig[](1);

        // flows[0] = EvaluableConfig(
        //     expressionDeployer_,
        //     stdJson.readBytesArray(json, ".flows.flow_approve.sources"),
        //     stdJson.readUintArray(json, ".flows.flow_approve.constants")
        // );
        // flows[1] = EvaluableConfig(
        //     expressionDeployer_,
        //     stdJson.readBytesArray(json, ".flows.flow_begin_whitelist.sources"),
        //     stdJson.readUintArray(json, ".flows.flow_begin_whitelist.constants")
        // );
        flows[0] = EvaluableConfig(
            expressionDeployer_,
            stdJson.readBytesArray(
                json,
                ".flows.flow_mint_arhero_x_00.sources"
            ),
            stdJson.readUintArray(
                json,
                ".flows.flow_mint_arhero_x_00.constants"
            )
        );
        // flows[3] = EvaluableConfig(
        //     expressionDeployer_,
        //     stdJson.readBytesArray(json, ".flows.flow_mint_public.sources"),
        //     stdJson.readUintArray(json, ".flows.flow_mint_public.constants")
        // );
        // flows[4] = EvaluableConfig(
        //     expressionDeployer_,
        //     stdJson.readBytesArray(
        //         json,
        //         ".flows.flow_mint_purebred_x_x.sources"
        //     ),
        //     stdJson.readUintArray(
        //         json,
        //         ".flows.flow_mint_purebred_x_x.constants"
        //     )
        // );
        // flows[5] = EvaluableConfig(
        //     expressionDeployer_,
        //     stdJson.readBytesArray(json, ".flows.flow_mint_whitelist.sources"),
        //     stdJson.readUintArray(json, ".flows.flow_mint_whitelist.constants")
        // );

        address clone_ = Clones.clone(address(flowERC721Implementation_));

        vm.startBroadcast(deployerPrivateKey);

        vm.recordLogs();

        ICloneableV1(clone_).initialize(
            abi.encode(
                FlowERC721Config(
                    stdJson.readString(json, ".name"),
                    stdJson.readString(json, ".symbol"),
                    stdJson.readString(json, ".baseURI"),
                    EvaluableConfig(expressionDeployer_, sources, constants),
                    flows
                )
            )
        );

        VmSafe.Log[] memory entries_ = vm.getRecordedLogs();

        vm.stopBroadcast();

        address[] memory expressionAddresses_ = new address[](entries_.length);

        for (uint256 i_ = 0; i_ < entries_.length; i_++) {
            if (
                entries_[i_].topics[0] ==
                keccak256("ExpressionAddress(address,address)")
            ) {
                (, expressionAddresses_[i_]) = abi.decode(
                    entries_[i_].data,
                    (address, address)
                );
            }
        }

        address expressionAddress_ = expressionAddresses_[5];
        address expressionFlow0_ = expressionAddresses_[2];

        // Same Flow contract wrapped with different interfaces
        IFlowERC721V2 flowERC721 = IFlowERC721V2(address(clone_));
        IERC721Metadata flowERC721Metadata = IERC721Metadata(address(clone_));

        Evaluable memory evaluableFlow0_ = Evaluable(
            IInterpreterV1(stdJson.readAddress(json, ".rainterpreter")),
            IInterpreterStoreV1(
                stdJson.readAddress(json, ".rainterpreterStore")
            ),
            expressionFlow0_
        );

        uint256[] memory callerContext = new uint256[](1);
        // litter
        callerContext[0] = 3;

        SignedContextV1[] memory signedContexts = new SignedContextV1[](0);

        flowERC721.flow(evaluableFlow0_, callerContext, signedContexts);
    }
}
