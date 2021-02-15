pragma solidity >=0.4.10 <0.7.0;

contract Escrow {
    address payable buyer;
    address payable seller;
    uint timeToExpire;
    uint timeToReturn;
    uint startTime;
    uint receivedTime;
    uint public deposit;
    string public status;
    
    
    //Buyer sets up the escrow contract and pays the deposit
    function Escrow1(address payable _seller, uint _timeToExpire,uint _timeToReturn) public payable{
        buyer = msg.sender;
        seller = _seller;
        deposit = msg.value;
        timeToExpire = _timeToExpire;
        timeToReturn = _timeToReturn;
        startTime = now;
        status = "Escrow Setup";
    }
    
    
    //seller updates item shipment information
    function itemShipped(string memory _status) external payable{
        if(msg.sender == seller){
        status = _status;
         if(!seller.send(deposit/5)){
                revert();
            }
            deposit -= deposit/5;
        }
        else
        revert();
    }
    
    
    //Buyer releases partial deposit to seller
    function itemReceived(string memory _status) external payable
    {
        if(msg.sender == buyer)
        {
            status = _status;
            receivedTime = now;
            
            selfdestruct(seller);
            seller.transfer(deposit);
        }
        else
        revert();
    }
    
    
    //Buyer releases balance deposit to seller
    /*function releaseBalanceToSeller() internal 
    {
        if(msg.sender == buyer)
        {
            //Finish the contract and send all the funds to seller
            selfdestruct(seller);
            seller.transfer(deposit);
        }
        else
        revert();
    }
    */
    
    //Buyer returns the item
    function returnItemToSeller(string memory _status) external 
    {
        if(msg.sender != buyer)
        revert();
        if(now > receivedTime + timeToReturn)
        revert();
        status = _status;
    }
    
    
    //Seller releases balance to buyer
    function releaseBalanceToBuyers() external payable
    {
        if(msg.sender != seller)
        revert();
        
        //Finish the contract and send remaining funds to Buyer
        //20% restocking penalty previously paid to Seller
        buyer.transfer((4 * deposit)/5);
        seller.transfer(deposit/5);
        selfdestruct(buyer);
        
    }
    
    
    //Buyer can withdraw the deposit if escrow is expired
    function withdraw() external payable
    {
        if(!isExpierd())
        revert();
        if(msg.sender == buyer)
        {
            //Finish the contract and send all the funds to buyer 
            buyer.transfer(deposit);
        selfdestruct(buyer); 
        }
        else 
        revert();
    }
    
    
    //Seller can cancel the contract escrow and return all the funds to buyer
    function cancel() external payable
    {
        if(msg.sender == seller)
        {
            buyer.transfer(deposit);
            selfdestruct(buyer);
        }
        else
        revert();
        
    }
    
    
    function isExpierd()public view returns (bool)
    {
       if(now > startTime + timeToExpire)
       return true;
       else
       return false;
    }
}
