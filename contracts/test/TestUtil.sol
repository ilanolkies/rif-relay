// SPDX-License-Identifier:MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "../interfaces/GsnTypes.sol";
import "../utils/GsnEip712Library.sol";
import "../utils/GsnUtils.sol";

contract TestUtil {


     bytes32 public constant RELAY_REQUEST_TYPEHASH = keccak256("RelayRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data,address tokenContract,uint256 tokenAmount,address recoverer,uint256 index,RelayData relayData)RelayData(uint256 gasPrice,bytes32 domainSeparator,bool isSmartWalletDeploy,address relayWorker,address callForwarder,address callVerifier)");

    /* function libRelayRequestName() public pure returns (string memory) {
        return "RelayRequest";
    } */

   /* function libRelayRequestType() public pure returns (string memory) {
        return "RelayRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data,address tokenContract,uint256 tokenAmount,address factory,address recoverer,uint256 index,RelayData relayData)RelayData(uint256 gasPrice,uint256 pctRelayFee,uint256 baseRelayFee,address relayWorker,address verifier,address forwarder,bytes verifierData,uint256 clientId)";
    }*/

   /* function libRelayRequestTypeHash() public pure returns (bytes32) {
        return GsnEip712Library.RELAY_REQUEST_TYPEHASH;
    } */

   /* function libRelayRequestSuffix() public pure returns (string memory) {
        return "RelayData relayData)RelayData(uint256 gasPrice,uint256 pctRelayFee,uint256 baseRelayFee,address relayWorker,address verifier,address forwarder,bytes verifierData,uint256 clientId)";
    }*/

    //helpers for test to call the library funcs:
    function callForwarderVerify(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature
    )
    external
    view {

            //(bool callSuccess,) = 
           relayRequest.relayData.callForwarder.staticcall(
            abi.encodeWithSelector(
                IForwarder.verify.selector,
                relayRequest.request,
                relayRequest.relayData.domainSeparator,
                RELAY_REQUEST_TYPEHASH,
                GsnEip712Library.hashRelayData(relayRequest.relayData),
                signature
            )
        );
    }

    function callForwarderVerifyAndCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature
    )
    external
    returns (
        bool success,
        bytes memory ret
    ) {
        bool forwarderSuccess;
        uint256 lastSuccTx;

        (forwarderSuccess, lastSuccTx, ret) = GsnEip712Library.execute(relayRequest, signature);
        
        if ( !forwarderSuccess) {
            GsnUtils.revertWithData(ret);
        }
        
        success = lastSuccTx == 0?true:false;
        emit Called(success, success == false ? ret : bytes(""));
    }

    event Called(bool success, bytes error);


    function splitRequest(
        GsnTypes.RelayRequest calldata req
    )
    external
    pure
    returns (
        IForwarder.ForwardRequest memory forwardRequest,
        bytes32 typeHash,
        bytes32 suffixData
    ) {
        forwardRequest = IForwarder.ForwardRequest(
            req.request.from,
            req.request.to,
            req.request.value,
            req.request.gas,
            req.request.nonce,
            req.request.data,
            req.request.tokenContract,
            req.request.tokenAmount,
            req.request.recoverer,
            req.request.index
        );
        suffixData = GsnEip712Library.hashRelayData(req.relayData);
        typeHash = RELAY_REQUEST_TYPEHASH;
    }


    /* function libDomainSeparator(address forwarder) public pure returns (bytes32) {
        return GsnEip712Library.domainSeparator(forwarder);
    } */



    function libGetChainID() public pure returns (uint256 id) {
        /* solhint-disable no-inline-assembly */
        assembly {
            id := chainid()
        }
    }

    /* function libEncodedDomain(address forwarder) public pure returns (bytes memory) {
        GsnEip712Library.EIP712Domain memory req = GsnEip712Library.EIP712Domain({
            name : "RSK Enveloping Transaction",
            version : "2",
            chainId : libGetChainID(),
            verifyingContract : forwarder
        });
        return abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), // EIP712DOMAIN_TYPEHASH
                keccak256(bytes(req.name)),
                keccak256(bytes(req.version)),
                req.chainId,
                req.verifyingContract
        );
    } */

    /* function libEncodedData(GsnTypes.RelayData memory req) public pure returns (bytes memory) {
        return abi.encode(
                keccak256("RelayData(uint256 gasPrice,uint256 pctRelayFee,uint256 baseRelayFee,address relayWorker,address verifier,address forwarder,bytes verifierData,uint256 clientId)"), // RELAYDATA_TYPEHASH
                req.gasPrice,
                req.pctRelayFee,
                req.baseRelayFee,
                req.relayWorker,
                req.verifier,
                req.forwarder,
                keccak256(req.verifierData),
                req.clientId
        );
    } */

   /* function libEncodedRequest(
            IForwarder.ForwardRequest memory req, 
            bytes32 requestTypeHash,
            bytes32 suffixData) public pure returns (bytes memory) {
                
        return abi.encodePacked(
            requestTypeHash,
            abi.encode(
                req.from,
                req.to,
                req.value,
                req.gas,
                req.nonce,
                keccak256(req.data)
            ),
            suffixData
        );
    } */
}
