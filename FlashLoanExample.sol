// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Withdraw.sol";


contract FlashLoanExample is FlashLoanSimpleReceiverBase, Withdraw {
  using SafeMath for uint;
  event Log(address asset, uint val);

  constructor(IPoolAddressesProvider provider) public FlashLoanSimpleReceiverBase(provider) {}

  function createFlashLoan(address asset, uint amount) external {
      address reciever = address(this);
      bytes memory params = ""; // use this to pass arbitary data to executeOperation
      uint16 referralCode = 0;

      POOL.flashLoanSimple(
       reciever,
       asset,
       amount,
       params,
       referralCode
      );
  }

   function executeOperation(
    address asset,
    uint256 amount,
    uint256 premium,
    address initiator,
    bytes calldata params
  ) external returns (bool){
    // do things like arbitrage here
    // abi.decode(params) to decode params

    
    //Single Asset 
    uint amountOwing = amount.add(premium);
    IERC20(asset).approve(address(POOL), amountOwing);
    emit Log(asset, amountOwing);
    return true;
    

  /*
    for (uint i = 0; i < asset.length; i++) {
            uint amountOwing = amount[i].add(premium[i]);
            IERC20(asset[i]).approve(address(POOL), amountOwing);
        }
        return true;
        */
  }
}