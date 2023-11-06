import React, { useState,useEffect } from "react";
import ToastMessage from "./ToastMessage";
import { Button, Modal, Tabs, Input, Tooltip, InputNumber } from 'antd';
import { InfoCircleOutlined, MedicineBoxOutlined } from '@ant-design/icons';

const Distributor = ({ web3Config }) => {
  const [medicineName, setMedicineName] = useState("");
  const [lotNumber, setLotNumber] = useState(0);
  const [amount, setamount] = useState(0);
  const [account, setAccount] = useState(0);
  const [mint, setMint] = useState(0);
  const [returnMedicineName,setReturnMedicineName] = useState(0);
  const [returnLotNumber,setReturnLotNumber] = useState(0);
  const [returnReturnQuantity,setReturnQuantity] = useState(0);
  const [open, setOpen] = useState(false);
  const [confirmLoading, setConfirmLoading] = useState(false);
  const [modalText, setModalText] = useState('Content of the modal');

  const [returnMedName, setreturnMedName] = useState();
  const [returnMedLotNumber, setreturnLotNumber] = useState();
  const [returnQuantity, setreturnQuantity] = useState();
  const [returnPharmacyAdd, setreturnPharmacyAdd] = useState();

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

  const purchaseMedicine = async () => {
    if (!medicineName ||  lotNumber < 0) {
      ToastMessage("Failed", "Please fill in all fields", "error");
      return;
    }
    const receipt = await web3Config.distributorContract.methods.purchaseMedicine(medicineName, lotNumber).send({ from: web3Config.account, gas: 3000000 });
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Purchased", "success");
    } else {
      ToastMessage("Failed", "Medicine not Purchased", "error");
    }
  };

  const returnMedicine = async () => {
    if (!returnMedicineName || returnLotNumber <= 0 || returnReturnQuantity <= 0) {
      ToastMessage("Failed", "Please fill in all fields", "error");
      return;
    }
    const receipt = await await web3Config.distributorContract.methods.returnMedicine(returnMedicineName, returnLotNumber, returnReturnQuantity).send({ from: web3Config.account, gas: 3000000 });
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Returned", "success");
    } else {
      ToastMessage("Failed", "Medicine not Returned", "error");
    }
  };

  const addValidPharmacy = async () => {
    if (!account) {
      ToastMessage("Failed", "Please fill in the Pharmacy Address field", "error");
      return;
    }
    console.log(web3Config)
    const receipt = await web3Config.distributorContract.methods.addPharmacy(account).send({ from: web3Config.account, gas: 3000000 });
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Returned", "success");
    } else {
      ToastMessage("Failed", "Medicine not Returned", "error");
    }
  };

  const purchaseTokens = async () => {
    if (mint <= 0) {
      ToastMessage("Failed", "Please enter a valid Token Amount", "error");
      return;
    }
    console.log(web3Config)
    const receipt = await web3Config.distributorContract.methods.purchaseTokens(mint).send({ from: web3Config.account,value: mint });
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Returned", "success");
    } else {
      ToastMessage("Failed", "Medicine not Returned", "error");
    }
  };

    //Accept Return
    const acceptReturn = async () => {
      if (!returnMedName || returnMedLotNumber <= 0 || returnQuantity <= 0 || !returnPharmacyAdd) {
        ToastMessage("Failed", "Please fill in all fields", "error");
        return;
      }
      const acceptReturn = await web3Config.distributorContract.methods.acceptReturn(returnMedName,returnMedLotNumber,returnQuantity,returnPharmacyAdd).send({ from: web3Config.account });
      if (acceptReturn.status) {
        ToastMessage("Sucess", "Distributor Valid", "success");
      } else {
        ToastMessage("Failed", "Distributor not Valid", "error");
      }
    }


       //Sell Tokens
       const sellToken = async () => {
        if (amount <= 0) {
          ToastMessage("Failed", "Please enter a valid Token Amount", "error");
          return;
        }
        const sellToken = await web3Config.distributorContract.methods.sellTokens(amount).send({ from: web3Config.account });
        if (sellToken.status) {
          ToastMessage("Sucess", "Distributor Valid", "success");
        } else {
          ToastMessage("Failed", "Distributor not Valid", "error");
        }
      }
  

  return (
    <div>
      <Modal
        title="Distributor"
        open={open}
        onOk={handleOk}
        confirmLoading={confirmLoading}
        onCancel={handleCancel}
        okButtonProps={{ style: { backgroundColor: '#4096ff', borderColor: '#4096ff80', color: '#FFFFFF' } }}
      >
        <Tabs defaultActiveKey="1">
          <Tabs.TabPane tab="Add Medicine" key="1">
            <div>
              <Input className="mb-2" type="text" value={medicineName} onChange={(e) => setMedicineName(e.target.value)}
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



              <InputNumber className="mb-2" type="number" value={lotNumber} onChange={(e) => setLotNumber(e.target.value)} addonBefore="Lot #" />



          


              <Button type="dashed" onClick={purchaseMedicine} danger>
                Purchase Medicine
              </Button>
            </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Return Medicine" key="2">
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
              onChange={value => setReturnLotNumber(value)} addonBefore="Lot #"   />



<InputNumber className="mb-2" type="number"
              placeholder="Quantity"
              value={returnReturnQuantity}
              onChange={value => setReturnQuantity(value)} addonBefore="Quantity"   />
          <Button type="dashed" onClick={returnMedicine} danger>
          Return Medicine
              </Button>
              </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Add Pharmacy" key="3">
            <div>
          
            <Input className="mb-2" value={account} onChange={(e) => setAccount(e.target.value)}  addonBefore="Acc #"   />
            <Button type="dashed" onClick={addValidPharmacy} danger>
            Add Valid Pharmacy
              </Button>
            </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Purchase Token" key="4">
            <div>
          <InputNumber className="mb-2"type="number" value={mint} onChange={value => setMint(value)} addonBefore="Token Amount"   />
          <Button type="dashed" onClick={purchaseTokens} danger>
          Purchase Tokens
              </Button>
           </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Accept Return" key="5">
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

              <InputNumber className="mb-2"  value={returnMedLotNumber} onChange={value => setreturnLotNumber(value)} addonBefore="Lot #"   />





              <InputNumber className="mb-2"  value={returnQuantity} onChange={value => setreturnQuantity(value)} addonBefore="Quantity"   />

              <Input className="mb-2"  value={returnPharmacyAdd} onChange={(e) => setreturnPharmacyAdd(e.target.value)}  addonBefore="Acc #"   />
            
              <Button type="dashed" onClick={acceptReturn} danger>
                Accept Return
              </Button>

            </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Sell Token" key="6">
            <div>
          <InputNumber className="mb-2"type="number" value={amount} onChange={value => setamount(value)} addonBefore="Token Amount"   />
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

export default Distributor;
