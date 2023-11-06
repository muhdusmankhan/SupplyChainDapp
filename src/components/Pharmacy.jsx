import React, { useState, useEffect } from "react";
import ToastMessage from "./ToastMessage";
import { Button, Modal, DatePicker, Tabs, Input, Tooltip, InputNumber, Select } from 'antd';
import { InfoCircleOutlined, MedicineBoxOutlined } from '@ant-design/icons';

const Pharmacy = ({ web3Config }) => {
  const [medicineName, setMedicineName] = useState("");
  const [lotNumber, setLotNumber] = useState(0);
  const [account, setAccount] = useState(0);
  const [amount, setamount] = useState(0);
  const [medVerifyAccount, setVerifyAccount] = useState(0);
  const [verifyLotNumber, setVerifyLotNumber] = useState(0);
  const [medicineVerifyName, setMedicineVerifyName] = useState("");
  const [quantity, setQuantity] = useState(0);
  const [tokenQuantity, setTokenQuantity] = useState(0);

  const [returnMedName, setreturnMedName] = useState();
  const [returnMedLotNumber, setreturnLotNumber] = useState();
  const [returnQuantity, setreturnQuantity] = useState();
  const [returnPharmacyAdd, setreturnPharmacyAdd] = useState();

  const [returnMedicineName, setReturnMedicineName] = useState(0);
  const [returnLotNumber, setReturnLotNumber] = useState(0);
  const [returnReturnQuantity, setReturnQuantity] = useState(0);
  const [returnDistributorAdd, setreturnDistributorAdd] = useState(0);


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

  const purchaseFromDistributor = async () => {
    if (!medicineName || lotNumber <= 0 || quantity <= 0 || account <= 0) {
      ToastMessage("Failed", "Please fill in all fields", "error");
      return;
    }

    const receipt = await web3Config.pharmacyContract.methods
      .purchaseMedicine(medicineName, lotNumber, quantity, account)
      .send({ from: web3Config.account });
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Purchased from Distributor", "success");
    } else {
      ToastMessage("Failed", "Medicine not Purchased from Distributor", "error");
    }
  };

  const purchaseTokens = async () => {
    if (tokenQuantity <= 0) {
      ToastMessage("Failed", "Please enter a valid quantity", "error");
      return;
    }
    const receipt = await web3Config.pharmacyContract.methods.purchaseTokens(tokenQuantity).send({ from: web3Config.account, value: quantity });
    if (receipt.status) {
      ToastMessage("Sucess", "Token Purcahsed", "success");
    } else {
      ToastMessage("Failed", "Token not Purcahsed ", "error");
    }
  };



  //Accept Return
  const acceptReturn = async () => {
    if (!returnMedName || returnMedLotNumber <= 0 || returnQuantity <= 0 || !returnPharmacyAdd) {
      ToastMessage("Failed", "Please fill in all fields", "error");
      return;
    }
    const acceptReturn = await web3Config.pharmacyContract.methods.acceptReturn(returnMedName, returnMedLotNumber, returnQuantity, returnPharmacyAdd).send({ from: web3Config.account });
    if (acceptReturn.status) {
      ToastMessage("Sucess", "Distributor Valid", "success");
    } else {
      ToastMessage("Failed", "Distributor not Valid", "error");
    }
  }

  const returnMedicine = async () => {
    if (!returnMedicineName || returnLotNumber <= 0 || returnReturnQuantity <= 0 || !returnDistributorAdd) {
      ToastMessage("Failed", "Please fill in all fields", "error");
      return;
    }
    const receipt = await await web3Config.pharmacyContract.methods.returnMedicine(returnMedicineName, returnLotNumber, returnReturnQuantity, returnDistributorAdd).send({ from: web3Config.account, gas: 3000000 });
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Returned", "success");
    } else {
      ToastMessage("Failed", "Medicine not Returned", "error");
    }
  };

  //Sell Tokens
  const sellToken = async () => {
    if (account <= 0) {
      ToastMessage("Failed", "Please enter a valid account number", "error");
      return;
    }
    const sellToken = await web3Config.pharmacyContract.methods.sellTokens(account).send({ from: web3Config.account });
    if (sellToken.status) {
      ToastMessage("Sucess", "Distributor Valid", "success");
    } else {
      ToastMessage("Failed", "Distributor not Valid", "error");
    }
  }

  return (
    <div>
      <Modal
        title="Pharmacy"
        open={open}
        onOk={handleOk}
        confirmLoading={confirmLoading}
        onCancel={handleCancel}
        okButtonProps={{ style: { backgroundColor: '#4096ff', borderColor: '#4096ff80', color: '#FFFFFF' } }}
      >
        <Tabs defaultActiveKey="1">
          <Tabs.TabPane tab="Purchase Tokens" key="1"><div>  <InputNumber className="mb-2" type="number"
            placeholder="Quantity"
            value={tokenQuantity}
            onChange={value => setTokenQuantity(value)} />
            <Button type="dashed" onClick={purchaseTokens} danger> Purchase Tokens
            </Button></div></Tabs.TabPane>
          <Tabs.TabPane tab="Purchase Medicine" key="2"><div>
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
              placeholder="Quantity"
              value={quantity}
              onChange={value => setQuantity(value)} addonBefore="Quantity" />

            <InputNumber className="mb-2" type="number"
              placeholder="Lot Number"
              value={lotNumber}
              onChange={value => setLotNumber(value)} addonBefore="Lot #" />

            <Input className="mb-2"
              placeholder="Pharmacy Address"
              value={account}
              onChange={(e) => setAccount(e.target.value)} />
            <Button type="dashed" onClick={purchaseFromDistributor} danger> Purchase Medcine
            </Button></div></Tabs.TabPane>
          

          <Tabs.TabPane tab="Accept Return" key="3">
            <div>

              <Input className="mb-2" type="text" value={returnMedName} onChange={(e) => setreturnMedName(e.target.value)}
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

              <InputNumber className="mb-2" type="number" value={returnMedLotNumber} onChange={value => setreturnLotNumber(value)} addonBefore="Lot #" />





              <InputNumber className="mb-2" type="number" value={returnQuantity} onChange={value => setreturnQuantity(value)} addonBefore="Quantity" />

              <Input className="mb-2" value={returnPharmacyAdd} onChange={(e) => setreturnPharmacyAdd(e.target.value)} addonBefore="Acc #" />

              <Button type="dashed" onClick={acceptReturn} danger>
                Accept Return
              </Button>

            </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Return Medicine" key="4">
            <div>
              <Input className="mb-2" t value={returnMedicineName}
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
                value={returnReturnQuantity}
                onChange={value => setReturnQuantity(value)} addonBefore="Quantity" />
                     <Input className="mb-2" type="text"
                placeholder="Pharmacy Address"
                value={returnDistributorAdd}
                onChange={(e) => setreturnDistributorAdd(e.target.value)} />
              <Button type="dashed" onClick={returnMedicine} danger>
                Return Medicine
              </Button>
            </div>
          </Tabs.TabPane>

          <Tabs.TabPane tab="Sell Token" key="5">
            <div>
              <InputNumber className="mb-2" type="number" value={account} onChange={value => setAccount(value)} addonBefore="Token Amount" />
              <Button type="dashed" onClick={sellToken} danger>
                Sell Tokens
              </Button>
            </div>
          </Tabs.TabPane>



        </Tabs>
      </Modal>
    </div>
  );
};

export default Pharmacy;
