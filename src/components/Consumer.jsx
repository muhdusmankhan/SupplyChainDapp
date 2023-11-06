import React, { useState, useEffect } from "react";
import ToastMessage from "./ToastMessage";
import { Button, Modal, DatePicker, Tabs, Input, Tooltip, InputNumber, Select } from 'antd';
import { InfoCircleOutlined, MedicineBoxOutlined } from '@ant-design/icons';

const Consumer = ({ web3Config }) => {

  const [medicineName, setMedicineName] = useState("");
  const [lotNumber, setLotNumber] = useState(0);
  const [quantity, setQuantity] = useState(0);
  const [pharmacyAddress, setPharmacyAddress] = useState("");

  const [account, setAccount] = useState(0);
  const [verifyMedicineName, setverifyMedicineName] = useState("");
  const [verifyMedicineLot, setverifyMedicineLot] = useState("");
  const [verifyPharmacyAddress, setverifyPharmacyAddress] = useState("");

  const [tokenQuantity, setTokenQuanity] = useState("");


  const [returnMedicineName, setReturnMedicineName] = useState("");
  const [returnLotNumber, setReturnLotNumber] = useState(0);
  const [returnQuantity, setReturnQuantity] = useState(0);
  const [returnpharmacyAddress, setReturnPharmacyAddress] = useState("");

  const [open, setOpen] = useState(false);
  const [confirmLoading, setConfirmLoading] = useState(false);
  const [modalText, setModalText] = useState('Content of the modal');
  useEffect(() => {
    showModal();
  }, []);
  const showModal = () => {
    setOpen(true);
  };

  const handleOk = () => {
    setModalText('The modal will be closed after two seconds');
    setConfirmLoading(true);
    setTimeout(() => {
      setOpen(false);
      setConfirmLoading(false);
    }, 2000);
  };
  const handleCancel = () => {
    console.log('Clicked cancel button');
    setOpen(false);
  };

  const purchaseFromPharmacy = async () => {

    if (!medicineName || lotNumber <= 0 || quantity <= 0 || !pharmacyAddress) {
      ToastMessage("Failed", "Please fill in all fields", "error");
      return;
    }
    const receipt = await web3Config.consumerContract.methods
      .purchaseMedicine(medicineName, lotNumber, quantity, pharmacyAddress)
      .send({ from: web3Config.account });
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Purchased from pharmacy", "success");
    } else {
      ToastMessage("Failed", "Medicine not Purchased from pharmacy", "error");
    }
  };

  const verifyMedicine = async () => {
    if (!verifyMedicineName || verifyMedicineLot <= 0 || !verifyPharmacyAddress) {
      ToastMessage("Failed", "Please fill in all fields", "error");
      return;
    }

    const receipt = await web3Config.consumerContract.methods
      .verifyMedicine(verifyMedicineName, verifyMedicineLot, verifyPharmacyAddress)
      .call();
      console.log(receipt)
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Verified", "success");
    } else {
      ToastMessage("Failed", "Medicine not Verified", "error");
    }
  };

  const purchaseTokens = async () => {

    if (tokenQuantity <= 0) {
      ToastMessage("Failed", "Please enter a valid quantity", "error");
      return;
    }
    const receipt = await web3Config.consumerContract.methods.purchaseTokens(tokenQuantity).send({from: web3Config.account, value: tokenQuantity });
    if (receipt.status) {
      ToastMessage("Sucess", "Token Purchased", "success");
    } else {
      ToastMessage("Failed", "Token not Purchased", "error");
    }
  };

  const returnMedicinetoPharmacy = async () => {
    if (!returnMedicineName || returnLotNumber <= 0 || returnQuantity <= 0 || !returnpharmacyAddress) {
      ToastMessage("Failed", "Please fill in all fields", "error");
      return;
    }

    const receipt = await web3Config.consumerContract.methods
      .returnMedicine(returnMedicineName, returnLotNumber, returnQuantity, returnpharmacyAddress)
      .send({ from: web3Config.account });
  };


  //Sell Tokens
  const sellToken = async () => {
    if (account <= 0) {
      ToastMessage("Failed", "Please enter a valid account number", "error");
      return;
    }
    const sellToken = await web3Config.consumerContract.methods.sellTokens(account).send({ from: web3Config.account });
    if (sellToken.status) {
      ToastMessage("Sucess", "Distributor Valid", "success");
    } else {
      ToastMessage("Failed", "Distributor not Valid", "error");
    }
  }


  
  return (
    <div>
      <Modal
        title="Customer"
        open={open}
        onOk={handleOk}
        confirmLoading={confirmLoading}
        onCancel={handleCancel}
        okButtonProps={{ style: { backgroundColor: '#4096ff', borderColor: '#4096ff80', color: '#FFFFFF' } }}
      >  <Tabs defaultActiveKey="1">
          <Tabs.TabPane tab="Purchase Medicine" key="1"><div>
            <Input className="mb-2" type="text"

              value={medicineName}
              onChange={(e) => setMedicineName(e.target.value)}
              placeholder="Enter Medicine Name"

              prefix={<MedicineBoxOutlined className="site-form-item-icon" />}
              suffix={
                <Tooltip title="Medicine name that help user to identify product">
                  <InfoCircleOutlined
                    style={{
                      color: 'rgba(0,0,0,.45)',
                    }}
                  />
                </Tooltip>
              }
            />

            <InputNumber className="mb-2" type="number"
              placeholder="Lot Number"
              value={lotNumber}
              onChange={value => setLotNumber(value)} addonBefore="Lot #" />

            <InputNumber className="mb-2" type="number"
              placeholder="Quantity"
              value={quantity}
              onChange={value => setQuantity(value)} addonBefore="Quantity" />

            <Input className="mb-2" type="text"
              placeholder="Pharmacy Address"
              value={pharmacyAddress}
              onChange={(e) => setPharmacyAddress(e.target.value)} addonBefore="Acc #" />

            <Button type="dashed" onClick={purchaseFromPharmacy} danger> Purchase Medcine
            </Button></div>   </Tabs.TabPane>
          <Tabs.TabPane tab="Verify Medicine" key="2"><div>
            <Input className="mb-2" type="text"

              value={verifyMedicineName}
              onChange={(e) => setverifyMedicineName(e.target.value)}
              placeholder="Enter Medicine Name"

              prefix={<MedicineBoxOutlined className="site-form-item-icon" />}
              suffix={
                <Tooltip title="Medicine name that help user to identify product">
                  <InfoCircleOutlined
                    style={{
                      color: 'rgba(0,0,0,.45)',
                    }}
                  />
                </Tooltip>
              }
            />

            <InputNumber className="mb-2" type="number"
              placeholder="Lot Number"
              value={verifyMedicineLot}
              onChange={value => setverifyMedicineLot(value)} addonBefore="Lot #" />
           
            <Input className="mb-2" 
              placeholder="Pharmacy Address"
              value={verifyPharmacyAddress}
              onChange={(e) => setverifyPharmacyAddress(e.target.value)}  />

            <Button type="dashed" onClick={verifyMedicine} danger> Verify Medcine
            </Button></div>    </Tabs.TabPane>


          <Tabs.TabPane tab="Purchase Tokens" key="3">  <div>
            <InputNumber className="mb-2" type="number"
              placeholder="Quantity"
              value={tokenQuantity}
              onChange={value => setTokenQuanity(value)} addonBefore="Quantity" />
            <Button type="dashed" onClick={purchaseTokens} danger> Purchase Tokens
            </Button></div>  </Tabs.TabPane>
          <Tabs.TabPane tab="Return Medicine" key="4">  <div>

            <Input className="mb-2" type="text"

              value={returnMedicineName}
              onChange={(e) => setReturnMedicineName(e.target.value)}
              placeholder="Enter Medicine Name"

              prefix={<MedicineBoxOutlined className="site-form-item-icon" />}
              suffix={
                <Tooltip title="Medicine name that help user to identify product">
                  <InfoCircleOutlined
                    style={{
                      color: 'rgba(0,0,0,.45)',
                    }}
                  />
                </Tooltip>
              }
            />

            <InputNumber className="mb-2" type="number"
              placeholder="Lot Number"
              value={returnLotNumber}
              onChange={value => setReturnLotNumber(value)} addonBefore="Lot #" />

            <InputNumber className="mb-2" type="number"
              placeholder="Quantity"
              value={returnQuantity}
              onChange={value => setReturnQuantity(value)} addonBefore="Quantity" />

            <Input className="mb-2" type="text"
              placeholder="Pharmacy Address"
              value={returnpharmacyAddress}
              onChange={(e) => setReturnPharmacyAddress(e.target.value)}  />


            <Button type="dashed" onClick={returnMedicinetoPharmacy} danger> Return Medicine
            </Button></div>  </Tabs.TabPane>

          <Tabs.TabPane tab="Sell Token" key="5">
            <div>
              <Input className="mb-2" type="number" value={account} onChange={(e) => setAccount(e.target.value)} addonBefore="Token Amount" />
              <Button type="dashed" onClick={sellToken} danger>
                Sell Tokens
              </Button>
            </div>
          </Tabs.TabPane>
        </Tabs></Modal>





    </div>
  );
};

export default Consumer;
