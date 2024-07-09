# ERC777
[https://eips.ethereum.org/EIPS/eip-777](https://eips.ethereum.org/EIPS/eip-777)

Code:  
https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC777/ERC777.sol

## What problem it solves?

## Both contracts and regular addresses can control and reject which token they send by registering a tokensToSend hook. (Rejection is done by reverting in the hook function.)

## Both contracts and regular addresses can control and reject which token they receive by registering a tokensReceived hook. (Rejection is done by reverting in the hook function.)

## The tokensReceived hook allows to send tokens to a contract and notify it in a single transaction, unlike ERC-20 which requires a double call (approve/transferFrom) to achieve this.

## ERC777 adds "hooks", which are basically payable functions for tokens.
![](assets/47F034CB-6D3B-470B-B92E-554A75CB4AE1.png)

## It is quite expensive ,because it needed to make an additional call to the ERC-1820 registry contract.

## This fixes maany UX issues. Dapps don't require allowances and double-txs.  
  You could even use many dapps by just sending tokens, instead of needing Metamask.  
  Imagine sending Dai to compound.eth and getting cDai. Then withdraw it by sending cDai back to compound.eth.

## There's over $100,000 worth of USDC locked forever in the USDC contract.  
  People made a mistake and sent their USDC to the token contract, instead of to their recipient.  
  With ERC777, the contract could have rejected those transactions and keep people from losing money.

## ERC777 + contract wallets would remove the issue of "spam tokens", since wallets could reject unwanted tokens.

## These hooks in ERC777 open up the issue of reentrancy attacks. This isn't a new attack vector, reentrancy caused the famous DAO hack.  
  What's new is  this attack is possible with tokens. Developers assume ETH transfers are vulnerable, but token transfers are safe.

## There's multiple ways this can be fixed. The Consensys audit suggests using a Mutex. You can limit the gas allowance for the transfer function (similar to the ETH transfer function in Solidity).

## Exploiting an ERC777-token tokensToSend hook Uniswap Exchange
[https://blog.openzeppelin.com/exploiting-uniswap-from-reentrancy-to-actual-profit](https://blog.openzeppelin.com/exploiting-uniswap-from-reentrancy-to-actual-profit)


[https://eips.ethereum.org/EIPS/eip-777#erc777tokenssender-and-the-tokenstosend-hook](https://eips.ethereum.org/EIPS/eip-777#erc777tokenssender-and-the-tokenstosend-hook)


[https://github.com/OpenZeppelin/exploit-uniswap](https://github.com/OpenZeppelin/exploit-uniswap)  
  
  
Why it works  
  
By leveraging the tokensToSend hook, the attacker contract is called after receiving ETH (i.e. the exchange ETH balance has decreased) but before the token balance is modified (i.e. the exchange token balance has not decreased). As a consequence, reentering the vulnerable tokenToEthSwapInput will re-calculate the token-ETH exchage price, but this time with less ETH and same amount of tokens in reserves. Thus, the exchange will be buying the attacker tokens, paying in ETH, at a higher price than it should.

# ERC1363

## ERC-1363 is an ERC-20 token that adds extra functions which older protocols don’t need to use.

## Solves it by issues by leaving transfer and transferFrom in the ERC-20 standard completely unaltered. All of the transfer hooks are called in functions that have an explicit call in the name.

## ERC-1363 Standard Explained
https://www.rareskills.io/post/erc-1363

## To be a compliant ERC-1363 token, the code must also implement six additional functions:  
  Two versions of transferAndCall  
  Two versions of transferFromAndCall  
  Two versions of approveAndCall

## For a contract that wishes to be notified that they have received ERC-1363 tokens, they must implement IERC1363Receiver, onTransferReceived
![](assets/0603E9FE-22E7-462E-ACAE-40C8031084B8.png)

## Reference Implementation
https://github.com/vittominacori/erc1363-payable-token/tree/master

# SafeERC20

## developers can write more robust contracts that can safely interact with a wide variety of ERC20 tokens, including those with non-standard implementations.

## The ERC20 standard specifies that transfer and transferFrom functions should return a boolean value indicating success or failure. However, some tokens (like USDT on mainnet) don't return any value. This can cause transactions to revert unexpectedly when interacting with these non-compliant tokens.  
  

### 
- SafeERC20 wraps these function calls and handles both cases - tokens that return a boolean and those that don't.

## Some ERC20 implementations might return false on failure instead of reverting. This can lead to silent failures where the calling contract might not realize that the transfer failed.  
  SafeERC20 ensures that any failure (whether it's a false return or no return value) results in a revert, making failures explicit.

## Approval race conditions:  
  The standard approve function is susceptible to front-running attacks. If a user wants to change an approval from N to M, an attacker can front-run the transaction to use the N approval, and then use the M approval after it's set.  
  SafeERC20 provides safeIncreaseAllowance and safeDecreaseAllowance functions to mitigate this risk.
