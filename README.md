# Spirit Kitty x Rain

## Usage

It is recommended to use VS Code for the best Rain tooling support.

Clone this repo and open in [Dev Container](https://code.visualstudio.com/docs/devcontainers/containers).

Then, install submodules with `forge install`

### Local Deploy and Testing

See [foundry docs](https://book.getfoundry.sh/tutorials/solidity-scripting#deploying-locally)

```
forge script script/SpiritKitty.s.sol:SpiritKitty --fork-url http://127.0.0.1:8545 --broadcast
```