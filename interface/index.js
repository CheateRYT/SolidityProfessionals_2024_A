$(document).ready(() => {
  fetch("./contractAbi.json")
    .then((response) => response.json())
    .then((abiFile) => {
      const provider = new Web3.providers.HttpProvider("http://127.0.0.1:8545");
      const web3 = new Web3(provider);
      let contract = new web3.eth.Contract(
        abiFile,
        "0xf7FF2Bb3CBaBbEe42C2854B99Cc64c49c9D2D058"
      );
      $(".nfts-block").hide();
      $(".collections-block").hide();
      $(".lots-block").hide();
      $(".auctions-block").hide();
      let selectedUser;
      window.ethereum
        .request({ method: "eth_requestAccounts" })
        .then((accounts) => {
          accounts.forEach((account) => {
            $("#choose-user__select").append(
              $(`<option class="user" value="${account}">${account}</option>`)
            );
          });
        });
      alert("Выберите пользователя!!!");
      $("#showNfts__btn").click(() => {
        $(".nfts-block").toggle();
      });
      $("#showCollections__btn").click(() => {
        $(".collections-block").toggle();
      });
      $("#showLots__btn").click(() => {
        $(".lots-block").toggle();
      });
      $("#showAuctions__btn").click(() => {
        $(".auctions-block").toggle();
      });
      $("#choose-user__select").change(() => {
        selectedUser = $("#choose-user__select").val();
        getUser(selectedUser);
        getBalance(selectedUser);
        setInterval(() => {
          reloadAuction();
        }, 10000);
      });

      $("#buyToken__btn").click(() => {
        buyToken($("#value_tokens").val());
      });

      function buyToken(value) {
        contract.methods
          .buyToken(value)
          .send({
            from: selectedUser,
            value: web3.utils.toWei(value.toString(), "ether"),
          })
          .then((result) => {
            alert("Выполнено");
            console.log(result);
            getBalance(selectedUser);
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#sellToken__btn").click(() => {
        sellToken($("#value_tokens").val());
      });

      function sellToken(value) {
        contract.methods
          .sellToken(value)
          .send({
            from: selectedUser,
          })
          .then((result) => {
            alert("Выполнено");
            console.log(result);
            getBalance(selectedUser);
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#createNft__btn").click(() => {
        createNft(
          $("#name_createNft").val(),
          $("#descr_createNft").val(),
          $("#path_createNft").val(),
          $("#value_createNft").val(),
          $("#price_createNft").val()
        );
      });

      function createNft(name, descr, path, value, price) {
        contract.methods
          .createNft(name, descr, path, value, price)
          .send({ from: selectedUser })
          .then((result) => {
            getNfts();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#changeNftPrice__btn").click(() => {
        changeNftPrice(
          $("#id_changeNftPrice").val(),
          $("#price_changeNftPrice").val()
        );
      });

      function changeNftPrice(id, price) {
        contract.methods
          .changeNftPrice(id, price)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);
            getNfts();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#createCollection__btn").click(() => {
        createCollection(
          $("#nftIds_createCollection").val(),
          $("#value_createCollection").val(),
          $("#name_collection").val(),
          $("#descr_collection").val()
        );
      });

      function createCollection(nftIds, nftValues, name, descr) {
        let nftIdsArray = nftIds.split(",");
        let nftValuesArray = nftValues.split(",");
        contract.methods
          .createCollection(nftIdsArray, nftValuesArray, name, descr)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);
            getNfts();

            getCollections();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#createLot__btn").click(() => {
        createLot(
          $("#idNft_createLot").val(),
          $("#price_createLot").val(),
          $("#value_createLot").val(),
          $("#isCollection_createLot").val(),
          $("#idCollection_createLot").val()
        );
      });

      function createLot(nftId, price, value, isCollection, collectionId) {
        let isisCollection = true;
        if (isCollection == "true") {
          isisCollection = true;
        } else {
          isisCollection = false;
        }
        contract.methods
          .createLot(nftId, price, value, isisCollection, collectionId)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);

            getCollections();
            getNfts();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#createAuction__btn").click(() => {
        createAuction(
          $("#idCollection_createAuction").val(),
          $("#start_createAuction").val(),
          $("#stop_createAuction").val(),
          $("#minBet_createAuction").val(),
          $("#maxBet_createAuction").val()
        );
      });

      function createAuction(collectionId, start, stop, minBet, maxBet) {
        contract.methods
          .createAuction(collectionId, start, stop, minBet, maxBet)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);

            getAuctions();

            getCollections();
            getNfts();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#createRefCode__btn").click(() => {
        createRefCode(selectedUser);
      });

      function createRefCode(userAddress) {
        let slisedAddress = userAddress.slice(2, 6);
        let refCode = `SUPER-${slisedAddress}2024`;
        console.log(refCode);
        contract.methods
          .createRefCode(refCode)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);
            getUser(selectedUser);
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#activateRefCode__btn").click(() => {
        activateRefCode($("#refCode_activate").val());
      });

      function activateRefCode(refCode) {
        contract.methods
          .activateRefCode(refCode)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);
            getUser(selectedUser);
            getBalance(selectedUser);
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#giveNft__btn").click(() => {
        giveNft(
          $("#idNft_giveNft").val(),
          $("#value_giveNft").val(),
          $("#to_giveNft").val(),
          $("#isCollection_giveNft").val(),
          $("#idCollection_giveNft").val()
        );
      });

      function giveNft(nftId, nftValue, to, isCollection, collectionId) {
        let isisCollection;
        if (isCollection == "true") {
          isisCollection = true;
        } else {
          isisCollection = false;
        }
        contract.methods
          .giveNft(nftId, nftValue, to, isisCollection, collectionId)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);
            getNfts();

            getCollections();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#buyLot__btn").click(() => {
        buyLot($("#idNft_buyLot").val());
      });

      function buyLot(lotId) {
        contract.methods
          .buyLot(lotId)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);

            getBalance(selectedUser);
            getCollections();
            getNfts();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#deleteLot__btn").click(() => {
        deleteLot($("#idNft_deleteLot").val());
      });

      function deleteLot(lotId) {
        contract.methods
          .deleteLot(lotId)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);
            getBalance();
            getCollections();
            getNfts();
            getLots();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#putBet__btn").click(() => {
        putBet($("#idAuction_putBet").val(), $("#amount_putBet").val());
      });

      function putBet(auctionId, amount) {
        contract.methods
          .putBet(auctionId, amount)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);
            getAuctions();
            getBalance(selectedUser);
            getCollections();
            getNfts();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#deleteAuction__btn").click(() => {
        deleteAuction($("#idAuction_deleteAuction"));
      });

      function deleteAuction(auctionId) {
        contract.methods
          .deleteAuction(auctionId)
          .send({ from: selectedUser })
          .then((result) => {
            console.log(result);
            getAuctions();
            getBalance(selectedUser);
            getCollections();
            getNfts();
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#showNfts__btn").click(() => {
        getNfts();
      });

      function getNfts() {
        contract.methods
          .returnNfts()
          .call({ from: selectedUser })
          .then((result) => {
            // $("#nfts-list").val() = 0;
            $(".nfts-list").empty();
            result.forEach((nft) => {
              let existingNft = $(`<div class="nft" data-id="${nft.id}>
              <p class="nft_id">Айди нфт : ${nft.id} </p>
              <p class="nft_price">Цена нфт : ${nft.price} </p>
              <p class="nft_price">Имя нфт : ${nft.price} </p>
              <p class="nft_price">Описание нфт : ${nft.descr} </p>
              <img class="nft_image" src="./NFT/${nft.path}"> 
              <p class="nft_owner0">Контакт : ${nft.owners[0]}</p>
              <p class="nft_owner1">Owner : ${nft.owners[1]}</p>
              <p class="nft_owner2">Tom: ${nft.owners[2]}</p>
              <p class="nft_owner3">Max : ${nft.owners[3]}</p>
              <p class="nft_owner4">Jack: ${nft.owners[4]}</p>
              <p class="nft_values0">Количество нфт у контракта : ${nft.values[0]} </p>
                            <p class="nft_values1">Количество нфт у owner : ${nft.values[1]} </p>
                            <p class="nft_values2">Количество нфт у Tom : ${nft.values[2]} </p>
                            <p class="nft_values3">Количество нфт у Max : ${nft.values[3]} </p>
                            <p class="nft_values4">Количество нфт у Jack : ${nft.values[4]} </p>
              </div>"`);
              $(".nfts-list").append(existingNft);
            });
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#showLots__btn").click(() => {
        getLots();
      });

      function getLots() {
        contract.methods
          .returnLots()
          .call({ from: selectedUser })
          .then((result) => {
            $(".lots-list").empty();
            result.forEach((lot) => {
              let existingLot = $(`<div class="lot" data-id="${lot.id}>
              <p class="lot_id">Айди лота : ${lot.id} </p>
              <p class="lot_seller">Продавец : ${lot.seller} </p>
              <p class="lot_nftId">Айди нфт на продаже : ${lot.nftId}</p>
              <p class="lot_value">Количество нфт: ${lot.value}</p>
              <p class="lot_price">Цена за все: ${lot.price}</p>
              <p class="lot_exists">Лот завершен? : ${lot.exists}</p>
              </div>"`);
              $(".lots-list").append(existingLot);
            });
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#showAuctions__btn").click(() => {
        getAuctions();
      });

      function getAuctions() {
        contract.methods
          .returnAuctions()
          .call({ from: selectedUser })
          .then((result) => {
            $(".auctions-list").empty();
            result.forEach((auction) => {
              let existingAuction =
                $(`<div class="auction" data-id="${auction.id}>
              <p class="auction_id">Айди аукциона : ${auction.id} </p>
              <p class="auction_collectionId">Айди коллекции на аукционе : ${auction.collectionId} </p>
              <p class="auction_owner">Владелец : ${auction.owner}</p>
              <p class="auction_created">Время создания в секундах: ${auction.created}</p>
              <p class="auction_start">Время старта в секундах: ${auction.start}</p>
              <p class="auction_stop">Время завершения в секундах : ${auction.stop}</p>
              <p class="auction_minBet">Минимальная ставка : ${auction.minBet}</p>
              <p class="auction_maxBet">Максимальная ставка : ${auction.maxBet}</p>
              <p class="auction_bets">Участник Owner: ${auction.bets[0]}</p>
             <p class="auction_bets">Участник Tom: ${auction.bets[1]}</p>
                <p class="auction_bets">Участник Max: ${auction.bets[2]}</p>
                   <p class="auction_bets">Участник Jack: ${auction.bets[3]}</p>
              <p class="auction_exists">Аукцион завершен? : ${auction.exists}</p>
              </div>"`);
              $(".auctions-list").append(existingAuction);
            });
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#showCollections__btn").click(() => {
        getCollections();
      });

      function getCollections() {
        contract.methods
          .returnCollections()
          .call({ from: selectedUser })
          .then((result) => {
            $(".collections-list").empty();
            result.forEach((collection) => {
              let existingCollection =
                $(`<div class="collection" data-id="${collection.id}>
              <p class="collection_id">Айди коллекции : ${collection.id} </p>
              <p class="collection_owner">Владелец коллекции : ${collection.owner} </p>
              <p class="collection_name">Имя коллекции : ${collection.name}</p>
              <p class="collection_descr">Описание коллекции : ${collection.descr}</p>
              <p class="collection_ids">Айди нфт в коллекции: ${collection.nftIds}</p>
              <p class="collection_values">Количество нфт к каждому айди : ${collection.nftValues}</p>
              <p class="collection_inAuction">Колекция на аукционе?: ${collection.inAuction}</p>
              </div>"`);
              $(".collections-list").append(existingCollection);
            });
          })
          .catch((error) => {
            console.error(error);
          });
      }

      $("#checkRefCode__btn").click(() => {
        checkRefCode($("#address_checkRefCode").val());
      });

      function checkRefCode(address) {
        contract.methods
          .showUserRefCode(address)
          .call({ from: selectedUser })
          .then((result) => {
            $("#refCodeAddress").html(`<p>Его реферальный код : ${result}</p>`);
          })
          .catch((error) => {
            console.error(error);
          });
      }

      function reloadAuction() {
        contract.methods
          .reloadAuction()
          .send({ from: selectedUser })
          .then((result) => {})
          .catch((error) => {
            getAuctions();
            getNfts();
            getCollections();
            getBalance(selectedUser);
          });
      }

      function getBalance(selectedUser) {
        contract.methods
          .balanceOf(selectedUser)
          .call({ from: selectedUser })
          .then((result) => {
            let normalInt = result.toString().slice(0, -10);
            $("#token-balance").html(
              `<h5>Баланс SUPER токенов  : ${normalInt} Баланс SUPER токенов с 10 знаками ${result}</h5>`
            );
          })
          .catch((error) => {
            console.error(error);
          });
      }

      function getUser(address) {
        contract.methods
          .returnUser(address)
          .call({ from: selectedUser })
          .then((result) => {
            $(".cabinet").html(`<p>Имя пользователя : ${result.name}</p>
        <p>Адрес пользователя : ${result.userAddress}</p>
        <p>Реферальный код : ${result.refCode}</p>
        <p>Процент реферального кода : ${result.refCodePercent}</p>
        <p>Реферальный код активирован: ${result.refCodeActivated}</p>`);
          })
          .catch((error) => {
            console.error(error);
          });
      }
    });
});
