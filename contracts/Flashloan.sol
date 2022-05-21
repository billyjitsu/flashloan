// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//
// need the Aave loan library


import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

//Aave Deposit /Withdraw pools
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProviderRegistry.sol";

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
  IPool constant ipool = IPool(0x87530ED4bd0ee0e79661D65f8Dd37538F693afD5);  // rinkeby pool addres provi 0xBA6378f1c1D046e9EB0F538560BA7558546edF3C
  IPoolAddressesProviderRegistry public poolAddressesProviderRegistry = IPoolAddressesProviderRegistry(0xF2038a65f68a94d1CFD0166f087A795341e2eac8);
  uint256 private constant ADDRESSES_PROVIDER_ID = uint256(0);
 // --

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
    depositCollateral(assets[0], amounts[0]);

    uint256 USDCAmount = 500000;
    uint256 DAIAmount = 1000000000000000000;
    //aave function to borrow new asset
    //borrowCollateral(WETH, USDCAmount);
    //repayCollateral(WETH, USDCAmount);
    //try reverse
    borrowCollateral(DAI, DAIAmount);
    depositCollateral(DAI, DAIAmount);
    borrowCollateral(WETH, USDCAmount);
    

   // withdrawCollateral(assets[0], amounts[0]);

    //UNISWAP STUFF
    //swap Dai to usdc
    swapExactInputSingle(amounts[0]);
    //Swap USDC to Dai
  //  swapExactInputSingleOut(IERC20(WETH).balanceOf(address(this)));  // current error
  //  swapExactInputSingleOut(amounts[0]);

    //repay the loan:
    repayCollateral(DAI, DAIAmount);

  

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

  //Aave Functions -
   function depositCollateral(address asset, uint256 amount) public {
        IERC20(asset).approve(address(_pool()), amount);
        _pool().deposit(asset, amount, address(this), 0);
    }

    function withdrawCollateral(address asset, uint256 amount) public {
        _pool().withdraw(asset, amount, address(this));
    }

    function borrowCollateral(address asset, uint256 amount) public {
        IERC20(asset).approve(address(_pool()), amount);
        _pool().borrow(asset, amount, 2, 0, address(this)); //on single tx Interest is 2
    }

    function repayCollateral(address asset, uint256 amount) public {
        _pool().repay(asset, amount, 2, address(this));  //on single tx Interest is 2
    }

    function _poolProvider() internal view returns (IPoolAddressesProvider) {
    return
      IPoolAddressesProvider(
        poolAddressesProviderRegistry.getAddressesProvidersList()[ADDRESSES_PROVIDER_ID]
      );
  }

  /**
   * @notice Retrieves Aave Pool address.
   * @return A reference to Pool interface.
   */
  function _pool() internal view returns (IPool) {
    return IPool(_poolProvider().getPool());
  }

  //
   
}