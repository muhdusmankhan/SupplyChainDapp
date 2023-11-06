import React, { useState, useEffect } from "react";
import ToastMessage from "./ToastMessage";
import { Button, Modal, DatePicker, Tabs,Input, Tooltip,InputNumber, Select } from 'antd';
import { InfoCircleOutlined, MedicineBoxOutlined } from '@ant-design/icons';


const { TabPane } = Tabs;
const Manufacturer = ({ web3Config }) => {

  const [name, setName] = useState();
  const [destoryMedName, setDestoryMedName] = useState();
  const [lotNumber, setLotNumber] = useState('');
  const [destoryMedLotNumber, setDestoryMedLotNumber] = useState();
  const [cat, setCat] = useState();
  const [quantity, setQuantity] = useState();
  const [destroyQuantity, setDestroyQuantity] = useState();
  const [price, setPrice] = useState();
  const [dateOfProduction, setDateOfProduction] = useState();
  const [dateofExpiry, setDateofExpiry] = useState();
  const [account, setAccount] = useState();

  const [returnMedName, setreturnMedName] = useState();
  const [returnLotNumber, setreturnLotNumber] = useState();
  const [returnQuantity, setreturnQuantity] = useState();
  const [returnDistributorAdd, setreturnDistributorAdd] = useState();

  const [mint, setMint] = useState(0);
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

  // Add medicine
  const addMedicine = async () => {
    try {
      if (!name || !lotNumber || !cat || !quantity || !price || !dateOfProduction || !dateofExpiry) {
        ToastMessage("Error", "Please fill in all fields", "error");
        return;
      }
      const dateOfProductionObject = new Date(dateOfProduction);
      const dateofExpiryObject = new Date(dateofExpiry);
      const dateOfProductionUnix = Math.floor(dateOfProductionObject.getTime() / 1000); // Convert to Unix timestamp (seconds)
      const dateofExpiryUnix = Math.floor(dateofExpiryObject.getTime() / 1000); // Convert to Unix timestamp (seconds)

console.log(web3Config);
console.log(name);
console.log(lotNumber);
console.log(cat);
console.log(quantity);
console.log(price);
console.log(dateOfProductionUnix);
console.log(dateofExpiryUnix);
      const receipt = await web3Config.manufacturerContract
      .methods.addMedicine(name, lotNumber, cat, quantity, price, dateOfProductionUnix, dateofExpiryUnix).send({ from: web3Config.account});
      if (receipt.status) {
        ToastMessage("Sucess", "Medicine Added", "success");
      } else {
        ToastMessage("Failed", "Medicine not Added", "error");
      }
    } catch (error) {
      console.error(error);
    }
  };

  // Mint tokens
  const mintTokens = async () => {
    try {
      if (mint <= 0) {
        ToastMessage("Error", "Please enter a valid token amount", "error");
        return;
      }
      const receipt = await web3Config.manufacturerContract.methods.mintTokens( mint).send({ from: web3Config.account, gas: 3000000 });
      if (receipt.status) {
        ToastMessage("Sucess", "Token Minted", "success");
      } else {
        ToastMessage("Failed", "Token not Minted", "error");
      }
    } catch (error) {
      console.error(error);
    }
  };

  // Destroy medicine
  const destroyMedicine = async () => {
    if (!destoryMedName || !destoryMedLotNumber || !destroyQuantity) {
      ToastMessage("Error", "Please fill in all fields", "error");
      return;
    }
    console.log(web3Config)
    const receipt = await web3Config.manufacturerContract.methods.destroyMed(destoryMedName, destoryMedLotNumber, destroyQuantity).send({ from: web3Config.account });
    if (receipt.status) {
      ToastMessage("Sucess", "Medicine Destroyed", "success");
    } else {
      ToastMessage("Failed", "Medicine not Destroyed", "error");
    }
  };


  // Add a Distributor
  const addValidDistributor = async () => {
    if (!account) {
      ToastMessage("Error", "Please fill in all fields", "error");
      return;
    }
    const isValidDistributor = await web3Config.manufacturerContract.methods.addValidDistributor(account).send({ from: web3Config.account });
    if (isValidDistributor.status) {
      ToastMessage("Sucess", "Distributor Valid", "success");
    } else {
      ToastMessage("Failed", "Distributor not Valid", "error");
    }
  };
  //Accept Return
  const acceptReturn = async () => {
    if (!returnMedName || !returnLotNumber || !returnQuantity || !returnDistributorAdd) {
      ToastMessage("Error", "Please fill in all fields", "error");
      return;
    }
    const acceptReturn = await web3Config.manufacturerContract.methods.acceptReturn(returnMedName,returnLotNumber,returnQuantity,returnDistributorAdd).send({ from: web3Config.account });
    if (acceptReturn.status) {
      ToastMessage("Sucess", "Distributor Valid", "success");
    } else {
      ToastMessage("Failed", "Distributor not Valid", "error");
    }
  }


  const { Option } = Select;



  return (
    <div>

      <Modal
        title="Manufacturer"
        open={open}
        onOk={handleOk}
        confirmLoading={confirmLoading}
        onCancel={handleCancel}
        okButtonProps={{ style: { backgroundColor: '#4096ff', borderColor: '#4096ff80', color: '#FFFFFF' } }}
      >
        <Tabs defaultActiveKey="1">
          <Tabs.TabPane tab="Add Medicine" key="1">
            <div>

              <Input className="mb-2" type="text" value={name}  onChange={(e) => setName(e.target.value)}
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

              <InputNumber className="mb-2" type="number" value={lotNumber}   onChange={value => setLotNumber(value)} addonBefore="Lot #"  />





              <InputNumber className="mb-2" type="number" value={quantity}  onChange={value => setQuantity(value)} addonBefore="Quantity"  />

              <InputNumber className="mb-2" type="number" value={price} onChange={value => setPrice(value)} addonBefore="Price"  />
              <DatePicker className="mb-2 mr-2" type="date" value={dateOfProduction} onChange={value =>  setDateOfProduction(value)} />
              <DatePicker className="mb-2" type="date" value={dateofExpiry}  onChange={value =>  setDateofExpiry(value)} />

              <br />
           
              <Select className="mb-2"
                value={cat}
                onChange={(value) => setCat(value)}
                style={{ width: 200 }}
                placeholder="Select a category"
              >
                <Option value="0">Off The Counter</Option>
                <Option value="1">Prescription Only</Option>
                <Option value="3">Herbal</Option>
                <Option value="4">Life Saving</Option>
              </Select>
              <br />
              <Button type="dashed" onClick={addMedicine} danger>
                Add Medicine
              </Button>

            </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Tokens" key="2">
            <div>

              <InputNumber className="mb-2" type="number" value={mint} onChange={value =>setMint(value)} addonBefore="Token Amount"  />

              <Button type="dashed" onClick={mintTokens} danger>  Mint Tokens
              </Button>
            </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Destory Medcine" key="3">
            <div>
          
              <Input className="mb-2" type="text" value={destoryMedName}  onChange={(e) => setDestoryMedName(e.target.value)}
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



              <InputNumber className="mb-2" type="number" value={destoryMedLotNumber} onChange={value => setDestoryMedLotNumber(value)} addonBefore="Lot #"  />


              <InputNumber className="mb-2" type="number" value={destroyQuantity}  onChange={value => setDestroyQuantity(value)} addonBefore="Quantity"  />
              <Button type="dashed" onClick={destroyMedicine} danger> Destroy Medcine
              </Button>
            </div>
          </Tabs.TabPane>
          <Tabs.TabPane tab="Add Valid Distributor" key="4">
          <div>
          <Input className="mb-2"  value={account} onChange={e => setAccount(e.target.value)} addonBefore="Acc #"  />
           
          </div>
          <Button type="dashed" onClick={addValidDistributor} danger> Add Valid Distributor
              </Button>
  
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

              <InputNumber className="mb-2" type="number" value={returnLotNumber} onChange={value => setreturnLotNumber(value)} addonBefore="Lot #"  />





              <InputNumber className="mb-2"  value={returnQuantity} onChange={value => setreturnQuantity(value)} addonBefore="Quantity"  />

              <Input className="mb-2"  value={returnDistributorAdd} onChange={(e) => setreturnDistributorAdd(e.target.value)}  addonBefore="Acc #"  />
            
              <Button type="dashed" onClick={acceptReturn} danger>
                Accept Return
              </Button>

            </div>
          </Tabs.TabPane>
        </Tabs>
      </Modal>
    </div>
  );
};

export default Manufacturer;
