set dotenv-load

all: install build

install:
    forge install

update:
    forge update

solc:
	pip3 install solc-select
	solc-select install 0.8.14
	solc-select use 0.8.14

build:
    forge build --force

test:
    forge test --force -vvv

clean:
    forge clean

gas-report:
    forge test --gas-report

flatten contract:
    forge flatten {{contract}}

slither contract:
    slither {{contract}}

format:
    prettier --write src/**/*.sol \
    && prettier --write src/*.sol \
    && prettier --write test/**/*.sol \
    && prettier --write test/*.sol \
    && prettier --write script/**/*.sol \
    && prettier --write script/*.sol

restore-submodules:
    #!/bin/sh
    set -e
    git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
        while read path_key path
        do
            url_key=$(echo $path_key | sed 's/\.path/.url/')
            url=$(git config -f .gitmodules --get "$url_key")
            git submodule add $url $path
        done

deploy-genesis:
    #!/bin/sh

    ls config.json >/dev/null 2>&1 || \
    { echo -e "Missing config.json, you can use config.example.json as an example config file." && exit 1; }








forge script "script/Battlecontract.s.sol:Deploy" \
    --rpc-url $MAINNET_RPC_NODE_URL \
    --sender $MAINNET_SENDER_ADDRESS \
    --private-key $MAINNET_KEYSTORE_PATH \
    --slow \
    --broadcast \
    --legacy \
    --with-gas-price 1000000000 \
    -vvvv



forge script "script/OlympusClash.s.sol:Deploy" \
    --rpc-url $MAINNET_RPC_NODE_URL \
    --sender $MAINNET_SENDER_ADDRESS \
    --private-key $MAINNET_KEYSTORE_PATH \
    --slow \
    --broadcast \
    --legacy \
    --with-gas-price 1000000000000 \
    -vvvv


    Add Battlecontract address via OlympusClash call

    

    Add OlympusClash address via Battlecontract call

VERIFY CONTRACT

    forge create --rpc-url $MAINNET_RPC_NODE_URL \
  --constructor-args "OlympusClash", "OLC" \
  --private-key $MAINNET_KEYSTORE_PATH \
  src/OlympusClash.sol:OlympusClash \
  --verifier blockscout \

  forge verify-contract OlympusClash \
 0xBCe0ddb6B4486dcc20a9Ae9cb200F2f407C0b1FC \
  --chain-id 7700 \
  --verifier blockscout

  forge verify-check 0xBCe0ddb6B4486dcc20a9Ae9cb200F2f407C0b1FC \
  --chain-id 7700 \
  --verifier blockscout




forge verify-contract --chain 7700 --optimizer-runs 200 --compiler-version 0.8.14 0xBCe0ddb6B4486dcc20a9Ae9cb200F2f407C0b1FC src/OlympusClash.sol:OlympusClash --show-standard-json-input > stdin.json




forge verify-contract --chain-id 7700 --optimizer-runs 200 --compiler-version 0.8.14 0xBCe0ddb6B4486dcc20a9Ae9cb200F2f407C0b1FC src/OlympusClash.sol:OlympusClash --verifier sourcify



forge flatten --output src/OlympusClash.flattened.sol  src/OlympusClash.sol



    CALL WITHOUT CHECK

       function mint_Battlecontract(address this_contract, address nft_owner) public {
        bytes4 sig = bytes4(keccak256("mint(address,address)"));
        (bool success, ) = BattleContractAddress.call(
            abi.encodeWithSelector(sig, this_contract, nft_owner)
        );
        if (!success) {
            revert TransferFailed(msg.sender);
        }