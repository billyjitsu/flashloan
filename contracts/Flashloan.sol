// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Withdraw.sol";


contract FlashLoanExample is FlashLoanReceiverBase, Withdraw {
  using SafeMath for uint;
  event Log(address asset, uint val);

  constructor(IPoolAddressesProvider provider) public FlashLoanReceiverBase(provider) {}

  function createFlashLoan(address[] memory assets, uint256[] memory amounts) external {
      address receiverAddress = address(this);

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        uint256[] memory modes = new uint256[](assets.length);

        // 0 = no debt (flash), 1 = stable, 2 = variable
        for (uint256 i = 0; i < assets.length; i++) {
            modes[i] = 0;
        }

      POOL.flashLoan(
       receiverAddress,
        assets,
        amounts,
        modes,
        onBehalfOf,
        params,
        referralCode
      );
  }

   function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external returns (bool){
    // do things like arbitrage here
    // abi.decode(params) to decode params


  
    for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(POOL), amountOwing);
        }
        return true;
  }
}