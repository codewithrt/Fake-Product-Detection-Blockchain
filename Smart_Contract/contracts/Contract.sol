// SPDX-License-Identifier: UNLICENSED
pragma solidity  ^0.8.14;

contract Contract{
    address Owner; 
    constructor(){
       Owner = msg.sender;
    }
    modifier isOwner(){
          require(msg.sender == Owner,"Only Owner Can add Manufacturers");
        _;
    }
    
    struct Product{
        uint256 UniqueNo;
        string ProductName;
        string CompanyName;
        string ProductType;
        uint256 ProductPrice;
        address Manufacturer;
        address Seller;
        string SellerLocation;
        uint256 Status;
        uint256 Manufacttimestamp;
        uint256 Sellertimestamp;
        address Ownership;
    }
    mapping(uint256 => Product) public  ManufProd;

    mapping(address=>mapping(uint256=>address)) public  Sellers;

    mapping(uint256 => address) public Manufacturers;
    mapping(address => uint256) public SellerCount;
    uint256 public Mancount = 0;
    // uint256 SellerCount = 0;
    uint256 public ProdCount = 0;
    // For Owner
    // add Manufacturers
    function addManufacturers(address _address) public isOwner{
        Mancount = Mancount+1;
        Manufacturers[Mancount] = _address;
    } 
    // remove Manufacturers
    function deleteManufacturers(uint256 _index) public isOwner{
        address manufac = Manufacturers[_index];
         delete(Manufacturers[_index]);
         for (uint256 i = 1;i<=SellerCount[manufac];i++){
             delete(Sellers[manufac][i]);
         }
         for (uint256 i = 1;i<=Mancount;i++){
             Product memory prod = ManufProd[i];
             if (prod.Manufacturer == manufac) {
                 delete(ManufProd[i]);
             }
         }
         setmap();
         setmapsel(manufac);
         setprod();
    }
    // set all the mapping in a line
    function setmap() internal {
        uint256 count = 0;
        for (uint i = 1;i<=Mancount;i++){
            if (Manufacturers[i] != 0x0000000000000000000000000000000000000000) {
                address val = Manufacturers[i];
                 Manufacturers[i] = 0x0000000000000000000000000000000000000000;
                count = count +1;
               Manufacturers[count] = val;
              
            }
        }
        Mancount = count;
    }
      function setmapsel(address _myaddress) internal {
        uint256 count = 0;
        for (uint i = 1;i<=SellerCount[_myaddress];i++){
            if (Sellers[_myaddress][i] != 0x0000000000000000000000000000000000000000) {
                address val = Sellers[_myaddress][i];
                 Sellers[_myaddress][i] = 0x0000000000000000000000000000000000000000;
                count = count +1;
               Sellers[_myaddress][count] = val;
              
            }
        }
        SellerCount[_myaddress] = count;
    }
//    arrang products
     function setprod() internal {
        uint256 count = 0;
        for (uint i = 1;i<=ProdCount;i++){
            if (ManufProd[i].Manufacturer != 0x0000000000000000000000000000000000000000) {
                Product memory val = ManufProd[i];
                 ManufProd[i].Manufacturer = 0x0000000000000000000000000000000000000000;
                count = count +1;
               ManufProd[count] = val;
              
            }
        }
        ProdCount = count;
     }


    // Search if he is manufacturer
    function IsManufacturer(address _address) internal view returns(uint256){
        uint256 check = 0;
        for (uint256 i = 0; i <= Mancount; i++) {
            if(Manufacturers[i] == _address){
             check = 1;
               
            }
        }
        return check;
    }
    function IsSeller(address _manufactaddress,address _selleraddress ) internal view returns(uint256){
        uint256 check = 0;
        for (uint256 i = 0; i <= SellerCount[_manufactaddress]; i++) {
            if(Sellers[_manufactaddress][i] == _selleraddress){
             check = 1;
               
            }
        }
        return check;
    }
    // Add items from Manufacturers
    function AddManufacturItem(uint256 uniqueno , string memory Name,string memory comapany,string memory _type,uint256 price,address seller,string memory location) public{
           address manufactur = msg.sender;
           require(IsManufacturer(manufactur) == 1,"Only Manufacturers are Allowed to add Seller");
           require(IsSeller(manufactur,seller)==1,"Invalid Seller");
           ProdCount =ProdCount +1 ;
           ManufProd[ProdCount].UniqueNo = uniqueno;
           ManufProd[ProdCount].ProductName = Name;
           ManufProd[ProdCount].CompanyName = comapany;
           ManufProd[ProdCount].ProductType = _type;
           ManufProd[ProdCount].ProductPrice = price;
           ManufProd[ProdCount].Manufacturer = manufactur;
           ManufProd[ProdCount].Seller = seller;
           ManufProd[ProdCount].SellerLocation = location;
           ManufProd[ProdCount].Status = 1;
           ManufProd[ProdCount].Manufacttimestamp = block.timestamp;
           ManufProd[ProdCount].Ownership = manufactur;
    }
    // For Manfacturers
    function addSeller(address _selleraddress) public{
        address _myaddress = msg.sender;
        require(IsManufacturer(_myaddress) == 1,"Only Manufacturers are Allowed to add Seller");
        SellerCount[_myaddress] = SellerCount[_myaddress] +1;
        Sellers[_myaddress][SellerCount[_myaddress]] = _selleraddress;
    }
    function deleteSeller(uint256 index) public{
        address _myaddress = msg.sender;
         require(IsManufacturer(_myaddress) == 1,"Only Manufacturers are Allowed to delete Seller");
         delete(Sellers[_myaddress][index]);
         setmapsel(_myaddress);
    }


    // For Seller
    // Get the unique no , type (from scanning the QR)  ,seller address,seller location(address from the current account and location for this time manually)

    function ProductSearch(uint256 _uniqueno) internal view returns (uint256){
        uint256 ret = 0;
         for (uint256 index = 1; index <= ProdCount; index++) {
           
           if (ManufProd[index].UniqueNo == _uniqueno){
            ret = index;
           }
         }
         return ret;
    }


    function GetProduct(uint256 _uniqueno) public{
        // search product
        // require(IsSeller() == 1,"Only Manufacturers are Allowed to add Seller");
        address _seller = msg.sender;
        uint256 index = ProductSearch(_uniqueno);
        address manufact =  ManufProd[index].Manufacturer;
        require(IsSeller(manufact,_seller) == 1,"Seller is not assigned by Manufacturers");
        require(ManufProd[index].Seller == _seller,"You are not the seller assigned to Sell this product");
        require(ManufProd[index].Status == 1,"Not for Seller");
        ManufProd[index].Sellertimestamp = block.timestamp;
        ManufProd[index].Status = 2;
        ManufProd[ProdCount].Ownership = _seller;
    }
    // Buyer
    // Check Product Authencity
    function CheckAuthent( uint256 uniqueno,address _seller,address _manufacturer,uint256 manufacttimestamp) public view returns(uint256){
        uint256 istrue = 0;
         uint256 index = ProductSearch(uniqueno);
         require(index != 0,"Product not found");
         require(ManufProd[index].Seller == _seller);
         require(ManufProd[index].Manufacturer == _manufacturer);
         if (ManufProd[index].Manufacttimestamp == manufacttimestamp) {
             istrue = 1;
         }
         return istrue;
    }


    function BuyProduct(uint256 uniqueno ) public payable{
       address buyer = msg.sender;
       uint256 index = ProductSearch(uniqueno);
       require(index != 0,"Product not found");
       require(ManufProd[index].Status == 2,"Not came from seller");
       require(msg.value == ManufProd[index].ProductPrice );
       ManufProd[index].Status == 3;
       ManufProd[index].Ownership = buyer;

    }

    function getIndex(uint256 uniqueno,address _seller,address _manufacturer,uint256 manufacttimestamp) public view returns(uint256){
          require(CheckAuthent(uniqueno,_seller,_manufacturer,manufacttimestamp) == 1,"Not Authenticated");
          uint256 index = ProductSearch(uniqueno);
          return index;
    }

}
