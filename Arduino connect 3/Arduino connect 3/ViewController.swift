//
//  ViewController.swift
//  Arduino connect 3
//
//  Created by Eric on 11/3/16.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
var indexOfBTDevice : Int!;
var tmpchar : CBCharacteristic!;
var btmger : blueToothManager!;
var uidArr = [CBUUID]();
var serviceArr = [CBUUID]();
var periph = [CBPeripheral]();
let screenSize: CGRect = UIScreen.main.bounds;
var myTimer: Timer? = nil

let buttonConnect = UIButton(); // let preferred over var here
let typePickerView: UIPickerView = UIPickerView();
var scanningLabel = UILabel();
var actInd: UIActivityIndicatorView = UIActivityIndicatorView();

var sliderLeftTop = UISlider();
var sliderLeftBot = UISlider();
var sliderRightTop = UISlider();
var sliderRightBot = UISlider();


let textColor = UIColor(hue: 0.4806, saturation: 0, brightness: 0.82, alpha: 1.0);

class blueToothManager {
    var centralManager: CBCentralManager!
    var bleHandler : BLEHandler
    init(){
        self.bleHandler = BLEHandler();
        self.centralManager = CBCentralManager(delegate: self.bleHandler, queue:nil);
    }
    
}

class BLEHandler : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    override init(){
        super.init();
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state){
        case .unsupported:
            print("unsupported");
        case .poweredOn:
            print("Powered On");
            central.scanForPeripherals(withServices: nil, options: nil);
        case .poweredOff:
            print("Powered Off");
        default:
            print("BLE default");
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var isExist = 0;
        
        if periph.count != 0 {
            for i in 0...periph.count-1 {
                if periph[i].name == peripheral.name {
                    isExist = 1;
                    break;
                }
            }
        }

        if ((isExist == 0) && (peripheral.name != nil)){
            periph.append(peripheral);
            print("\(peripheral.name)");
        }
        
        /*if periph.count != 0 {
            for periphID in 0...periph.count-1{
                if periph[periphID].name == "HMSoft"{
                    central.connect(periph[periphID], options: nil);
                    central.stopScan();
                }
            }
        }*/
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        periph[indexOfBTDevice].delegate = self;
        periph[indexOfBTDevice].discoverServices(nil);
        
        removeNoNeedObject();
        /*if periph.count != 0 {
            for periphID in 0...periph.count-1{
                if periph[periphID].name == "HMSoft"{
                    periph[periphID].delegate = self;
                    periph[periphID].discoverServices(nil);
                }
            }
        }*/
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for ser in peripheral.services! {
            print("Service found with UUID: " + ser.uuid.uuidString)
            peripheral.discoverCharacteristics(nil, for: ser);
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for character in service.characteristics!{
            if character.uuid.uuidString == "FFE1" {
                print("characteristic uuid: " + character.uuid.uuidString);
                tmpchar = character;
                let bytes : [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
                let data = Data(bytes:bytes)
                peripheral.writeValue(data as Data, for: character, type: CBCharacteristicWriteType.withoutResponse);
                peripheral.setNotifyValue(true, for: character);
            }
        }
    }
    
    func removeNoNeedObject(){
        buttonConnect.removeFromSuperview();
        typePickerView.removeFromSuperview();
        actInd.removeFromSuperview();
        scanningLabel.removeFromSuperview();
    }
    
    //arduino Bluetooth RX
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //print("characteristic uuidtest: " + characteristic.uuid.uuidString);
        print("update");
        /*var parameter = NSInteger(1)
        let data = NSData(bytes: &parameter, length: 1)*/
        // data to string
        //let str = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue);
        
        // string to data
        //str?.data(using: String.Encoding.utf8.rawValue);
        //peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse);
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("wrote");
    }
    //arduino Bluetooth TX
    
    //isWriteSuccess
    
    
}

func createLableWithText(str:String, coordinate:CGPoint) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21));
    label.center = coordinate;
    label.textAlignment = .center;
    label.text = str;
    label.textColor = textColor;
    return label;
}

extension UIView {
       func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 2.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}




