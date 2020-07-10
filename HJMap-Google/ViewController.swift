//
//  ViewController.swift
//  HJMap-Google
//
//  Created by 김희중 on 2020/07/09.
//  Copyright © 2020 HJ. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var mapContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var myLocationLabel: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = true
        lb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(myLocation)))
        lb.backgroundColor = .brown
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "내 위치"
        return lb
    }()
    
    lazy var markerLabel: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = true
        lb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(marker)))
        lb.backgroundColor = .blue
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "marker 생성"
        return lb
    }()
    
    lazy var customMarkerLabel: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = true
        lb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(customMarker)))
        lb.backgroundColor = .darkGray
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "custom Marker"
        return lb
    }()
    
    lazy var customInfoLabel: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = true
        lb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setupInfoWindow)))
        lb.backgroundColor = .purple
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "custom info"
        return lb
    }()
    
    lazy var customInfoDismissLabel: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = true
        lb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(customInfoDismiss)))
        lb.backgroundColor = .magenta
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "custom info dismiss"
        return lb
    }()
    
    lazy var mapview: GMSMapView = {
        var mapview = GMSMapView()
        let camera = GMSCameraPosition.camera(withLatitude: 37.552468, longitude: 126.923139, zoom: 16.0)
        mapview = GMSMapView.map(withFrame: .zero, camera: camera)
        mapview.isMyLocationEnabled = true
        mapview.delegate = self
        return mapview
    }()
    
    var infoWindow: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let whiteBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        return view
    }()
    
    let whiteTriBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    
    let infoLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "DMSans-Regular", size: 12)
        lb.textColor = .gray
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    
    var locationManager = CLLocationManager()
    
    
    // custom indo window
    // custom marker
    
    var mapContainerViewConstraint: NSLayoutConstraint?
    var myLocationLabelConstraint: NSLayoutConstraint?
    var markerLabelConstraint: NSLayoutConstraint?
    var customMarkerLabelConstraint: NSLayoutConstraint?
    var customInfoLabelConstraint: NSLayoutConstraint?
    var customInfoDismissLabelConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // 기본 설정
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        view = mapView
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        mapContainerView = mapview
        
        // 항상 containerview에 mapview를 설정하고 나서 containerview를 해당 view에 addsubview해주어야 한다.
        setupLayouts()
        
        // 기본 marker 설정
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
    }
    
    fileprivate func setupLayouts() {
        view.addSubview(mapContainerView)
        view.addSubview(myLocationLabel)
        view.addSubview(markerLabel)
        view.addSubview(customMarkerLabel)
        view.addSubview(customInfoLabel)
        view.addSubview(customInfoDismissLabel)

        mapContainerViewConstraint = mapContainerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0).first
        myLocationLabelConstraint = myLocationLabel.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 100, leftConstant: 0, bottomConstant: 0, rightConstant: 30, widthConstant: 100, heightConstant: 40).first
        markerLabelConstraint = markerLabel.anchor(myLocationLabel.bottomAnchor, left: nil, bottom: nil, right: myLocationLabel.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 40).first
        customMarkerLabelConstraint = customMarkerLabel.anchor(markerLabel.bottomAnchor, left: nil, bottom: nil, right: markerLabel.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 40).first
        customInfoLabelConstraint = customInfoLabel.anchor(customMarkerLabel.bottomAnchor, left: nil, bottom: nil, right: customMarkerLabel.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 40).first
        customInfoDismissLabelConstraint = customInfoDismissLabel.anchor(customInfoLabel.bottomAnchor, left: nil, bottom: nil, right: customInfoLabel.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 140, heightConstant: 40).first
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last

        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 16.0)

        self.mapview.animate(to: camera)

        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("did Tapped marker")
        return false
    }
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        // 66자 최대로
//        infoLabel.text = "자신만의 메모를 남기세요"
//        return self.infoWindow
//    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("did Tapped info window")
    }

    @objc fileprivate func myLocation() {
        guard let lat = self.mapview.myLocation?.coordinate.latitude,
              let lng = self.mapview.myLocation?.coordinate.longitude else { return }

        let camera = GMSCameraPosition.camera(withLatitude: lat ,longitude: lng, zoom: 16.0)
        self.mapview.animate(to: camera)
    }
    
    @objc fileprivate func marker() {
        mapview.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.552468, longitude: 126.923139)
        marker.title = "title"
        marker.snippet = "snippet"
        marker.map = mapview
    }
    
    @objc fileprivate func customMarker() {
        mapview.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.552468, longitude: 126.923139)
        marker.title = "title"
        marker.snippet = "snippet"
        marker.map = mapview
//        marker.icon = UIImage(named: "")
        marker.icon = GMSMarker.markerImage(with: .darkGray)
    }
    
    // infoWindow에는 autolayout 적용 불가능.
    @objc fileprivate func setupInfoWindow() {
        mapview.clear()
        customInfoClicked = true
        let width:CGFloat = 143
        let height:CGFloat = 103
        infoWindow.frame = CGRect(x: 0, y: 0, width: width, height: height)
        let mapinfoview = MapinfoView(frame: infoWindow.frame)
        mapinfoview.backgroundColor = .clear
        infoWindow.addSubview(mapinfoview)
        
        infoWindow.addSubview(whiteBackView)
        whiteBackView.layer.cornerRadius = width * 0.04
        
        infoWindow.addSubview(whiteTriBackView)
        
        infoWindow.addSubview(infoLabel)
        
        whiteBackView.frame = CGRect(x: 0, y: 0, width: width, height: height * 6/7)
        whiteTriBackView.frame = CGRect(x: width * 2/5, y: height * 6/7, width: width * 1/5, height: 1)
        
        infoLabel.frame = CGRect(x: 12, y: 0, width: 143 - 24, height: height - 12)
        customMarker()
    }
    
    @objc fileprivate func customInfoDismiss() {
        mapview.clear()
        customInfoClicked = false
        customMarker()
    }
    
    var customInfoClicked: Bool = false
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {

        if customInfoClicked {
            // custom info 클릭했을때(적용했을때)
            // 66자 최대
            infoLabel.text = "자신만의 메모를 남기세요"
            return self.infoWindow
        }
        
        else {
            // 원래 기본 marker info 처럼 나오게
            return nil
        }
    }
    

}
