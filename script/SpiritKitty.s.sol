// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/StdJson.sol";
import "../lib/rain.interface.factory/src/ICloneableV1.sol";
import {FlowERC721Config, IFlowERC721V2, EvaluableConfig, IExpressionDeployerV1} from "../lib/rain.interface.flow/src/IFlowERC721V2.sol";
import {IERC721Metadata} from "../lib/forge-std/src/interfaces/IERC721.sol";
import {ClonesUpgradeable as Clones} from "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/ClonesUpgradeable.sol";

contract SpiritKitty is Script {
    using stdJson for address;
    using stdJson for string;

    string json;
    address flow;

    function setUp() public {
        // Read from the config file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/config.json");
        json = vm.readFile(path);

        IFlowERC721V2 flowERC721Implementation_ = IFlowERC721V2(
            stdJson.readAddress(json, ".flowERC721")
        );
        IExpressionDeployerV1 expressionDeployer_ = IExpressionDeployerV1(
            stdJson.readAddress(json, ".expressionDeployer")
        );

        uint256[] memory constants = stdJson.readUintArray(json, ".constants");
        bytes[] memory sources = stdJson.readBytesArray(json, ".sources");
        EvaluableConfig[] memory flows = new EvaluableConfig[](6);

        flows[0] = EvaluableConfig(
            expressionDeployer_,
            stdJson.readBytesArray(json, ".flows.flow_approve.sources"),
            stdJson.readUintArray(json, ".flows.flow_approve.constants")
        );
        flows[1] = EvaluableConfig(
            expressionDeployer_,
            stdJson.readBytesArray(json, ".flows.flow_begin_whitelist.sources"),
            stdJson.readUintArray(json, ".flows.flow_begin_whitelist.constants")
        );
        flows[2] = EvaluableConfig(
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
        flows[3] = EvaluableConfig(
            expressionDeployer_,
            stdJson.readBytesArray(json, ".flows.flow_mint_public.sources"),
            stdJson.readUintArray(json, ".flows.flow_mint_public.constants")
        );
        flows[4] = EvaluableConfig(
            expressionDeployer_,
            stdJson.readBytesArray(
                json,
                ".flows.flow_mint_purebred_x_x.sources"
            ),
            stdJson.readUintArray(
                json,
                ".flows.flow_mint_purebred_x_x.constants"
            )
        );
        flows[5] = EvaluableConfig(
            expressionDeployer_,
            stdJson.readBytesArray(json, ".flows.flow_mint_whitelist.sources"),
            stdJson.readUintArray(json, ".flows.flow_mint_whitelist.constants")
        );

        address clone_ = Clones.clone(address(flowERC721Implementation_));

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

        flow = clone_;

        // vm.startBroadcast();
        // vm.stopBroadcast();
    }

    function run() public {
        // Same Flow contract wrapped with different interfaces
        // IFlowERC721V2 flowERC721 = IFlowERC721V2(address(flow));
        // IERC721Metadata flowERC721Metadata = IERC721Metadata(address(flow));
        // flowERC721Metadata.tokenURI(0x0102);
    }
}