class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let screenWidth = screenSize.width;
    let screenHeight = screenSize.height;
    @objc func createScanningLabel(){
         let co = CGPoint(x: screenWidth/2 - 20, y: screenHeight/4);
         scanningLabel = createLableWithText(str: "Scanning", coordinate: co);
         self.view.addSubview(scanningLabel);
        
        actInd.center = CGPoint(x: co.x + 65, y:co.y);
        actInd.hidesWhenStopped = true
        actInd.color = UIColor.black;
        self.view.addSubview(actInd);
        actInd.startAnimating();
    }
    
    @objc func createPickerView(){
        typePickerView.delegate = self;
        typePickerView.dataSource = self;
        typePickerView.isHidden = false;
        typePickerView.backgroundColor = UIColor.white;
        typePickerView.center = CGPoint(x: screenWidth/2, y: screenHeight*3/7);
        self.view.addSubview(typePickerView);
    }
    
    @objc func createButton(){
        let co = CGPoint(x: screenWidth/2 , y: screenHeight/2);
        buttonConnect.isHidden = false;
        buttonConnect.frame = CGRect(x:100, y:100, width:200, height:100);
        buttonConnect.center = CGPoint(x:co.x, y:co.y+1/2*co.y);
        buttonConnect.setTitle("Connect", for: UIControlState.normal);
        buttonConnect.setTitleColor(UIColor .blue, for: UIControlState.normal)
        buttonConnect.addTarget(self, action: #selector(buttonPressed), for: UIControlEvents.touchUpInside);
        self.view.addSubview(buttonConnect);
    }
    
    @objc func LTsliderChanged(){
        
         let bytes : [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, UInt8(sliderLeftTop.value)];
         let data = Data(bytes:bytes);
         periph[indexOfBTDevice].writeValue(data as Data, for: tmpchar, type: CBCharacteristicWriteType.withoutResponse);
         periph[indexOfBTDevice].setNotifyValue(true, for: tmpchar);
    }
    @objc func LBsliderChanged(){
        let bytes : [UInt8] = [0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, UInt8(sliderLeftBot.value)];
        let data = Data(bytes:bytes);
        periph[indexOfBTDevice].writeValue(data as Data, for: tmpchar, type: CBCharacteristicWriteType.withoutResponse);
        periph[indexOfBTDevice].setNotifyValue(true, for: tmpchar);
    }
    @objc func RTsliderChanged(){
        let bytes : [UInt8] = [0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, UInt8(sliderRightTop.value)];
        let data = Data(bytes:bytes);
        periph[indexOfBTDevice].writeValue(data as Data, for: tmpchar, type: CBCharacteristicWriteType.withoutResponse);
        periph[indexOfBTDevice].setNotifyValue(true, for: tmpchar);
    }
    
    @objc func RBsliderChanged(){
        let bytes : [UInt8] = [0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, UInt8(sliderRightBot.value)];
        let data = Data(bytes:bytes);
        periph[indexOfBTDevice].writeValue(data as Data, for: tmpchar, type: CBCharacteristicWriteType.withoutResponse);
        periph[indexOfBTDevice].setNotifyValue(true, for: tmpchar);
    }
    
    @objc func buildControl(){
        sliderLeftTop.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2));
        sliderLeftTop.maximumValue = 128;
        sliderLeftTop.minimumValue = 0;
        sliderLeftTop.value = 0;
        sliderLeftTop.addTarget(self, action: #selector(LTsliderChanged), for: .valueChanged)
        sliderLeftTop.isContinuous = false;
        sliderLeftTop.isHidden = false;
        sliderLeftTop.center = CGPoint(x: screenWidth/4, y: screenHeight/4);
        self.view.addSubview(sliderLeftTop);
        
        sliderLeftBot.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2));
        sliderLeftBot.maximumValue = 128;
        sliderLeftBot.minimumValue = 0;
        sliderLeftBot.value = 0;
        sliderLeftBot.addTarget(self, action: #selector(LBsliderChanged), for: .valueChanged)
        sliderLeftBot.isContinuous = false;
        sliderLeftBot.isHidden = false;
        sliderLeftBot.center = CGPoint(x: screenWidth/4, y: screenHeight*3/4);
        self.view.addSubview(sliderLeftBot);
        
        sliderRightTop.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2));
        sliderRightTop.maximumValue = 128;
        sliderRightTop.minimumValue = 0;
        sliderRightTop.value = 0;
        sliderRightTop.addTarget(self, action: #selector(RTsliderChanged), for: .valueChanged)
        sliderRightTop.isContinuous = false;
        sliderRightTop.isHidden = false;
        sliderRightTop.center = CGPoint(x: screenWidth*3/4, y: screenHeight/4);
        self.view.addSubview(sliderRightTop);
        
        sliderRightBot.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2));
        sliderRightBot.maximumValue = 128;
        sliderRightBot.minimumValue = 0;
        sliderRightBot.value = 0;
        sliderRightBot.addTarget(self, action: #selector(LBsliderChanged), for: .valueChanged)
        sliderRightBot.isContinuous = false;
        sliderRightBot.isHidden = false;
        sliderRightBot.center = CGPoint(x: screenWidth*3/4, y: screenHeight*3/4);
        self.view.addSubview(sliderRightBot);
    }
    
   
    
    @objc func buttonPressed(){
        //print("hello");
        //let tmpchar = CBCharacteristic();
        //tmpchar.value(forUndefinedKey: "FFE1");
        /*let bytes : [UInt8] = [0x00];
        let data = Data(bytes:bytes)
        periph[0].writeValue(data as Data, for: tmpchar, type: CBCharacteristicWriteType.withoutResponse);*/
        
        
        btmger.centralManager.connect(periph[indexOfBTDevice], options: nil);
        btmger.centralManager.stopScan();
        buildControl();
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        btmger = blueToothManager();
        indexOfBTDevice = 0;
        

        
        //welcome label
        let co = CGPoint(x: screenWidth/2, y: screenHeight/2);
        let welcomeLabel = createLableWithText(str: "Arduino Connect", coordinate: co);
        self.view.addSubview(welcomeLabel);
        welcomeLabel.fadeOut();
        
        //scanning device icon
        myTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(createScanningLabel), userInfo: nil, repeats: false)

        //picker view
        myTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(createPickerView), userInfo: nil, repeats: false)
        
        //create select button
        myTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(createButton), userInfo: nil, repeats: false)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent: Int) -> String?{
        return periph[row].name;
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1;
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return periph.count;
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indexOfBTDevice = row;
        pickerView.reloadAllComponents();
    }
}

