// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//
// need the Aave loan library
// ILendingPool, IProtocolDataProvider, IStableDebtToken  for interfaces

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

import "./Withdraw.sol";



contract FlashLoanExample is FlashLoanReceiverBase, Withdraw {
  using SafeMath for uint;
  event Log(address asset, uint val);

  address private constant SWAP_ROUTER =
        0xE592427A0AEce92De3Edee1F18E0157C05861564;

  //Rinkeby AAVE Stables
  address public constant DAI = 0x4aAded56bd7c69861E8654719195fCA9C670EB45; // Aave Rinkey
  address public constant WETH = 0xb18d016cDD2d9439A19f15633005A6b2cd6Aa774; // <<< REALLY USDC

  ISwapRouter public immutable swapRouter = ISwapRouter(SWAP_ROUTER);

  //Aave Interface tools
  //ILendingPool constant lendingPool = ILendingPool(address(0x9FE532197ad76c5a68961439604C037EB79681F0)); // Kovan
  //IProtocolDataProvider constant dataProvider = IProtocolDataProvider(address(0x744C1aaA95232EeF8A9994C4E0b3a89659D9AB79)); // Kovan


  uint256 public swappedAmount;

  constructor(IPoolAddressesProvider provider) public FlashLoanReceiverBase(provider) {}

  //UNISWAP SWAP FUNCTIONS

  function safeTransferWithApprove(uint256 amountIn, address routerAddress)
        internal
    {
        TransferHelper.safeApprove(DAI, routerAddress, amountIn);
    }

  // Create a 2ndary function to approve the 2nd asset - need to create a global one
  function safeTransferWithApprove2(uint256 amountIn, address routerAddress)
        internal
    {
        TransferHelper.safeApprove(WETH, routerAddress, amountIn);
    }

  function swapExactInputSingle(uint256 amountIn)
      public                  //used to be external
      returns (uint256 amountOut)
  {
      safeTransferWithApprove(amountIn, address(swapRouter));
      ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
          .ExactInputSingleParams({
              tokenIn: DAI,
              tokenOut: WETH,
              fee: 3000,
              recipient: msg.sender,
              deadline: block.timestamp,
              amountIn: amountIn,
              amountOutMinimum: 0,
              sqrtPriceLimitX96: 0
          });
      amountOut = swapRouter.exactInputSingle(params);
      swappedAmount = amountOut;
  }
/*
  // create a 2ndary function for swapping assets,  need to creat a universal function
  function swapExactInputSingleOut(uint256 amountIn)
      public                   //used to be external
      returns (uint256 amountOut)
  {
      safeTransferWithApprove2(amountIn, address(swapRouter));
      ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
          .ExactInputSingleParams({
              tokenIn: WETH,
              tokenOut: DAI,
              fee: 3000,
              recipient: msg.sender,
              deadline: block.timestamp,
              amountIn: amountIn,
              amountOutMinimum: 0,
              sqrtPriceLimitX96: 0
          });
      amountOut = swapRouter.exactInputSingle(params);
  }
  */

  

  ///////////////

  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external returns (bool){
    // do things like arbitrage here
    // abi.decode(params) to decode params
    
    //Deposit the loaned assets
    //aave function to deposit

    //aave function to borrow new asset

    //UNISWAP STUFF
    //swap Dai to usdc
    swapExactInputSingle(amounts[0]);
    //Swap USDC to Dai
  //  swapExactInputSingleOut(IERC20(WETH).balanceOf(address(this)));  // current error

  

    //
  
    for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(POOL), amountOwing);
        }
        return true;
  }

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
   
}