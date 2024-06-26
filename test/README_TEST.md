# 适配router
1、安装依赖
```json
{
  "name": "zeek-contracts",
  "version": "1.0.0",
  "description": "",
  "scripts": {
    "compile": "SKIP_LOAD=true hardhat clean && SKIP_LOAD=true hardhat compile"
  },
  "devDependencies": {
    "@ethersproject/units": "5.7.0",
    "@nomicfoundation/hardhat-toolbox": "^2.0.2",
    "@nomiclabs/hardhat-ethers": "^2.2.2",
    "@nomiclabs/hardhat-etherscan": "3.1.7",
    "@nomiclabs/hardhat-waffle": "^2.0.6",
    "@typechain/ethers-v5": "10.2.0",
    "@typechain/hardhat": "6.1.5",
    "@types/chai": "4.3.4",
    "@types/mocha": "10.0.1",
    "@types/node": "16.11.11",
    "@typescript-eslint/eslint-plugin": "5.55.0",
    "@typescript-eslint/parser": "5.55.0",
    "chai": "^4.3.7",
    "dotenv": "16.0.3",
    "eslint": "8.36.0",
    "eslint-config-prettier": "8.7.0",
    "eslint-plugin-prettier": "4.2.1",
    "ethereum-waffle": "^4.0.10",
    "ethers": "^5.7.2",
    "hardhat": "^2.13.0",
    "hardhat-gas-reporter": "1.0.9",
    "prettier": "2.8.4",
    "prettier-plugin-solidity": "1.1.3",
    "solidity-docgen": "^0.6.0-beta.35",
    "ts-generator": "0.1.1",
    "ts-node": "10.9.1",
    "typechain": "8.1.1",
    "typescript": "4.9.5"
  },
  "dependencies": {
    "@openzeppelin/contracts": "5.0.0",
    "@openzeppelin/contracts-upgradeable": "5.0.0"
  }
}
```
```
npm install
```
2、初始化hardhat
```
npx hardhat
```
3、替换hardhat.config.ts
```js
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';
import '@typechain/hardhat';
import dotenv from 'dotenv';
import glob from 'glob';
import 'hardhat-gas-reporter';
import { HardhatUserConfig } from 'hardhat/types';
import path from 'path';
import 'solidity-docgen';
import './config/compile';
import { HARDHAT_CHAIN_ID } from './config/hardhat';
import { hardhatAccounts } from './config/hardhat-accounts';
import { getHardhatNetwork, getRpcNetwork, local, mumbai, sepolia } from './config/network';
dotenv.config();
const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.22',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
            details: {
              yul: true,
            },
          },
        },
      },
    ],
  },
  networks: {
    // hardhat network
    hardhat: {
      chainId: HARDHAT_CHAIN_ID,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      accounts: hardhatAccounts.map(
          ({ privateKey, balance }: { privateKey: string; balance: string }) => ({
            privateKey,
            balance,
          })
      ),
    },
    local: getHardhatNetwork(local),
    dev: getRpcNetwork(sepolia),
    beta: getRpcNetwork(mumbai),
    prod: getRpcNetwork(mumbai),
  },
  paths: {
    cache: './target/cache',
    artifacts: './target/artifacts',
  }
};

export default config;
```
4、启动compile脚本

5、测试
```
forge test --match-contract GovernanceTest --match-test testsetOfferRatiosIssueFees -vvvv --use 0.8.22

forge test --match-contract ZeekRouterTest --match-test testCannotAddRouter_addOneManyTimes -vvvv --use 0.8.22

forge test --match-contract ProfileTest --match-test testCannotReview_withWish_InitiatorNotWishOwner -vvvv --use 0.8.22

forge test  --use 0.8.22
forge test --match-contract QuoraTest --use 0.8.22
forge test --match-contract QuestionTest --use 0.8.22 --match-test testCannotOfferQuestion_Token0FeeToken0_OfferWishManyTimes -vvv
```
