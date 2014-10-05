//
//  ViewController.swift
//  Sketch
//
//  Created by Hannes Verlinde on 04/10/14.
//  Copyright (c) 2014 Hannes Verlinde. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let serviceType = CBUUID.UUIDWithString("89CAFFF0-275D-43DC-AE8F-0D083678A265")
    let characteristicType = CBUUID.UUIDWithString("3C10F17E-BD4B-46F6-B9AE-C43736504A56")

    var peripheralManager: CBPeripheralManager!
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == .PoweredOn {
            println("central on")
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        centralManager.scanForPeripheralsWithServices([serviceType], options: nil)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        self.peripheral = peripheral
        central.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceType])
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        peripheral.discoverCharacteristics([characteristicType], forService: peripheral.services.first as CBService)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        characteristic = service.characteristics.first as CBCharacteristic?
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if peripheral.state == .PoweredOn {
            println("peripheral on")
            
            let service = CBMutableService(type: serviceType, primary: true)
            service.characteristics = [CBMutableCharacteristic(type: characteristicType, properties: .WriteWithoutResponse, value: nil, permissions: .Writeable)]
            
            peripheralManager.addService(service)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [serviceType]])
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [AnyObject]!) {
        for request in requests as [CBATTRequest] {
            let point = CGPointFromString(NSString(data: request.value, encoding: NSUTF8StringEncoding))
            (view as View).addPoint(point)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let point = touch.locationInView(view)
        (view as View).addPoint(point)
        
        if let characteristic = characteristic {
            let data = NSStringFromCGPoint(point).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            peripheral?.writeValue(data, forCharacteristic: characteristic, type: .WithoutResponse)
        }
    }

}

