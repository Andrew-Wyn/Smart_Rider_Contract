pragma solidity >=0.4.0 <0.7.0;

contract RiderContract {
    
    address payable public owner;
    address payable public rider;
    uint private percentage_to_rider;
    
    uint active_orders;
    mapping(address => Order) orders;
    
    struct Order {
        uint id;
        uint amount;
        bool active;
    } 
    
    event Ordered(address caller, address rider, uint id, uint amount);
    event Delivered(address caller, address rider, uint id);
    event Dismissed(address caller, address rider, uint id, uint amount);
    
    constructor(address payable _rider, uint _percentage_to_rider) public {
        rider = _rider;
        owner = msg.sender;
        percentage_to_rider = _percentage_to_rider;
        active_orders = 0;
    }
    
    function prenotareOrdine(uint _id, uint _amount) public payable {
        require(msg.value >= _amount, "pagamento insufficiente");
        orders[msg.sender].id = _id;
        orders[msg.sender].amount = _amount;
        orders[msg.sender].active = true;
        active_orders += 1;
        
        emit Ordered(msg.sender, rider, _id, _amount);
    }
    
    function ordineArrivato() public payable {
        Order storage order_delivered = orders[msg.sender];
        require(order_delivered.active == true, "Non risulta Nessun ordine a suo favore");
        uint amount_to_rider = order_delivered.amount * percentage_to_rider / 100;
        uint amount_to_owner = order_delivered.amount - amount_to_rider;
        rider.transfer(amount_to_rider);
        owner.transfer(amount_to_owner);
        active_orders -= 1;
        orders[msg.sender].active = false;
        
        emit Delivered(msg.sender, rider, order_delivered.id);
    }

    function cancellaOrdine() public payable {
        Order storage order_dismissed = orders[msg.sender];
        require(order_dismissed.active == true, "Non risulta Nessun ordine a suo favore");
        msg.sender.transfer(order_dismissed.amount);
        active_orders -= 1;

        orders[msg.sender].active = false;

        emit Dismissed(msg.sender, rider, order_dismissed.id, order_dismissed.amount);
    }
    
    function rilascioRider() public payable {
        require(msg.sender == rider || msg.sender == owner, "per terminare il contratto devi essere il rider o l'owner");
        require(active_orders == 0, "devi ancora portare a termine degli ordini");
        
        selfdestruct(owner); // eventuali eth in eccesso vengono rilasciati all'owner
    }
}