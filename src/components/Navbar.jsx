import React from 'react'
import { useState } from 'react'
import { close, logo, menu } from '../assets'
import { navLinks } from '../constants'
import Web3 from "web3";
import { Button } from 'antd';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import {  Constants, ToastMessage, Manufacturer, Distributor, Pharmacy, Consumer } from "../components";
const Navbar = () => {

  const [web3Config, setWeb3Config] = useState(null);
  const [toggle, setToggle] = useState(false)
  const [showNavLinks, setShowNavLinks] = useState(true);
  const [showRouter, setShowRouter] = useState(false);

  const connectWeb3 = async () => {
    try {
      if (Web3.givenProvider) {
        await Web3.givenProvider.enable();
        let web3 = new Web3(Web3.givenProvider);
        let account = await web3.eth.getAccounts();
        account = account[0];
        console.log("Account", account);
        ToastMessage("Sucess", "Web3 Provider Connected", "success");

        const manufacturerContract  = new web3.eth.Contract(Constants.manufacturerABI, Constants.manufacturerContract);
        const distributorContract = new web3.eth.Contract(
          Constants.distributorABI,
          Constants.distributorContract
        );
  
        const consumerContract = new web3.eth.Contract(
          Constants.consumerABI,
          Constants.consumerContract
        );
  
        const pharmacyContract = new web3.eth.Contract(
          Constants.pharmacyABI,
          Constants.pharmacyContract
        );
        setWeb3Config({
          web3, account, manufacturerContract,
          distributorContract,
          consumerContract,
          pharmacyContract,

        });
        setShowRouter(true);
        setShowNavLinks(false);
      }
      else {
        ToastMessage("Web3 Provider not found", "Please Install Metamask or any Other!", "error");
      }
    } catch (error) {
      console.error(error);
    }

  }
  return (
    <nav className='w-full flex py-6 justify-between items-center navbar'>
      <img src={logo} alt="drugStore" className='w-[124px]  h-[32px]' />
      {showNavLinks && (
      <ul className='list-none sm:flex hidden justify-end items-center flex-1'>
      
        {navLinks.map((nav, index) => (
          <li key={nav.id}
            className={` z-10 font-poppins font-normal cursor-pointer text-[16px] text-white ${index === navLinks.length - 1 ? 'mr-0' : 'mr-20'}`}>

            <a href={`#${nav.id}`}>{nav.title}</a>
          </li>

        )
        )}
         </ul>
         )}
 {showRouter && (
  <ul className='z-10 list-none sm:flex hidden justify-end items-center flex-1'>
        <Router>


          <li className={`font-poppins font-normal cursor-pointer text-[16px] text-white ml-10 mr-10`}   > <Link to="/Manufacturer" >Manufacturer</Link></li>
          <li className={`font-poppins font-normal cursor-pointer text-[16px] text-white mr-10`} > <Link to="/Distributor" >Distributor</Link></li>
          <li className={`font-poppins font-normal cursor-pointer text-[16px] text-white mr-10`} ><Link to="/Pharmacy" >Pharmacy</Link></li>
          <li className={`font-poppins font-normal cursor-pointer text-[16px] text-white mr-10`} ><Link to="/Consumer" >Consumer</Link></li>

       
          <Routes>
            <Route exact path="/Manufacturer" element={<Manufacturer  web3Config={web3Config} />}></Route>
            <Route exact path="/Distributor" element={<Distributor web3Config={web3Config} />}></Route>
            <Route exact path="/Pharmacy" element={<Pharmacy web3Config={web3Config} />}></Route>
            <Route exact path="/Consumer" element={<Consumer web3Config={web3Config} />}></Route>
          </Routes>
        </Router>
        </ul>
        )}
     
      <Button className='ml-2 ' size='large' type='primary' onClick={connectWeb3} danger  style={{
    backgroundColor: web3Config ? 'green' : '', // Change to the color you want
    borderColor: web3Config ? 'green' : '', // Change to the color you want
  }}>  {web3Config ? 'Connected to MetaMask' : 'Connect Metamask'}</Button>
      <div className='sm:hidden flex flex-1 justify-end items-center'>
        <img src={toggle ? close : menu} alt='menu' className='w-[28px] h-[28px] object-contain' onClick={() => setToggle((prev) => (!prev))} />
      </div>
      <div
        className={`${toggle ? "flex" : "hidden"}
        p-6 bg-black-gradient absolute top-20 right-0 mx-4 my-2 min-w-[140px] rounded-xl sidebar`}>
        <ul className='list-none flex-col  justify-end items-center flex-1'>
          {navLinks.map((nav, index) => (
            <li key={nav.id}
              className={`font-poppins font-normal cursor-pointer text-[16px] text-white ${index === navLinks.length - 1 ? 'mb-0' : 'mb-4'}`}>

              <a href={`#${nav.id}`}>{nav.title}</a>
            </li>
          ))}

        </ul>


      </div>
    </nav>
  )
}

export default Navbar