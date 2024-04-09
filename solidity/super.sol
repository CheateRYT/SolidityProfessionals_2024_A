// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "ERC1155.sol";
import "ERC20.sol";
contract Super is ERC20, ERC1155 {
    address private owner;
    address private tom = 0x5C61FbDd5Fc5F9640dd1168BdFB463Ab1c2C2724;
    address private max = 0x3095a2eE9e2850CaD56cbe5cA132F2C0B316e7Eb;
    address private jack = 0x46988Da131E041717Ed73AeFFbC408d4EEA10B36;
    uint256 public tokenPrice = 1 ether;

    //Структура пользователя
    struct User{
        string name;
        address userAddress;
        string refCode;
        uint256 refCodePercent;
        bool refCodeActivated;
    }
    //Структура Нфт
    struct Nft{
        uint256 id;
        uint256 price;
        string name;
        string descr;
        string path;
        address[] owners;
        uint256[] values;
    }
    //Структура коллекции
    struct Collection{
        uint256 id;
        string name;
        string descr;
        address owner;
        uint256[] nftIds;
        uint256[] nftValues;
        bool inAuction;
    }
    //Структура лота на торговой площадке
    struct Lot{
        uint256 id;
        uint256 nftId;
        uint256 value;
        uint256 price;
        address seller;
        bool exists;
    }
    //Структура аукциона
    struct Auction{
        uint256 id;
        uint256 collectionId;
        address owner;
        uint256 created;
        uint256 start;
        uint256 stop;
        uint256 minBet;
        uint256 maxBet;
        uint256[] bets;
        address[] members;
        bool exists;
    }

    modifier onlyOwner()  {
        require(msg.sender == owner, "You are not owner");
        _;
    }
    mapping(address => User) users;
    mapping(string => address) refCodeAddress;
    Nft[] public nfts;
    Auction[] public auctions;
    Lot[] public lots;
    Collection[] public collections;

    //Конструктор со стартовыми настройками 
    constructor() payable  ERC1155("uri") ERC20("Professional","SUPER")  {
        owner = msg.sender;
        users[address(this)] = User("Contract", address(this), "",0, false);
        users[owner] = User("Owner", owner, "", 0, false);
        users[tom] = User("Tom", tom, "", 0, false);
        users[max] = User("Max", max, "", 0, false);
        users[jack] = User("Jack", jack, "", 0, false);
        distributeTokens();   

        address[] memory nftOwners = new address[](5);
        nftOwners[0] = address(this);
        nftOwners[1] = owner; 
        nftOwners[2] = tom;
        nftOwners[3] = max;
        nftOwners[4] = jack;

       // uint256[] memory nftValues0 = new uint256[](5);
      //  nftValues0[1] = 7;
        //uint256[] memory nftValues1 = new uint256[](5);
        //nftValues1[1] = 5;
       // uint256[] memory nftValues2 = new uint256[](5);
       // nftValues2[1] = 2;
       // uint256[] memory nftValues3 = new uint256[](5);
       // nftValues3[1] = 6;
      //  nfts.push(Nft(nfts.length, 2000, "Gerda v profil", "Skuchayshay haski po imeni gerda", "husky_nft1.png", nftOwners,nftValues0));
       // nfts.push(Nft(nfts.length, 5000, "Gerda na frilance", "Gerda relisnula nobiy proekt", "husky_nft2.png", nftOwners,nftValues1));
       // nfts.push(Nft(nfts.length, 3500, "Novogodnya gerda", "Gerda sdet boya kurantov", "husky_nft3.png", nftOwners,nftValues2));
      //  nfts.push(Nft(nfts.length, 4000, "Gerda v otpuske", "Priehala otdohnut posle tyashelogo proekta", "husky_nft4.png", nftOwners,nftValues3));


    }
    //Функция для указания количества десятичных знаков
    function decimals() public view override returns(uint8) {
        return 10;
    }

    //Функция раздает стартовые токены 
    function distributeTokens() private  {
       uint256 totalSupply = 1000000 * (10 ** decimals());
        _mint(owner, 100000 *(10 ** decimals()));
        _mint(tom, 200000 *(10 ** decimals()));
        _mint(max, 300000 *(10 ** decimals()));
        _mint(jack, 400000 *(10 ** decimals()));
    } 
    //Функция для покупки erc20 токенов принимает количество токенов
    function buyToken(uint256 value) public payable {
        approve(msg.sender, value * (10 ** decimals()));
        _transfer(owner, msg.sender, value * (10 ** decimals()));
        payable(owner).transfer(value * tokenPrice);
    }
    //Функция для продажи erc20 токенов принимает количество токенов
    function sellToken(uint256 value) public payable {
        require(msg.sender != owner, "Owner can't sell tokens");
          approve(msg.sender, value * (10 ** decimals()));
          _transfer(msg.sender, owner, value * (10 ** decimals()));
        payable(msg.sender).transfer(value * tokenPrice);
    }
    //Функция для создания одиночных нфт принимает имя нфт, описание, путь к картинке и количество этих нфт, цену, может вызвать только owner
    function createNft(string memory name,string memory descr,string memory path,uint256 value, uint256 price) public onlyOwner{
        address[] memory nftOwners = new address[](5);
        nftOwners[0] = address(this);
        nftOwners[1] = owner; 
        nftOwners[2] = tom;
        nftOwners[3] = max;
        nftOwners[4] = jack;
        uint256[] memory nftValues = new uint256[](5);
        uint256  newNft = nfts.length;
        for (uint256 i = 0; i < nftOwners.length; i++) {
            if (nftOwners[i] == msg.sender) {
                nftValues[i] = value;
            } else {
                nftValues[i] = 0;
            }
        }
          nfts.push(Nft(newNft, price,name,descr, path, nftOwners, nftValues));
    }
    //Функция позволяет изменить стоимость нфт, принимает айди нфт, и цену.
    function changeNftPrice(uint256 idNft, uint256 price) public {
        nfts[idNft].price = price;
    }
    //Функция для создания коллекции  принимает айди нфт в виде массива, их количество в виде массива, имя коллекции и описание может вызвать только owner
    function createCollection(uint256[] memory nftIds, uint256[] memory nftValues, string memory name, string memory descr) public onlyOwner {
            for (uint256 i = 0; i < nftIds.length; i++) {
                    for (uint256 j = 0; j < nfts[nftIds[i]].owners.length; j++) {
                        if (nfts[nftIds[i]].owners[j] == msg.sender) {
                            nfts[nftIds[i]].values[j] -= nftValues[i];
                            nfts[nftIds[i]].values[0] += nftValues[i];
                        }
                    }
            }
            collections.push(Collection(collections.length, name, descr, msg.sender, nftIds, nftValues, false));
    }
    //Функция для создания лота на торговой площадке принимает айди нфт для выставления, цену за всё, и количество этой нфт
    // и флаг из коллекции вы хотите продать или нет, а так же если из коллекции то тогда айди коллекции из которой вы хотите продать нфт
    function createLot(uint256 nftId, uint256 price,uint256 value, bool isCollection, uint256 collectionId) public {
         if (isCollection) {
            require(collections[collectionId].owner == msg.sender, "You are not owner of this collection");
            for (uint256 i = 0; i < collections[collectionId].nftIds.length; i++) {
                if (collections[collectionId].nftIds[i] == nftId) {
                    collections[collectionId].nftValues[i] -= value;
                }
            }
        } else {
            for (uint256 k = 0; k < nfts[nftId].owners.length;k++) {
                if (nfts[nftId].owners[k] == msg.sender) {
                    nfts[nftId].values[k] -= value;
                    nfts[nftId].values[0] += value;
                }
            }
        }
        lots.push(Lot(lots.length, nftId, value, price, msg.sender, true));
    }  
    //Функция для создания Аукциона принимает айди коллекции, время старта, время завершения, минимальную и максимальную ставку
    function createAuction(uint256 collectionId, uint256 start, uint256 stop, uint256 minBet, uint256 maxBet) public{
        require(collections[collectionId].inAuction == false, "Collection already in Auction");
        require (collections[collectionId].owner == msg.sender, "You are not owner of this collection");
        collections[collectionId].inAuction = true;
         address[] memory members = new address[](4);
        members[0] = owner; 
        members[1] = tom;
        members[2] = max;
        members[3] = jack;
        uint256[] memory bets = new uint256[](4);
        for (uint256 i = 0; i < members.length; i++) {
                bets[i] = 0;
        }
        auctions.push(Auction(auctions.length, collectionId, msg.sender, block.timestamp, block.timestamp + (1 minutes * start),
        block.timestamp + (1 minutes * start) + (1 minutes * stop),minBet, maxBet, bets, members, true ));
    }
    //Функция для создания реферального кода принимает текст реферального кода и записывает его в структуру 
    function createRefCode(string memory refCode) public {
        refCodeAddress[refCode] = msg.sender;
        users[msg.sender].refCode = refCode;
       
    }
    //Функция для активации реферального кода принимает текст реферального кода
    function activateRefCode(string memory refCode) public {
        if (users[msg.sender].refCodeActivated == false) {
             if (  users[refCodeAddress[refCode]].refCodePercent < 3) {
               users[refCodeAddress[refCode]].refCodePercent += 1;
        }
        _mint(msg.sender, 100 * (10 ** decimals()));
        }
    }
    //Функция для безвозмездной передачи нфт другому пользователю, принимает айди нфт, количество этой нфт, адресс кому передаете
    // и флаг из коллекции вы хотите отдать или нет, а так же если из коллекции то тогда айди коллекции из которой вы хотите отдать нфт
    function giveNft(uint256 nftId, uint256 nftValue, uint256, address to, bool isCollection, uint256 collectionId) public {
        if (isCollection) {
            for (uint256 i = 0; i < collections[collectionId].nftIds.length; i++) {
                if (collections[collectionId].nftIds[i] == nftId) {
                    collections[collectionId].nftValues[i] -= nftValue;
                    for (uint256 j = 0; j < nfts[nftId].owners.length; j++) {
                        if (nfts[nftId].owners[j] == to) {
                            nfts[nftId].values[j] += nftValue;
                            nfts[nftId].values[0] -= nftValue;
                        }
                    }
                }
            }
        } else {
            uint256 sellerPoint;
            for (uint256 w = 0; w <  nfts[nftId].owners.length; w++) {
                if (nfts[nftId].owners[w] == msg.sender) {
                    sellerPoint = w;
                }
            }
            for (uint256 k = 0; k < nfts[nftId].owners.length; k++) {
                        if (nfts[nftId].owners[k] == to) {
                            nfts[nftId].values[k] += nftValue;
                            nfts[nftId].values[sellerPoint] -= nftValue;
                        }
                    }
        }
    }
    //Функция для покупки лота на торговой плоащдке принимает аргументы айди лота
    function buyLot (uint256 lotId) public {
        require(lots[lotId].exists == true, "Lot already buyed");
        for (uint256 i = 0; i < nfts[lots[lotId].nftId].owners.length; i++) {
            if (nfts[lots[lotId].nftId].owners[i] == msg.sender) {
                 nfts[lots[lotId].nftId].values[i] += lots[lotId].value;
                 nfts[lots[lotId].nftId].values[0] -= lots[lotId].value;
            }
        }
        _transfer(msg.sender, lots[lotId].seller, lots[lotId].price * (10 ** decimals()));
        lots[lotId].exists = false;
    }
    //Функция для удаления лота с торговой площадки принимает айди лота
    function deleteLot(uint256 lotId) public {
        for (uint256 i = 0; i < nfts[lots[lotId].nftId].owners.length; i++) {
            if (nfts[lots[lotId].nftId].owners[i] == lots[lotId].seller) {
                nfts[lots[lotId].nftId].values[i] += lots[lotId].value;
                nfts[lots[lotId].nftId].values[0] -= lots[lotId].value;
            }
        }
        lots[lotId].exists = false;
    }

    //Функция для удаления аукциона принимает в аргументах айди аукциона
    function deleteAuction(uint256 auctionId) public{
        for (uint256 i = 0; i < auctions[auctionId].members.length; i++) {
                _transfer(address(this),auctions[auctionId].members[i], auctions[auctionId].bets[i]);
        }
                auctions[auctionId].exists = false;
                collections[auctions[auctionId].collectionId].inAuction = false;
    }
    //Функция для обновления данных об аукционе которая позволяет проверить завершились ли аукционы или нет и выдать приз
    function reloadAuction () public {
        for (uint256 i = 0; i < auctions.length; i++) {
            if (auctions[i].exists != false) {
                if (auctions[i].stop < block.timestamp) {
                    uint256 maxBet;
                    address maxBetAddress;
                    for (uint256 j = 0; j < auctions[i].members.length; j++) {
                        if ( auctions[i].bets[j] > maxBet) {
                            maxBet = auctions[i].bets[j];
                            maxBetAddress = auctions[i].members[j];
                        }
                    }
                collections[auctions[i].collectionId].owner = maxBetAddress;
                auctions[i].exists = false;
                        for (uint256 w = 0; w < auctions[i].members.length; w++) {
                            if (auctions[i].members[w] != maxBetAddress) {
                                _transfer(address(this),auctions[w].members[w], auctions[i].bets[w]);
                            } else {
                                _transfer(maxBetAddress, auctions[i].owner, maxBet * (10 ** decimals()));
                            }
        }
                }
            }
        }
    }
    //Функция позволяет ставить ставку на аукцион принимает в параметрах айди аукциона а так же сумму
    function putBet(uint256 auctionId, uint256 amount) public {
        require(auctions[auctionId].exists == true, "Auction already exists");
        require(auctions[auctionId].stop > block.timestamp, "Auction already exists");
        require(auctions[auctionId].minBet < amount, "You placed  less than minBet");
            if (auctions[auctionId].maxBet <= amount) {
                collections[auctions[auctionId].collectionId].owner = msg.sender;
                auctions[auctionId].exists = false;
                        for (uint256 i = 0; i < auctions[auctionId].members.length; i++) {
                            if (auctions[auctionId].members[i] != msg.sender) {
                                _transfer(address(this),auctions[auctionId].members[i], auctions[auctionId].bets[i]);
                            } else {
                                _transfer(msg.sender, auctions[auctionId].owner, amount * (10 ** decimals()));
                            }
                
        }
            } else {
                for (uint256 j = 0; j < auctions[auctionId].members.length; j++) {
                    if ( auctions[auctionId].members[j] == msg.sender) {
                         auctions[auctionId].bets[j] += amount;
                         _transfer(msg.sender, address(this),amount * (10 ** decimals()));
                    }
                }
            }
    }
    //Функция возвращает все лоты из торговой площадки в виде массива структур Lot
    function returnLots() external view returns(Lot[] memory) {
        return lots;
    }
    //Функция возвращает все аукционы в виде массива структур Auction
        function returnAuctions() external view returns(Auction[] memory) {
        return auctions;
    }
    //Функция возвращает все нфт коллекции в виде массива структур Collection
        function returnCollections() external view returns(Collection[] memory) {
        return collections;
    }
    //Функция возвращает все нфт в виде массива структур Nft
    function returnNfts() external view returns(Nft[] memory) {
        return nfts;
    }
    //Функция показывает реферальный код по адрессу человека,  получает адрес того чей реферальный код вы хотите узнать возвращает строку с реферальным кодом
    function  showUserRefCode(address to) external view returns(string memory refCode) {
        return users[to].refCode;
    }
    //Функция возвращает данные о пользователе, принимает адресс пользователя и возваращает структуру из маппинга по адрессу
    function returnUser(address userAddress) external view returns(User memory) {
        return users[userAddress];
    }
}