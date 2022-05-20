// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPool.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProviderRegistry.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/pool/Pool.sol";

contract Deposit {                       //Pool implementation 0x87530ED4bd0ee0e79661D65f8Dd37538F693afD5
                                        // Pool Address provider Registry 0xF2038a65f68a94d1CFD0166f087A795341e2eac8
    IPool constant ipool = IPool(0x87530ED4bd0ee0e79661D65f8Dd37538F693afD5);  // rinkeby pool addres provi 0xBA6378f1c1D046e9EB0F538560BA7558546edF3C
    IPoolAddressesProviderRegistry public poolAddressesProviderRegistry = IPoolAddressesProviderRegistry(0xF2038a65f68a94d1CFD0166f087A795341e2eac8);

    address owner;
    uint256 private constant ADDRESSES_PROVIDER_ID = uint256(0);

    constructor () public {
        owner = msg.sender;
    }


    function depositCollateral(address asset, uint256 amount) public {
        IERC20(asset).approve(address(_pool()), amount);
        _pool().deposit(asset, amount, address(this), 0);
    }

    function withdrawCollateral(address asset, uint256 amount) public {
        _pool().withdraw(asset, amount, address(this));
    }

    function borrowCollateral(address asset, uint256 amount) public {
        IERC20(asset).approve(address(_pool()), amount);
        _pool().borrow(asset, amount, 0, 0, address(this));
    }

    function repayCollateral(address asset, uint256 amount) public {
        _pool().repay(asset, amount, 0, address(this));
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

}